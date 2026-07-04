import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/secure_text_field.dart';
import '../../../../theme/app_palette.dart';
import 'form_section.dart';

/// The 2FA/TOTP type section of the credential form: an info banner, a "scan
/// QR" affordance, a "paste otpauth link" action, and the manual issuer/secret
/// fields. Extracted from `credential_form_screen.dart` to keep it lean.
class TotpFieldsSection extends StatelessWidget {
  const TotpFieldsSection({
    super.key,
    required this.issuerCtrl,
    required this.secretCtrl,
    required this.onScan,
    required this.onPaste,
    required this.secretValidator,
    this.isDesktopScan = false,
  });

  final TextEditingController issuerCtrl;
  final TextEditingController secretCtrl;
  final VoidCallback onScan;
  final VoidCallback onPaste;
  final FormFieldValidator<String> secretValidator;

  /// When true (desktop), the scan button captures a screen region instead of
  /// opening the camera scanner.
  final bool isDesktopScan;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final totp = palette.typeTotp;

    return FormSection(
      icon: Icons.access_time_rounded,
      accentColor: totp,
      title: l10n.formSection2fa,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: totp.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: totp.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: totp.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.formTotpDesc,
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Material(
          color: totp.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onScan,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: totp.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDesktopScan
                        ? Icons.crop_free_rounded
                        : Icons.qr_code_scanner_rounded,
                    color: totp,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isDesktopScan ? l10n.formScanQrScreen : l10n.formScanQr,
                    style: TextStyle(
                      color: totp,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: onPaste,
            icon: Icon(Icons.content_paste_rounded, size: 16, color: totp),
            label: Text(l10n.formPasteTotp),
            style: TextButton.styleFrom(foregroundColor: totp),
          ),
        ),

        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Divider(color: palette.divider.withValues(alpha: 0.5)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                l10n.formOrManually,
                style: TextStyle(color: palette.textDisabled, fontSize: 11),
              ),
            ),
            Expanded(
              child: Divider(color: palette.divider.withValues(alpha: 0.5)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: issuerCtrl,
          style: TextStyle(color: palette.textPrimary),
          decoration: InputDecoration(
            labelText: l10n.formAccountIssuerLabel,
            hintText: l10n.formAccountIssuerHint,
            prefixIcon: Icon(
              Icons.account_circle_outlined,
              size: 18,
              color: palette.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SecureTextField(
          controller: secretCtrl,
          label: l10n.formTotpSecretLabel,
          validator: secretValidator,
        ),
      ],
    );
  }
}
