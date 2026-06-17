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

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourcePath}\..\dist\windows\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; AppUserModelID: "{#MyAppId}"
Name: "{userdesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; AppUserModelID: "{#MyAppId}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
