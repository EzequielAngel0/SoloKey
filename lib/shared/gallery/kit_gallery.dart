import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/credentials/domain/entities/credential.dart';
import '../widgets/kit/kit.dart';

/// Galería del kit de Tinta y papel (DIS-3). Solo para la build debug: se abre
/// con `lib/main_galeria.dart` y no toca la bóveda ni la sesión. Aquí el dueño
/// afina los tonos en la app, con los dos temas y la letra al 200 %. La E2E de
/// E (CAL-1) la monta tal cual con [KitGalleryApp].
///
/// Los textos están en español fijo a propósito: es una herramienta de
/// desarrollo, no una pantalla de la app.
class KitGalleryApp extends StatefulWidget {
  const KitGalleryApp({super.key});

  @override
  State<KitGalleryApp> createState() => _KitGalleryAppState();
}

enum _Platform { mobile, desktop }

class _KitGalleryAppState extends State<KitGalleryApp> {
  ThemeMode _mode = ThemeMode.dark;
  double _scale = 2;
  _Platform _platform = _Platform.desktop;

  @override
  Widget build(BuildContext context) {
    final desktop = _platform == _Platform.desktop;
    return MaterialApp(
      title: 'SoloKey · Galería',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: AppTheme.light(desktop: desktop),
      darkTheme: AppTheme.dark(desktop: desktop),
      home: Builder(
        builder: (context) {
          final mq = MediaQuery.of(context);
          return Scaffold(
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Controls(
                    mode: _mode,
                    scale: _scale,
                    platform: _platform,
                    onMode: (m) => setState(() => _mode = m),
                    onScale: (s) => setState(() => _scale = s),
                    onPlatform: (p) => setState(() => _platform = p),
                  ),
                  Expanded(
                    child: MediaQuery(
                      data: mq.copyWith(textScaler: TextScaler.linear(_scale)),
                      child: const _Sections(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Controles de la galería, siempre al 100 % para poder usarlos.
class _Controls extends StatelessWidget {
  const _Controls({
    required this.mode,
    required this.scale,
    required this.platform,
    required this.onMode,
    required this.onScale,
    required this.onPlatform,
  });

  final ThemeMode mode;
  final double scale;
  final _Platform platform;
  final ValueChanged<ThemeMode> onMode;
  final ValueChanged<double> onScale;
  final ValueChanged<_Platform> onPlatform;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.sheet,
        border: Border(bottom: BorderSide(color: p.rule)),
      ),
      padding: const EdgeInsets.all(AppSpace.md),
      child: Wrap(
        spacing: AppSpace.lg,
        runSpacing: AppSpace.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Galería · Tinta y papel',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro')),
              ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
            ],
            selected: {mode},
            onSelectionChanged: (s) => onMode(s.first),
          ),
          SegmentedButton<double>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 1, label: Text('Letra 100 %')),
              ButtonSegment(value: 1.5, label: Text('150 %')),
              ButtonSegment(value: 2, label: Text('200 %')),
            ],
            selected: {scale},
            onSelectionChanged: (s) => onScale(s.first),
          ),
          SegmentedButton<_Platform>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: _Platform.mobile, label: Text('Móvil')),
              ButtonSegment(
                value: _Platform.desktop,
                label: Text('Escritorio'),
              ),
            ],
            selected: {platform},
            onSelectionChanged: (s) => onPlatform(s.first),
          ),
        ],
      ),
    );
  }
}

class _Sections extends StatefulWidget {
  const _Sections();

  @override
  State<_Sections> createState() => _SectionsState();
}

class _SectionsState extends State<_Sections> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scroll,
      thumbVisibility: true,
      child: ListView(
        controller: _scroll,
        padding: const EdgeInsets.all(AppSpace.xl),
        children: const [
          _Section('Color', child: _Swatches()),
          _Section('Letra', child: _TypeSpecimen()),
          _Section('Botones', child: _Buttons()),
          _Section('Campo secreto', child: _Secrets()),
          _Section('Filas de la bóveda', child: _Rows()),
          _Section('Tarjeta', child: _Cards()),
          _Section('Avisos y estados', child: _Notices()),
          _Section('Búsqueda y filtros', child: _SearchAndFilters()),
          _Section('Código TOTP', child: _Totp()),
          _Section('Barras del celular', child: _MobileBars()),
          _Section('Escritorio en tres paneles', child: _Desktop()),
          _Section('Sin nada', child: _Empty()),
          _Section('Logo', child: _Logos()),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, {required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpace.md),
          child,
        ],
      ),
    );
  }
}

