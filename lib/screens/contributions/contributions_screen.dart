import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/contributions_provider.dart';
import '../../providers/members_provider.dart';
import '../../widgets/transaction_card.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/empty_state_widget.dart';
import 'add_contribution_screen.dart';

/// Contributions screen – shows all payment records with summary.
class ContributionsScreen extends ConsumerWidget {
  const ContributionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributions = ref.watch(contributionsProvider);
    final totalIn = ref.watch(totalContributionsProvider);
    final currentMonthTotal = ref.watch(currentMonthTotalProvider);
    final paidCount = ref.watch(currentMonthPaidCountProvider);
    final memberCount = ref.watch(memberCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _buildHeader(context, totalIn, currentMonthTotal, paidCount,
              memberCount, isDark),
          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.teal,
              onRefresh: () async {
                ref.invalidate(contributionsProvider);
              },
              child: contributions.when(
                data: (list) {
                  if (list.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.payments_outlined,
                      title: 'No Contributions Yet',
                      subtitle:
                          'Start recording monthly payments from community members.',
                      actionLabel: 'Record Payment',
                      onAction: () => _navigateToAdd(context, ref),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final c = list[index];
                      return _ContributionItem(
                        contribution: c,
                        index: index,
                      );
                    },
                  );
                },
                loading: () => Padding(
                  padding: const EdgeInsets.all(16),
                  child: LoadingSkeleton(itemCount: 6),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _navigateToAdd(context, ref),
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Record Payment',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AsyncValue<double> totalIn,
    AsyncValue<double> currentMonthTotal,
    AsyncValue<int> paidCount,
    AsyncValue<int> memberCount,
    bool isDark,
  ) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.payments_rounded,
                      color: AppColors.white, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contributions',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        AppFormatters.monthYear(DateTime.now()),
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.75),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Summary row
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'All Time Total',
                      valueAsync: totalIn,
                      icon: Icons.savings_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      label: 'This Month',
                      valueAsync: currentMonthTotal,
                      icon: Icons.calendar_month_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MembersRatioCard(
                      paidCount: paidCount,
                      memberCount: memberCount,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAdd(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddContributionScreen()),
    );
    if (result == true) {
      ref.invalidate(contributionsProvider);
      ref.invalidate(currentMonthPaidCountProvider);
      ref.invalidate(currentMonthTotalProvider);
      ref.invalidate(totalContributionsProvider);
      ref.invalidate(paidMemberIdsProvider);
    }
  }
}

class _ContributionItem extends ConsumerWidget {
  final dynamic contribution;
  final int index;

  const _ContributionItem({required this.contribution, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Try to get member name from members list
    final membersAsync = ref.watch(activeMembersProvider);
    final memberName = membersAsync.valueOrNull
            ?.firstWhere(
              (m) => m.id == (contribution.memberId as int),
              orElse: () => throw Exception(),
            )
            .fullName ??
        'Member #${contribution.memberId}';

    return TransactionCard(
      title: memberName,
      subtitle:
          '${AppFormatters.formatMonthKey(contribution.monthKey as String)} • ${contribution.paymentMethod}',
      amount: contribution.amount as double,
      isExpense: false,
      icon: Icons.payments_rounded,
      date: contribution.createdAt as DateTime,
      animationIndex: index,
      badge: (contribution.receiptNumber as String).substring(0, 11),
      badgeColor: AppColors.teal,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final AsyncValue<double> valueAsync;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.valueAsync,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.aquaLight, size: 16),
          const SizedBox(height: 4),
          valueAsync.when(
            data: (v) => Text(
              AppFormatters.currency(v),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            loading: () => Container(
              height: 14,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            error: (_, __) =>
                const Text('—', style: TextStyle(color: AppColors.white)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.7),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MembersRatioCard extends StatelessWidget {
  final AsyncValue<int> paidCount;
  final AsyncValue<int> memberCount;

  const _MembersRatioCard(
      {required this.paidCount, required this.memberCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.people_rounded,
              color: AppColors.aquaLight, size: 16),
          const SizedBox(height: 4),
          Row(
            children: [
              paidCount.when(
                data: (p) => memberCount.when(
                  data: (m) => Text(
                    '$p/$m',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  loading: () =>
                      const Text('…', style: TextStyle(color: AppColors.white)),
                  error: (_, __) =>
                      const Text('—', style: TextStyle(color: AppColors.white)),
                ),
                loading: () =>
                    const Text('…', style: TextStyle(color: AppColors.white)),
                error: (_, __) =>
                    const Text('—', style: TextStyle(color: AppColors.white)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Paid This Month',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.7),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
