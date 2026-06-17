import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/vault_app_bar.dart';
import '../../../theme/app_palette.dart';
import '../../credentials/application/credentials_provider.dart';
import '../../credentials/domain/entities/credential.dart';
import '../../../core/utils/auth_helper.dart';

/// PasskeysScreen — Fase 12
///
/// Lists all stored Passkeys and allows:
///   - Viewing a passkey's metadata (rpId, credentialId, etc.)
///   - Deleting a passkey from the vault
///   - (Future) Triggering platform FIDO2 assertion via PasskeyService
class PasskeysScreen extends ConsumerWidget {
  const PasskeysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final credsAsync = ref.watch(credentialsNotifierProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: const VaultAppBar(title: 'Respaldos de Passkey'),
      body: credsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: palette.typePasskey),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e', style: TextStyle(color: palette.error)),
        ),
        data: (creds) {
          final passkeys = creds
              .where((c) => c.type == CredentialType.passkey)
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          if (passkeys.isEmpty) {
            return _EmptyPasskeysView();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: passkeys.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) =>
                _PasskeyCard(credential: passkeys[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPasskeyInfo(context),
        backgroundColor: palette.typePasskey,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Añadir Passkey'),
      ),
    );
  }

  void _showAddPasskeyInfo(BuildContext context) {
    final palette = context.palette;
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.drawer,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            28,
            28,
            28,
            28 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Icon(Icons.fingerprint_rounded,
                  size: 56, color: palette.typePasskey),
              const SizedBox(height: 16),
              Text(
                '¿Cómo registrar una Passkey?',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Las Passkeys se registran directamente en cada servicio web '
                '(ej. Google, GitHub, Apple). \n\n'
                '1. Ve al sitio web del servicio\n'
                '2. Busca "Passkeys" o "Llaves de acceso" en Seguridad\n'
                '3. El sistema registrará y sincronizará la passkey automáticamente\n\n'
                'SoloKey almacenará la información de la passkey en tu bóveda '
                'de forma cifrada para que puedas gestionarla.',
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 13,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.typePasskey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyPasskeysView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: palette.typePasskey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: palette.typePasskey.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.fingerprint_rounded,
                size: 56,
                color: palette.typePasskey,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Sin respaldos de passkey',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Las Passkeys son el futuro de la autenticación: '
              'sin contraseñas, más seguras y más rápidas. '
              'Regístralas en tus servicios favoritos y '
              'SoloKey guardará aquí un respaldo cifrado.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            // Backup storage badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded,
                      color: palette.typePasskey, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Respaldo cifrado en tu bóveda',
                    style: TextStyle(
                      color: palette.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Passkey Card ──────────────────────────────────────────────────────────────

class _PasskeyCard extends ConsumerWidget {
  const _PasskeyCard({required this.credential});
  final Credential credential;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final meta = credential.passkeyMetadata;
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.divider),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: palette.typePasskey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: palette.typePasskey.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(Icons.fingerprint_rounded,
              color: palette.typePasskey, size: 24),
        ),
        title: Text(
          credential.title,
          style: TextStyle(
              color: palette.textPrimary, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (meta != null) ...[
              const SizedBox(height: 4),
              Text(
                meta.rpId,
                style: TextStyle(
                    color: palette.textMuted, fontSize: 12),
              ),
              if (meta.userDisplayName != null)
                Text(
                  meta.userDisplayName!,
                  style: TextStyle(
                      color: palette.textDisabled, fontSize: 11),
                ),
            ],
            const SizedBox(height: 4),
            Text(
              'Actualizado: ${_formatDate(credential.updatedAt)}',
              style: TextStyle(
                  color: palette.textDisabled, fontSize: 10),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded,
              color: palette.textMuted),
          color: palette.drawer,
          onSelected: (action) => _handleAction(context, ref, action),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'details',
              child: ListTile(
                leading: Icon(Icons.info_outline_rounded,
                    color: palette.textMuted, size: 20),
                title: Text('Ver detalles',
                    style: TextStyle(color: palette.textPrimary, fontSize: 13)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline_rounded,
                    color: palette.danger, size: 20),
                title: Text('Eliminar',
                    style: TextStyle(
                        color: palette.danger, fontSize: 13)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _showDetails(context),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    if (action == 'details') {
      _showDetails(context);
    } else if (action == 'delete') {
      _confirmDelete(context, ref);
    }
  }

  void _showDetails(BuildContext context) {
    final palette = context.palette;
    final meta = credential.passkeyMetadata;
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.drawer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              credential.title,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (meta != null) ...[
              _DetailRow(
                  icon: Icons.language_rounded,
                  label: 'Dominio (RP ID)',
                  value: meta.rpId),
              if (meta.rpName != null)
                _DetailRow(
                    icon: Icons.business_rounded,
                    label: 'Servicio',
                    value: meta.rpName!),
              if (meta.userDisplayName != null)
                _DetailRow(
                    icon: Icons.person_rounded,
                    label: 'Usuario',
                    value: meta.userDisplayName!),
              _DetailRow(
                icon: Icons.verified_user_rounded,
                label: 'Verificación',
                value: meta.userVerificationRequired
                    ? 'Requerida (Biométrico / PIN)'
                    : 'Opcional',
              ),
              _DetailRow(
                icon: Icons.tag_rounded,
                label: 'Credential ID',
                value:
                    '${meta.credentialId.substring(0, meta.credentialId.length.clamp(0, 20))}…',
              ),
            ],
            _DetailRow(
              icon: Icons.calendar_today_rounded,
              label: 'Registrada',
              value: _formatDate(credential.createdAt),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.typePasskey.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: palette.typePasskey.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_rounded,
                      color: palette.typePasskey, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La clave privada nunca sale del dispositivo. '
                      'Solo la información de identificación está almacenada.',
                      style: TextStyle(
                          color: palette.typePasskey, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.drawer,
        title: Text('Eliminar Passkey',
            style: TextStyle(color: palette.textPrimary)),
        content: Text(
          '¿Eliminar la passkey "${credential.title}"?\n\n'
          'Nota: también deberás eliminarla del servicio web correspondiente '
          '(${credential.passkeyMetadata?.rpId ?? credential.website ?? "el sitio"}).',
          style: TextStyle(color: palette.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final auth = await AuthHelper.requireAuth(context, reason: 'Verifica para eliminar esta passkey');
              if (!auth) return;

              if (context.mounted) {
                Navigator.pop(context);
              }

              ref
                  .read(credentialsNotifierProvider.notifier)
                  .delete(credential.id);
            },
            style: TextButton.styleFrom(
                foregroundColor: palette.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

// ── Detail Row ────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: palette.textMuted),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: palette.textDisabled, fontSize: 10)),
              Text(value,
                  style: TextStyle(
                      color: palette.textPrimary, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