// ── Color ───────────────────────────────────────────────────────────────────

class _Swatches extends StatelessWidget {
  const _Swatches();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tokens = <(String, String, Color)>[
      ('paper', 'Papel: fondo', p.paper),
      ('sheet', 'Hoja: tarjetas', p.sheet),
      ('raised', 'Elevada: diálogos', p.raised),
      ('inset', 'Hundida: campos', p.inset),
      ('ink', 'Tinta: texto y principal', p.ink),
      ('inkSoft', 'Tinta suave', p.inkSoft),
      ('inkFaint', 'Tinta tenue', p.inkFaint),
      ('inkGhost', 'Deshabilitado', p.inkGhost),
      ('rule', 'Borde', p.rule),
      ('ruleSoft', 'Borde suave', p.ruleSoft),
      ('ruleStrong', 'Borde de control', p.ruleStrong),
      ('breach', 'Comprometida', p.breach),
      ('breachWash', 'Fondo comprometida', p.breachWash),
      ('weak', 'Débil', p.weak),
      ('weakWash', 'Fondo débil', p.weakWash),
      ('sound', 'Sana', p.sound),
      ('soundWash', 'Fondo sana', p.soundWash),
    ];
    return Wrap(
      spacing: AppSpace.md,
      runSpacing: AppSpace.md,
      children: [
        for (final (name, role, color) in tokens)
          SizedBox(
            width: MediaQuery.textScalerOf(context).scale(180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppRadius.controlAll,
                    border: Border.all(color: p.rule),
                  ),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(role, style: Theme.of(context).textTheme.labelLarge),
                Text(
                  '$name  ${_hex(color)}',
                  style: AppTheme.mono(Theme.of(context).textTheme.labelMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

// ── Letra ───────────────────────────────────────────────────────────────────

class _TypeSpecimen extends StatelessWidget {
  const _TypeSpecimen();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final styles = <(String, TextStyle?)>[
      ('Titular', t.headlineMedium),
      ('Título', t.titleLarge),
      ('Subtítulo', t.titleMedium),
      ('Cuerpo', t.bodyMedium),
      ('Ayuda', t.bodySmall),
      ('Etiqueta', t.labelMedium),
    ];
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (name, style) in styles)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.sm),
              child: Text('$name · Contraseña de la bóveda', style: style),
            ),
          const Divider(height: AppSpace.xl),
          Text(
            'Mono, para secretos: Il1| O0o 5S 8B',
            style: AppTheme.mono(t.titleMedium),
          ),
          const SizedBox(height: AppSpace.sm),
          Text.rich(
            TextSpan(
              children: secretSpans(
                'Tr0mpet4-Az#l_2026',
                AppTheme.mono(t.titleLarge),
              ),
            ),
          ),
          Text(
            'Números más gruesos y símbolos en medio, sin otro color.',
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ── Botones ─────────────────────────────────────────────────────────────────

class _Buttons extends StatelessWidget {
  const _Buttons();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpace.md,
      runSpacing: AppSpace.md,
      children: [
        PaperButton(label: 'Guardar', icon: Icons.check, onPressed: () {}),
        PaperButton.secondary(label: 'Importar', onPressed: () {}),
        PaperButton.quiet(label: 'Cancelar', onPressed: () {}),
        PaperButton.destructive(
          label: 'Borrar para siempre',
          icon: Icons.delete_outline,
          onPressed: () {},
        ),
        const PaperButton(label: 'Deshabilitado', onPressed: null),
        PaperButton(label: 'Guardando', busy: true, onPressed: () {}),
        PaperButton(
          label: 'Botón que ocupa todo el ancho con un texto largo',
          expand: true,
          onPressed: () {},
        ),
      ],
    );
  }
}

// ── Campo secreto ───────────────────────────────────────────────────────────

class _Secrets extends StatefulWidget {
  const _Secrets();

  @override
  State<_Secrets> createState() => _SecretsState();
}

class _SecretsState extends State<_Secrets> {
  final _c = SecretTextController(text: 'Tr0mpet4-Az#l_2026');
  bool _shown = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SecretField(
          controller: _c,
          label: 'Contraseña',
          helper: 'Prueba a mostrarla: cambia el peso, no el color.',
          revealTooltip: 'Mostrar contraseña',
          hideTooltip: 'Ocultar contraseña',
          copyTooltip: 'Copiar contraseña',
          onCopy: () => Clipboard.setData(ClipboardData(text: _c.text)),
        ),
        const SizedBox(height: AppSpace.lg),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Usuario',
            hintText: 'nombre@correo.com',
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Con error',
            errorText: 'Este campo no puede quedar vacío',
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        PaperCard(
          title: 'Detalle (solo lectura)',
          trailing: PaperButton.quiet(
            label: _shown ? 'Ocultar' : 'Mostrar',
            onPressed: () => setState(() => _shown = !_shown),
          ),
          child: SecretText(value: _c.text, revealed: _shown),
        ),
      ],
    );
  }
}

