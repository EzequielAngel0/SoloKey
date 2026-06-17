import 'package:flutter/material.dart';
import '../../../../shared/widgets/staggered_list_item.dart';
import '../../domain/entities/credential.dart';
import 'credential_card.dart';

class CredentialListWidget extends StatelessWidget {
  const CredentialListWidget({
    super.key,
    required this.credentials,
  });

  final List<Credential> credentials;

  @override
  Widget build(BuildContext context) {
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
