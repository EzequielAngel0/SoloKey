import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/secure_text_field.dart';
import '../../../../theme/app_palette.dart';
import '../../../../theme/app_theme.dart';
import 'form_section.dart';

/// The SSH-key type section of the credential form: key-type dropdown, an
/// Ed25519 generator button, and the private/public/passphrase fields.
/// Extracted from `credential_form_screen.dart` to keep it lean.
class SshKeyFieldsSection extends StatelessWidget {
  const SshKeyFieldsSection({
    super.key,
    required this.keyType,
    required this.onKeyTypeChanged,
    required this.isGenerating,
    required this.onGenerate,
    required this.privateKeyCtrl,
    required this.publicKeyCtrl,
    required this.passphraseCtrl,
    required this.privateKeyValidator,
  });

  final String keyType;
  final ValueChanged<String> onKeyTypeChanged;
  final bool isGenerating;
  final VoidCallback onGenerate;
  final TextEditingController privateKeyCtrl;
  final TextEditingController publicKeyCtrl;
  final TextEditingController passphraseCtrl;
  final FormFieldValidator<String> privateKeyValidator;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final ssh = palette.typeSshKey;
    final mono = TextStyle(
      color: palette.textPrimary,
      fontFamily: AppTheme.monoFamily,
      fontSize: 13,
    );

    return FormSection(
      icon: Icons.terminal_rounded,
      accentColor: ssh,
      title: l10n.formSectionSsh,
      children: [
        DropdownButtonFormField<String>(
          initialValue: keyType,
          style: TextStyle(color: palette.textPrimary),
          dropdownColor: palette.drawer,
          decoration: InputDecoration(
            labelText: l10n.fieldKeyType,
            prefixIcon: Icon(
              Icons.vpn_key_outlined,
              size: 18,
              color: palette.textMuted,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'Ed25519', child: Text('Ed25519')),
            DropdownMenuItem(value: 'RSA', child: Text('RSA')),
            DropdownMenuItem(value: 'ECDSA', child: Text('ECDSA')),
          ],
          onChanged: (val) {
            if (val != null) onKeyTypeChanged(val);
          },
        ),
        if (keyType == 'Ed25519') ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: isGenerating
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(
                        color: ssh,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: onGenerate,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: Text(l10n.formGenerateSsh),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ssh,
                      side: BorderSide(color: ssh, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
          ),
        ],
        const SizedBox(height: 14),
        TextFormField(
          controller: privateKeyCtrl,
          style: mono,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: l10n.fieldPrivateKey,
            hintText: '-----BEGIN OPENSSH PRIVATE KEY-----\n...',
            alignLabelWithHint: true,
            prefixIcon: Icon(
              Icons.security_rounded,
              size: 18,
              color: palette.textMuted,
            ),
          ),
          validator: privateKeyValidator,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: publicKeyCtrl,
          style: mono,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: l10n.formPublicKeyOptional,
            hintText: 'ssh-ed25519 AAAA...',
            alignLabelWithHint: true,
            prefixIcon: Icon(
              Icons.public_rounded,
              size: 18,
              color: palette.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SecureTextField(
          controller: passphraseCtrl,
          label: l10n.formKeyPassphraseOptional,
        ),
      ],
    );
  }
}