// ── Filas ───────────────────────────────────────────────────────────────────

Future<void> _noop() async {}

class _Rows extends StatefulWidget {
  const _Rows();

  @override
  State<_Rows> createState() => _RowsState();
}

class _RowsState extends State<_Rows> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    const user = QuickCopy(
      tooltip: 'Copiar usuario',
      icon: Icons.person_outline,
      onCopy: _noop,
    );
    const pass = QuickCopy(tooltip: 'Copiar contraseña', onCopy: _noop);
    const code = QuickCopy(
      tooltip: 'Copiar código',
      icon: Icons.pin_outlined,
      onCopy: _noop,
    );
    final rows = <Widget>[
      CredentialRow(
        icon: credentialTypeIcon(CredentialType.password),
        title: 'Banco Nacional',
        subtitle: 'angel.ezequiel',
        favorite: true,
        favoriteLabel: 'Favorita',
        copies: const [user, pass],
      ),
      CredentialRow(
        icon: credentialTypeIcon(CredentialType.password),
        title: 'Correo personal con un nombre muy largo que no cabe',
        subtitle: 'una.direccion.de.correo.muy.larga@ejemplo.com.mx',
        status: const StatePill(label: 'Comprometida', tone: SafetyTone.breach),
        copies: const [user, pass],
      ),
      CredentialRow(
        icon: credentialTypeIcon(CredentialType.password),
        title: 'Tienda en línea',
        subtitle: 'compras',
        status: const StatePill(label: 'Repetida', tone: SafetyTone.weak),
        copies: const [user, pass],
      ),
      CredentialRow(
        icon: credentialTypeIcon(CredentialType.totp),
        title: 'GitHub',
        subtitle: 'Código de 6 dígitos',
        copies: const [code],
      ),
      CredentialRow(
        icon: credentialTypeIcon(CredentialType.sshKey),
        title: 'Servidor de casa',
        subtitle: 'ed25519',
        copies: const [pass],
      ),
      CredentialRow(
        icon: credentialTypeIcon(CredentialType.apiKey),
        title: 'API del clima',
        copies: const [pass],
      ),
      CredentialRow(
        icon: credentialTypeIcon(CredentialType.secureNote),
        title: 'Notas del seguro',
      ),
      CredentialRow(
        icon: credentialTypeIcon(CredentialType.passkey),
        title: 'Llave de acceso (respaldo)',
        subtitle: 'ejemplo.com',
      ),
    ];
    return PaperCard(
      padding: const EdgeInsets.all(AppSpace.sm),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(color: context.palette.ruleSoft),
            _selectable(i, rows[i] as CredentialRow),
          ],
        ],
      ),
    );
  }

  Widget _selectable(int i, CredentialRow r) => CredentialRow(
    icon: r.icon,
    title: r.title,
    subtitle: r.subtitle,
    status: r.status,
    copies: r.copies,
    favorite: r.favorite,
    favoriteLabel: r.favoriteLabel,
    selected: i == _selected,
    onTap: () => setState(() => _selected = i),
  );
}

// ── Tarjeta ─────────────────────────────────────────────────────────────────

