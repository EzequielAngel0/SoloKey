import 'package:flutter/material.dart';
import '../../domain/entities/credential.dart';

class CredentialIcon extends StatelessWidget {
  const CredentialIcon({
    super.key,
    required this.credential,
    required this.defaultIcon,
    required this.color,
  });

  final Credential credential;
  final IconData defaultIcon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final website = credential.website;
    if (website != null && website.isNotEmpty) {
      final domain = _getDomain(website);
      if (domain != null) {
        final faviconUrl = 'https://www.google.com/s2/favicons?sz=64&domain=$domain';
        return Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            faviconUrl,
            fit: BoxFit.contain,
            width: 46,
            height: 46,
            errorBuilder: (_, __, ___) => _buildDefault(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildDefault();
            },
          ),
        );
      }
    }
    return _buildDefault();
  }

  Widget _buildDefault() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(defaultIcon, color: color, size: 22),
    );
  }

  String? _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      if (host.isNotEmpty) {
        return host.replaceFirst(RegExp(r'^www\.'), '');
      }
    } catch (_) {}

    final match = RegExp(r'(?:https?://)?(?:www\.)?([^/]+)').firstMatch(url);
    if (match != null) {
      return match.group(1);
    }
    return null;
  }
}
