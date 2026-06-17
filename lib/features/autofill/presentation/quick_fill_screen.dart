import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/clipboard_countdown.dart';
import '../../../theme/app_palette.dart';
import '../../credentials/application/credentials_provider.dart';
import '../../credentials/domain/entities/credential.dart';

/// Desktop "autofill" equivalent — a compact Quick-Fill overlay.
///
/// Desktop OSes have no system autofill framework, so SoloKey offers the
/// KeePass-style flow instead: a global hotkey (Ctrl+Shift+L) brings this
/// overlay to the front, the user picks a credential, and the username /
/// password are copied to the clipboard with the existing auto-clear timer
/// ([ClipboardService]) so they can be pasted into the target field.
///
/// The route is protected: if the vault is locked the router guard redirects to
/// `/unlock` before this screen is shown.
class QuickFillScreen extends ConsumerStatefulWidget {
  const QuickFillScreen({super.key});

  @override
  ConsumerState<QuickFillScreen> createState() => _QuickFillScreenState();
}

class _QuickFillScreenState extends ConsumerState<QuickFillScreen> {
  final _searchCtrl = TextEditingController();
  final _focus = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Grab the keyboard immediately so the user can type right after the hotkey.
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<Credential> _filter(List<Credential> all) {
    final q = _query.toLowerCase().trim();
    if (q.isEmpty) return all;
    return all
        .where((c) =>
            c.title.toLowerCase().contains(q) ||
            (c.username?.toLowerCase().contains(q) ?? false) ||
            (c.website?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  Future<void> _copy(String label, String value) async {
    if (value.isEmpty) return;
    await showClipboardCountdownSnackBar(
      context: context,
      label: label,
      value: value,
    );
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final credentialsAsync = ref.watch(credentialsNotifierProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: palette.textMuted),
          tooltip: 'Cerrar (Esc)',
          onPressed: _close,
        ),
        title: Row(
          children: [
            Icon(Icons.bolt_rounded, color: palette.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              'Autocompletado rápido',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _searchCtrl,
              focusNode: _focus,
              autofocus: true,
              onSubmitted: (_) {
                // Enter copies the password of the first match for speed.
                final list = _filter(
                  credentialsAsync.asData?.value ?? const [],
                );
                if (list.isNotEmpty) {
                  _copy('Contraseña', list.first.password ?? '');
                }
              },
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar credencial…',
                hintStyle: TextStyle(color: palette.textMuted),
                prefixIcon: Icon(Icons.search_rounded, color: palette.textMuted),
                filled: true,
                fillColor: palette.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: credentialsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'No se pudieron cargar las credenciales',
                  style: TextStyle(color: palette.textMuted),
                ),
              ),
              data: (all) {
                final list = _filter(all);
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'Sin coincidencias',
                      style: TextStyle(color: palette.textMuted),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _QuickFillTile(
                    credential: list[i],
                    onCopyUser: () =>
                        _copy('Usuario', list[i].username ?? ''),
                    onCopyPassword: () =>
                        _copy('Contraseña', list[i].password ?? ''),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Copia el dato y pégalo (Ctrl+V) en el campo · se limpia solo del portapapeles',
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickFillTile extends StatelessWidget {
  const _QuickFillTile({
    required this.credential,
    required this.onCopyUser,
    required this.onCopyPassword,
  });

  final Credential credential;
  final VoidCallback onCopyUser;
  final VoidCallback onCopyPassword;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasUser = (credential.username ?? '').isNotEmpty;
    final hasPass = (credential.password ?? '').isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: palette.accent.withValues(alpha: 0.15),
            child: Icon(Icons.key_rounded, color: palette.accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  credential.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasUser)
                  Text(
                    credential.username!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.textMuted, fontSize: 12),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, size: 20),
            color: palette.textMuted,
            tooltip: 'Copiar usuario',
            onPressed: hasUser ? onCopyUser : null,
          ),
          IconButton(
            icon: const Icon(Icons.key_outlined, size: 20),
            color: palette.accent,
            tooltip: 'Copiar contraseña',
            onPressed: hasPass ? onCopyPassword : null,
          ),
        ],
      ),
    );
  }
}
