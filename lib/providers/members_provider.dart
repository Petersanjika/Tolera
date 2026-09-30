import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/member.dart';
import 'providers.dart';

// ── Members list ──────────────────────────────────────────────────────────────

final membersProvider = FutureProvider<List<Member>>((ref) async {
  final repo = ref.watch(memberRepositoryProvider);
  return repo.getAllMembers();
});

final activeMembersProvider = FutureProvider<List<Member>>((ref) async {
  final repo = ref.watch(memberRepositoryProvider);
  return repo.getActiveMembers();
});

final memberSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredMembersProvider = FutureProvider<List<Member>>((ref) async {
  final query = ref.watch(memberSearchQueryProvider);
  final repo = ref.watch(memberRepositoryProvider);
  if (query.isEmpty) return repo.getAllMembers();
  return repo.searchMembers(query);
});

final memberCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(memberRepositoryProvider);
  return repo.getMemberCount();
});

// ── Single member ─────────────────────────────────────────────────────────────

final memberByIdProvider =
    FutureProvider.family<Member?, int>((ref, id) async {
  final repo = ref.watch(memberRepositoryProvider);
  return repo.getMemberById(id);
});
