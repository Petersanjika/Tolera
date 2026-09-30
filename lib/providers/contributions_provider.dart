import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contribution.dart';
import '../core/utils/formatters.dart';
import 'providers.dart';

// ── All contributions ─────────────────────────────────────────────────────────

final contributionsProvider = FutureProvider<List<Contribution>>((ref) async {
  final repo = ref.watch(contributionRepositoryProvider);
  return repo.getAllContributions();
});

final contributionsByMemberProvider =
    FutureProvider.family<List<Contribution>, int>((ref, memberId) async {
  final repo = ref.watch(contributionRepositoryProvider);
  return repo.getContributionsByMember(memberId);
});

// ── Current month stats ───────────────────────────────────────────────────────

final currentMonthKeyProvider = Provider<String>((ref) {
  return AppFormatters.currentMonthKey();
});

final currentMonthPaidCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(contributionRepositoryProvider);
  final monthKey = ref.watch(currentMonthKeyProvider);
  final ids = await repo.getPaidMemberIdsForMonth(monthKey);
  return ids.length;
});

final currentMonthTotalProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(contributionRepositoryProvider);
  final monthKey = ref.watch(currentMonthKeyProvider);
  return repo.getTotalContributionsForMonth(monthKey);
});

final totalContributionsProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(contributionRepositoryProvider);
  return repo.getTotalContributions();
});

final monthlyTotalsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(contributionRepositoryProvider);
  return repo.getMonthlyTotals(months: 6);
});

/// IDs of members who paid this month
final paidMemberIdsProvider = FutureProvider<List<int>>((ref) async {
  final repo = ref.watch(contributionRepositoryProvider);
  final monthKey = ref.watch(currentMonthKeyProvider);
  return repo.getPaidMemberIdsForMonth(monthKey);
});