class _Cards extends StatelessWidget {
  const _Cards();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Wrap(
      spacing: AppSpace.lg,
      runSpacing: AppSpace.lg,
      children: [
        SizedBox(
          width: 360,
          child: PaperCard(
            title: 'Salud de la bóveda',
            trailing: const StatePill(label: 'Sana', tone: SafetyTone.sound),
            child: Text(
              '128 credenciales revisadas. Ninguna aparece en filtraciones '
              'conocidas.',
              style: t.bodyMedium,
            ),
          ),
        ),
        SizedBox(
          width: 360,
          child: PaperCard(
            onTap: () {},
            semanticLabel: 'Tarjeta que se puede tocar',
            child: Row(
              children: [
                const Icon(Icons.devices_outlined),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(
                    'Sincronizar con el celular',
                    style: t.titleSmall,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Avisos ──────────────────────────────────────────────────────────────────

class _Notices extends StatelessWidget {
  const _Notices();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Notice(
          tone: SafetyTone.breach,
          title: '3 contraseñas aparecen en una filtración',
          message: 'Cámbialas cuanto antes en esos sitios.',
          action: PaperButton.quiet(label: 'Ver cuáles', onPressed: () {}),
        ),
        const SizedBox(height: AppSpace.md),
        const Notice(
          tone: SafetyTone.weak,
          title: '5 contraseñas se repiten',
          message: 'Si una se filtra, las demás quedan expuestas.',
        ),
        const SizedBox(height: AppSpace.md),
        const Notice(
          tone: SafetyTone.sound,
          title: 'Sincronizado hace un momento',
        ),
        const SizedBox(height: AppSpace.md),
        const Notice(
          title: 'La bóveda se bloquea sola a los 5 minutos',
          message: 'Puedes cambiarlo en Ajustes.',
        ),
        const SizedBox(height: AppSpace.lg),
        const Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: [
            StatePill(label: 'Comprometida', tone: SafetyTone.breach),
            StatePill(label: 'Débil', tone: SafetyTone.weak),
            StatePill(label: 'Por vencer', tone: SafetyTone.weak),
            StatePill(label: 'Sana', tone: SafetyTone.sound),
            StatePill(label: 'Sin revisar'),
          ],
        ),
      ],
    );
  }
}

// ── Búsqueda y filtros ──────────────────────────────────────────────────────

class _SearchAndFilters extends StatefulWidget {
  const _SearchAndFilters();

  @override
  State<_SearchAndFilters> createState() => _SearchAndFiltersState();
}

class _SearchAndFiltersState extends State<_SearchAndFilters> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    const filters = <(String, IconData?)>[
      ('Todo', null),
      ('Favoritas', Icons.star_outline),
      ('Contraseñas', Icons.key_outlined),
      ('Códigos', Icons.timer_outlined),
      ('Trabajo', Icons.folder_outlined),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SearchField(
          hint: 'Buscar en la bóveda',
          clearTooltip: 'Borrar búsqueda',
          shortcutHint: 'Ctrl K',
        ),
        const SizedBox(height: AppSpace.sm),
        Wrap(
          spacing: AppSpace.sm,
          children: [
            for (var i = 0; i < filters.length; i++)
              FilterPill(
                label: filters[i].$1,
                icon: filters[i].$2,
                selected: i == _filter,
                onTap: () => setState(() => _filter = i),
              ),
          ],
        ),
        const SectionLabel('Trabajo › Clientes › Norte'),
      ],
    );
  }
}

// ── TOTP ────────────────────────────────────────────────────────────────────

class _Totp extends StatefulWidget {
  const _Totp();

  @override
  State<_Totp> createState() => _TotpState();
}

class _TotpState extends State<_Totp> {
  late final Timer _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = 30 - DateTime.now().second % 30;
    return PaperCard(
      child: Wrap(
        spacing: AppSpace.xxl,
        runSpacing: AppSpace.lg,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TotpCode(code: '492019', secondsLeft: left),
          TotpCode(code: '492019', secondsLeft: left, large: false),
        ],
      ),
    );
  }
}

// ── Barras ──────────────────────────────────────────────────────────────────

class _MobileBars extends StatefulWidget {
  const _MobileBars();

  @override
  State<_MobileBars> createState() => _MobileBarsState();
}

