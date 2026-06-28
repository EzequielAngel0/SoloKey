; Instalador de SoloKey (escritorio Windows) — Inno Setup 6.
; Empaqueta la salida portable de dist/windows en un SoloKey-<ver>-setup.exe.
;
; Compilar:  ISCC.exe /DMyAppVersion=1.0.0 installer\SoloKey.iss
; (build_release.ps1 -Target inno lo hace automaticamente, tras compilar Windows.)
;
; AppUserModelID en los accesos directos = el mismo que fija el runner nativo
; (windows/runner/main.cpp: SetCurrentProcessExplicitAppUserModelID), para que
; los toasts de notificacion salgan con icono y titulo "SoloKey".

#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif

; Carpeta con el build portable de Windows (exe + DLLs + data). build_release.ps1
; la pasa con /DSourceDir=<ruta del Release>; por defecto apunta al build local.
#ifndef SourceDir
  #define SourceDir SourcePath + "\..\build\windows\x64\runner\Release"
#endif

#define MyAppName "SoloKey"
#define MyAppPublisher "Angel Ezequiel Barbosa Lomeli"
#define MyAppExeName "SoloKey.exe"
#define MyAppId "com.angelezequiel.solokey"

[Setup]
AppId={{8570E795-279E-4AB7-89D1-3427F181D82F}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}
OutputDir={#SourcePath}\..\dist
OutputBaseFilename=SoloKey-{#MyAppVersion}-setup
SetupIconFile={#SourcePath}\..\windows\runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Instalacion per-user (sin UAC). La boveda queda en el %APPDATA% del usuario,
; misma ubicacion que al correr el .exe portable.
PrivilegesRequired=lowest
; Actualizaciones en sitio: mismo AppId => Inno reemplaza solo los binarios en
; {app} y NUNCA toca la boveda en %APPDATA%, asi que las credenciales se
; conservan (Drift migra el esquema solo al abrir la version nueva).
;
; NOTA: NO usamos CloseApplications/Restart Manager. SoloKey vive en la bandeja
; con la ventana oculta y reintercepta WM_CLOSE (prevent-close => se oculta en
; vez de salir), por lo que el Restart Manager solo cierra ventanas visibles y
; deja vivo el proceso en segundo plano, que sigue bloqueando el .exe/DLLs. En
; su lugar el [Code] de abajo hace taskkill /F del proceso antes de copiar.

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
; Regla de firewall entrante para el servidor de sync (vinculacion/sync con el
; celular en la red local). Opt-in: agrega la regla con una unica elevacion UAC.
Name: "firewall"; Description: "Permitir sincronizacion con el celular en la red local (regla de firewall)"; GroupDescription: "Red local:"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Excludes: "*.pdb,*.msix"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; AppUserModelID: "{#MyAppId}"
Name: "{userdesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; AppUserModelID: "{#MyAppId}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
// Cierra a la fuerza cualquier instancia de SoloKey (incluida la que vive
// oculta en la bandeja, que reintercepta WM_CLOSE y no saldria sola), para
// liberar el .exe/DLLs antes de reemplazarlos. Es seguro: la app persiste cada
// cambio de forma transaccional (SQLite/Keystore) y la clave en RAM es efimera.
procedure KillRunningApp;
var
  ResultCode: Integer;
begin
  Exec(ExpandConstant('{sys}\taskkill.exe'), '/F /T /IM {#MyAppExeName}', '',
    SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

// Se ejecuta justo antes de copiar archivos (tras pulsar "Instalar").
function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  KillRunningApp;
  Result := '';
end;

// Tambien al desinstalar, para no dejar el proceso bloqueando la carpeta.
function InitializeUninstall(): Boolean;
begin
  KillRunningApp;
  Result := True;
end;

// Regla de firewall ENTRANTE basada en el programa (cubre el rango de puertos
// dinamico 8283+ del servidor Shelf). El instalador es per-user (sin admin), asi
// que elevamos SOLO este paso con 'runas' (un UAC). Si el usuario cancela, el
// sync sigue siendo posible cuando Windows muestre su propio aviso de firewall.
procedure AddFirewallRule;
var
  ResultCode: Integer;
begin
  ShellExec('runas', ExpandConstant('{sys}\netsh.exe'),
    ExpandConstant('advfirewall firewall add rule name="SoloKey Sync" dir=in action=allow program="{app}\{#MyAppExeName}" enable=yes profile=private,domain'),
    '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep = ssPostInstall) and WizardIsTaskSelected('firewall') then
    AddFirewallRule;
end;

// Limpia la regla al desinstalar (elevado; si se cancela, no es critico).
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ResultCode: Integer;
begin
  if CurUninstallStep = usUninstall then
    ShellExec('runas', ExpandConstant('{sys}\netsh.exe'),
      'advfirewall firewall delete rule name="SoloKey Sync"',
      '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;
