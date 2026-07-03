import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/folders/application/folders_provider.dart';
import 'package:password_manager/features/folders/presentation/folder_actions.dart';
import 'package:password_manager/l10n/app_localizations.dart';

import '../../support/fake_folder_repository.dart';
import '../../support/widget_harness.dart';

class _CreateHost extends ConsumerWidget {
  const _CreateHost();
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => promptCreateFolder(context, ref),
            child: const Text('new'),
          ),
        ),
      );
}

void main() {
  testWidgets('creating a folder persists the chosen name and color',
      (tester) async {
    final repo = FakeFolderRepository([]);
    await pumpApp(
      tester,
      const _CreateHost(),
      overrides: [folderRepositoryProvider.overrideWithValue(repo)],
    );

    await tester.tap(find.text('new'));
    await tester.pumpAndSettle();

    // The editor exposes a color section with swatches.
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.folderColorTitle.toUpperCase()), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Work');
    // Pick the second preset (blue) rather than the default indigo.
    const chosen = '#3B82F6';
    await tester.tap(find.byKey(const ValueKey('folder-color-$chosen')));
    await tester.pump();
    await tester.tap(find.text(l10n.commonCreate));
    await tester.pumpAndSettle();

    expect(repo.folders.single.name, 'Work');
    expect(repo.folders.single.colorHex, chosen);
  });
}
