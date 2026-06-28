import 'package:flutter/material.dart';
import '../../../../shared/widgets/staggered_list_item.dart';
import '../../domain/entities/credential.dart';
import 'credential_card.dart';

class CredentialListWidget extends StatelessWidget {
  const CredentialListWidget({
    super.key,
    required this.credentials,
    this.onReorder,
  });

  final List<Credential> credentials;

  /// When provided, the list becomes drag-reorderable (long-press to drag) and
  /// reports the new order via this callback. [newIndex] is the final index
  /// after removal (onReorderItem semantics — no manual ±1 adjustment needed).
  /// When null, it's a static list.
  final void Function(int oldIndex, int newIndex)? onReorder;

  @override
  Widget build(BuildContext context) {
    if (onReorder != null) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: credentials.length,
        onReorderItem: onReorder!,
        itemBuilder: (context, i) => Padding(
          key: ValueKey(credentials[i].id),
          padding: const EdgeInsets.only(bottom: 10),
          child: CredentialCard(credential: credentials[i]),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: credentials.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => StaggeredListItem(
        index: i,
        child: CredentialCard(credential: credentials[i]),
      ),
    );
  }
}
