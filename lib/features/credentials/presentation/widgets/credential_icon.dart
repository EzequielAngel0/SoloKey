import 'package:flutter/material.dart';
import '../../domain/entities/credential.dart';

/// Type avatar for a credential: a rounded, accent-tinted square with the
/// type icon.
///
/// Privacy/offline note: this widget NO LONGER fetches remote favicons by
/// default. The previous implementation hit
/// `google.com/s2/favicons` for every credential with a website, which leaked
/// the user's vault domains to Google and broke the list offline. Remote
/// favicons are now strictly opt-in via [showFavicon] (default `false`) and are
/// still fetched lazily with a graceful fallback to the type avatar.
class CredentialIcon extends StatelessWidget {
  const CredentialIcon({
    super.key,
    required this.credential,
    required this.defaultIcon,
    required this.color,
    this.size = 44,
    this.showFavicon = false,
  });

  final Credential credential;
  final IconData defaultIcon;
  final Color color;
  final double size;

  /// When true (opt-in), tries to load the site favicon over the network and
  /// falls back to the type avatar on any error. Defaults to `false` so the
  /// vault never phones home and always renders offline.
  final bool showFavicon;

  @override
  Widget build(BuildContext context) {
    if (showFavicon) {
      final domain = _getDomain(credential.website);
      if (domain != null) {
        final faviconUrl =
            'https://www.google.com/s2/favicons?sz=64&domain=$domain';
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            faviconUrl,
            fit: BoxFit.contain,
            width: size,
            height: size,
            errorBuilder: (_, _, _) => _buildDefault(),
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : _buildDefault(),
          ),
        );
      }
    }
    return _buildDefault();
  }

  Widget _buildDefault() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(defaultIcon, color: color, size: size * 0.48),
    );
  }

  String? _getDomain(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      if (host.isNotEmpty) {
        return host.replaceFirst(RegExp(r'^www\.'), '');
      }
    } catch (_) {}

    final match = RegExp(r'(?:https?://)?(?:www\.)?([^/]+)').firstMatch(url);
    return match?.group(1);
  }
}