class _MobileBarsState extends State<_MobileBars> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return Center(
      child: Container(
        width: 400,
        height: 560 + (scale - 1) * 120,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: p.ruleStrong),
        ),
        child: Scaffold(
          appBar: PaperTopBar(
            title: 'Bóveda',
            textScale: scale,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                tooltip: 'Nueva credencial',
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpace.md),
            children: [
              const SearchField(
                hint: 'Buscar',
                clearTooltip: 'Borrar búsqueda',
              ),
              const SizedBox(height: AppSpace.sm),
              CredentialRow(
                icon: credentialTypeIcon(CredentialType.password),
                title: 'Banco Nacional',
                subtitle: 'angel.ezequiel',
                copies: const [
                  QuickCopy(tooltip: 'Copiar contraseña', onCopy: _noop),
                ],
              ),
            ],
          ),
          bottomNavigationBar: PaperBottomBar(
            index: _tab,
            onSelect: (i) => setState(() => _tab = i),
            destinations: const [
              BarDestination(
                icon: Icons.lock_outline,
                selectedIcon: Icons.lock,
                label: 'Bóveda',
              ),
              BarDestination(
                icon: Icons.shield_outlined,
                selectedIcon: Icons.shield,
                label: 'Seguridad',
              ),
              BarDestination(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: 'Ajustes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Escritorio ──────────────────────────────────────────────────────────────

class _Desktop extends StatefulWidget {
  const _Desktop();

  @override
  State<_Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<_Desktop> {
  int _nav = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    const navs = <(IconData, String, int?, String)>[
      (Icons.lock_outline, 'Bóveda', 128, 'Ctrl 1'),
      (Icons.star_outline, 'Favoritas', 12, 'Ctrl 2'),
      (Icons.shield_outlined, 'Seguridad', null, 'Ctrl 3'),
      (Icons.settings_outlined, 'Ajustes', null, 'Ctrl ,'),
    ];
    return Container(
      height: 520 + (scale - 1) * 160,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: p.ruleStrong),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1100 + (scale - 1) * 300,
          child: DesktopPanes(
            navWidth: 248 + (scale - 1) * 100,
            listWidth: 360 + (scale - 1) * 120,
            nav: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
              children: [
                for (var i = 0; i < navs.length; i++)
                  NavItem(
                    icon: navs[i].$1,
                    label: navs[i].$2,
                    count: navs[i].$3,
                    shortcut: navs[i].$4,
                    selected: i == _nav,
                    onTap: () => setState(() => _nav = i),
                  ),
              ],
            ),
            list: ListView(
              padding: const EdgeInsets.all(AppSpace.md),
              children: [
                const SearchField(
                  hint: 'Buscar',
                  clearTooltip: 'Borrar búsqueda',
                  shortcutHint: 'Ctrl K',
                ),
                const SizedBox(height: AppSpace.sm),
                CredentialRow(
                  icon: credentialTypeIcon(CredentialType.password),
                  title: 'Banco Nacional',
                  subtitle: 'angel.ezequiel',
                  selected: true,
                  copies: const [
                    QuickCopy(tooltip: 'Copiar contraseña', onCopy: _noop),
                  ],
                ),
                CredentialRow(
                  icon: credentialTypeIcon(CredentialType.totp),
                  title: 'GitHub',
                  copies: const [
                    QuickCopy(tooltip: 'Copiar código', onCopy: _noop),
                  ],
                ),
              ],
            ),
            detail: ListView(
              padding: const EdgeInsets.all(AppSpace.xl),
              children: [
                Text('Banco Nacional', style: t.headlineSmall),
                const SizedBox(height: AppSpace.lg),
                PaperCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Usuario', style: t.labelMedium),
                      Text('angel.ezequiel', style: t.bodyLarge),
                      const SizedBox(height: AppSpace.md),
                      Text('Contraseña', style: t.labelMedium),
                      const SecretText(
                        value: 'Tr0mpet4-Az#l_2026',
                        revealed: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Vacío ───────────────────────────────────────────────────────────────────

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      child: EmptyNote(
        icon: Icons.search_off_outlined,
        title: 'Nada coincide con "banco"',
        message: 'Prueba con otra palabra o quita los filtros.',
        action: PaperButton.secondary(
          label: 'Quitar filtros',
          onPressed: () {},
        ),
      ),
    );
  }
}

// ── Logo (DIS-4) ────────────────────────────────────────────────────────────

class _Logos extends StatelessWidget {
  const _Logos();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpace.md,
      runSpacing: AppSpace.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _LogoGround(ground: AppPalette.light.paper),
        _LogoGround(ground: AppPalette.dark.paper),
        const SoloKeyMark(size: 64),
      ],
    );
  }
}

/// El icono a 128, 48, 32 y 16 sobre un fondo fijo (claro u oscuro), como en
/// un lanzador o la barra de tareas.
class _LogoGround extends StatelessWidget {
  const _LogoGround({required this.ground});

  final Color ground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ground,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: context.palette.rule),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final s in const [128.0, 48.0, 32.0, 16.0]) ...[
              SoloKeyAppIcon(size: s),
              if (s != 16) const SizedBox(width: AppSpace.lg),
            ],
          ],
        ),
      ),
    );
  }
}
