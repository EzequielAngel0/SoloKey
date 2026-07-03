import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/credential.dart';

/// Pill filters shown on the Vault destination. Favorites is a filter chip
/// instead of a whole navigation tab.
enum VaultFilter { all, favorites, password, totp, passkey, ssh }

/// User-selectable ordering for the Vault list. [manual] respects the drag
/// order (`sortOrder`); the others are computed. Only [manual] allows drag
/// reordering (reordering a computed order makes no sense).
enum VaultSort { manual, titleAsc, updatedDesc }

/// True when [c] belongs to filter [f]. Pure so it can be unit-tested and reused
/// by mobile and desktop without duplicating the switch.
bool matchesVaultFilter(Credential c, VaultFilter f) => switch (f) {
      VaultFilter.all => true,
      VaultFilter.favorites => c.isFavorite,
      VaultFilter.password => c.type == CredentialType.password,
      VaultFilter.totp => c.type == CredentialType.totp,
      VaultFilter.passkey => c.type == CredentialType.passkey,
      VaultFilter.ssh => c.type == CredentialType.sshKey,
    };

/// Returns a NEW list ordered per [sort]. Never mutates [credentials]. [manual]
/// keeps the persisted drag order (`sortOrder` asc, tie-break by title) so the
/// result is deterministic even when several rows share a sortOrder.
List<Credential> sortCredentials(List<Credential> credentials, VaultSort sort) {
  final out = List<Credential>.of(credentials);
  switch (sort) {
    case VaultSort.manual:
      out.sort((a, b) {
        final c = a.sortOrder.compareTo(b.sortOrder);
        return c != 0 ? c : a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
    case VaultSort.titleAsc:
      out.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    case VaultSort.updatedDesc:
      out.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
  return out;
}

/// Selected Vault list ordering. Session-scoped (survives navigation across the
/// app); resets on a cold start. Shared by mobile and desktop so both stay in
/// sync. Kept as a plain [NotifierProvider] (no codegen) to match
/// `credentialHealthProvider` and avoid a build_runner round-trip.
final vaultSortProvider =
    NotifierProvider<VaultSortNotifier, VaultSort>(VaultSortNotifier.new);

class VaultSortNotifier extends Notifier<VaultSort> {
  @override
  VaultSort build() => VaultSort.manual;

  void set(VaultSort sort) => state = sort;
}

/// Selected Vault filter chip. Session-scoped like [vaultSortProvider] so the
/// last chip is remembered while navigating away and back.
final vaultFilterProvider =
    NotifierProvider<VaultFilterNotifier, VaultFilter>(VaultFilterNotifier.new);

class VaultFilterNotifier extends Notifier<VaultFilter> {
  @override
  VaultFilter build() => VaultFilter.all;

  void set(VaultFilter filter) => state = filter;
}

/// Whether the Vault list is in drag-to-reorder mode. Off by default so the
/// drag handle (`≡`) does not clutter the list; the user toggles it on to
/// rearrange, then off to browse. Only meaningful when [VaultSort.manual] is
/// active with no filter/search.
final vaultReorderModeProvider =
    NotifierProvider<VaultReorderModeNotifier, bool>(VaultReorderModeNotifier.new);

class VaultReorderModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) {
    if (state != value) state = value;
  }
}

/// Icon for a [VaultSort] used in the sort menu.
IconData vaultSortIcon(VaultSort sort) => switch (sort) {
      VaultSort.manual => Icons.drag_indicator_rounded,
      VaultSort.titleAsc => Icons.sort_by_alpha_rounded,
      VaultSort.updatedDesc => Icons.schedule_rounded,
    };
