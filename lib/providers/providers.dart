import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../models/app_user.dart';
import '../repositories/member_repository.dart';
import '../repositories/contribution_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/meeting_repository.dart';
import '../repositories/user_repository.dart';

// ── Database ──────────────────────────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

// ── Repositories ──────────────────────────────────────────────────────────────

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(ref.watch(appDatabaseProvider));
});

final contributionRepositoryProvider =
    Provider<ContributionRepository>((ref) {
  return ContributionRepository(ref.watch(appDatabaseProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(appDatabaseProvider));
});

final meetingRepositoryProvider = Provider<MeetingRepository>((ref) {
  return MeetingRepository(ref.watch(appDatabaseProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(appDatabaseProvider));
});

// ── Auth / Session ─────────────────────────────────────────────────────────

/// The currently logged-in user. Null means not logged in.
final currentUserProvider = StateProvider<AppUser?>((ref) => null);

// ── Theme ─────────────────────────────────────────────────────────────────────

/// Tracks whether dark mode is enabled
final isDarkModeProvider = StateProvider<bool>((ref) => false);
