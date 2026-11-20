import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/injection.dart';
import '../../../l10n/app_localizations.dart';
import '../../../router/app_router.dart';
import '../../../core/infrastructure/vault/vault_store.dart';
import '../../../shared/widgets/kit/kit.dart';

/// Arranque: la marca quieta mientras se averigua si ya hay bóveda, y de ahí al
/// primer uso o al desbloqueo. Sin esperas de adorno ni animación (ADR-0013).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final initialized = await getIt<VaultStore>().exists();
    if (!mounted) return;
    context.go(initialized ? AppRoutes.unlock : AppRoutes.setup);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SoloKeyMark(size: 96),
            const SizedBox(height: AppSpace.xl),
            Semantics(
              header: true,
              child: Text('SoloKey', style: t.displaySmall),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              AppLocalizations.of(context).splashTagline,
              style: t.bodyLarge?.copyWith(color: p.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
