import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/providers.dart';
import '../../providers/members_provider.dart';
import '../../providers/contributions_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/meetings_provider.dart';
import '../../widgets/animated_stat_card.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/water_wave_header.dart';
import '../../core/constants/app_constants.dart' as constants;

/// Main dashboard screen showing financial summary, charts, and recent activity.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.offWhite,
      body: RefreshIndicator(
        color: AppColors.teal,
        onRefresh: () async {
          // Invalidate all providers to force refresh
          ref.invalidate(membersProvider);
          ref.invalidate(contributionsProvider);
          ref.invalidate(expensesProvider);
          ref.invalidate(meetingsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── Gradient Header ──────────────────────────────────────────────
            _buildHeader(context, ref),
            // ── Stat Cards ───────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildStatCards(context, ref)),
            // ── Monthly Chart ────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildChart(context, ref)),
            // ── Arrears section ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildArrearsSection(context, ref)),
            // ── Recent Expenses ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildRecentExpenses(context, ref)),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final memberCount = ref.watch(memberCountProvider);
    final currentMonth = AppFormatters.monthYear(DateTime.now());

    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 60,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(Icons.water_drop_rounded,
                              color: AppColors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tolera Dashboard',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ).animate().fadeIn(duration: 500.ms),
                              Text(
                                currentMonth,
                                style: TextStyle(
                                  color: AppColors.white.withOpacity(0.75),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Member count pill
                        memberCount.when(
                          data: (count) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '$count Members',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Balance highlight
                    _buildBalanceHighlight(context, ref),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceHighlight(BuildContext context, WidgetRef ref) {
    final totalIn = ref.watch(totalContributionsProvider);
    final totalOut = ref.watch(totalExpensesProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Balance',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                totalIn.when(
                  data: (income) => totalOut.when(
                    data: (expense) {
                      final balance = income - expense;
                      return Text(
                        AppFormatters.currency(balance),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ).animate().fadeIn(duration: 700.ms);
                    },
                    loading: () => const _LoadingText(),
                    error: (_, __) => const Text('—',
                        style: TextStyle(color: AppColors.white)),
                  ),
                  loading: () => const _LoadingText(),
                  error: (_, __) =>
                      const Text('—', style: TextStyle(color: AppColors.white)),
                ),
              ],
            ),
          ),
          // In/Out pills
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniStatRow(
                icon: Icons.arrow_downward_rounded,
                label: 'In',
                valueAsync: totalIn,
                color: AppColors.greenLight,
              ),
              const SizedBox(height: 4),
              _MiniStatRow(
                icon: Icons.arrow_upward_rounded,
                label: 'Out',
                valueAsync: totalOut,
                color: const Color(0xFFFF6B6B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stat Cards ────────────────────────────────────────────────────────────

  Widget _buildStatCards(BuildContext context, WidgetRef ref) {
    final memberCount = ref.watch(memberCountProvider);
    final totalIn = ref.watch(totalContributionsProvider);
    final totalOut = ref.watch(totalExpensesProvider);
    final paidCount = ref.watch(currentMonthPaidCountProvider);
    final memberCountVal = memberCount.valueOrNull ?? 0;
    final paidCountVal = paidCount.valueOrNull ?? 0;
    final arrearsCount = memberCountVal - paidCountVal;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Month\'s Overview',
            style: Theme.of(context).textTheme.titleMedium,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              AnimatedStatCard(
                label: 'Total Contributions',
                value: totalIn.when(
                  data: (v) => AppFormatters.currency(v),
                  loading: () => '...',
                  error: (_, __) => '—',
                ),
                icon: Icons.savings_rounded,
                gradient: AppColors.cardGradientBlue,
                animationDelay: 0,
              ),
              AnimatedStatCard(
                label: 'Total Expenses',
                value: totalOut.when(
                  data: (v) => AppFormatters.currency(v),
                  loading: () => '...',
                  error: (_, __) => '—',
                ),
                icon: Icons.receipt_long_rounded,
                gradient: AppColors.cardGradientOrange,
                animationDelay: 100,
              ),
              AnimatedStatCard(
                label: 'Members Paid',
                value: paidCount.when(
                  data: (v) => '$v / $memberCountVal',
                  loading: () => '...',
                  error: (_, __) => '—',
                ),
                icon: Icons.check_circle_rounded,
                gradient: AppColors.cardGradientGreen,
                animationDelay: 200,
              ),
              AnimatedStatCard(
                label: 'Arrears',
                value: arrearsCount > 0 ? '$arrearsCount members' : 'None',
                icon: Icons.warning_amber_rounded,
                gradient: arrearsCount > 0
                    ? AppColors.cardGradientRed
                    : AppColors.cardGradientGreen,
                animationDelay: 300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Chart ─────────────────────────────────────────────────────────────────

  Widget _buildChart(BuildContext context, WidgetRef ref) {
    final monthlyTotals = ref.watch(monthlyTotalsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded,
                    color: AppColors.teal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Monthly Contributions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            monthlyTotals.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No data yet'),
                    ),
                  );
                }
                return SizedBox(
                  height: 160,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => AppColors.deepBlue,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final item = data[groupIndex];
                            return BarTooltipItem(
                              '${AppFormatters.formatMonthKey(item['monthKey'] as String)}\n',
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11),
                              children: [
                                TextSpan(
                                  text: AppFormatters.currency(
                                      item['total'] as double),
                                  style: const TextStyle(
                                    color: AppColors.aquaLight,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= data.length) {
                                return const SizedBox.shrink();
                              }
                              final parts =
                                  (data[index]['monthKey'] as String).split('-');
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  parts.length == 2
                                      ? constants.AppConstants.months[
                                              int.parse(parts[1]) - 1]
                                          .substring(0, 3)
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: data
                          .asMap()
                          .entries
                          .map(
                            (entry) => BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value['total'] as double,
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [AppColors.teal, AppColors.aqua],
                                  ),
                                  width: 24,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms);
              },
              loading: () => const SizedBox(
                height: 160,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.teal),
                ),
              ),
              error: (_, __) => const SizedBox(height: 80),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
    );
  }

  // ── Arrears ───────────────────────────────────────────────────────────────

  Widget _buildArrearsSection(BuildContext context, WidgetRef ref) {
    final paidIds = ref.watch(paidMemberIdsProvider);
    final members = ref.watch(activeMembersProvider);

    return paidIds.when(
      data: (paidList) => members.when(
        data: (allMembers) {
          final unpaid = allMembers
              .where((m) => !paidList.contains(m.id))
              .toList();
          if (unpaid.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Members with Arrears',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${unpaid.length}',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...unpaid.take(4).map(
                  (member) => _ArrearsTile(member: member),
                ),
                if (unpaid.length > 4)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${unpaid.length - 4} more members…',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ── Recent Expenses ───────────────────────────────────────────────────────

  Widget _buildRecentExpenses(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);

    return expenses.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        final recent = list.take(3).toList();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Expenses',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...recent.asMap().entries.map(
                    (e) => _ExpenseTile(
                      expense: e.value,
                      index: e.key,
                    ),
                  ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.all(16),
        child: LoadingSkeleton(itemCount: 3, itemHeight: 70),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _LoadingText extends StatelessWidget {
  const _LoadingText();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _MiniStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final AsyncValue<double> valueAsync;
  final Color color;

  const _MiniStatRow({
    required this.icon,
    required this.label,
    required this.valueAsync,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 6),
        valueAsync.when(
          data: (v) => Text(
            AppFormatters.currency(v),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          loading: () => const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          error: (_, __) => const Text('—',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _ArrearsTile extends StatelessWidget {
  final dynamic member;

  const _ArrearsTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final initials = AppFormatters.initials(member.fullName as String);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.error.withOpacity(0.2),
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              member.fullName as String,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              AppFormatters.currency(2000),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _ExpenseTile extends StatelessWidget {
  final dynamic expense;
  final int index;

  const _ExpenseTile({required this.expense, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.cardGradientOrange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: AppColors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title as String,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  expense.category as String,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.currency(expense.amount as double),
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              _statusBadge(expense.status as String),
            ],
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 60 * index)).fadeIn();
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'approved':
        color = AppColors.success;
        break;
      case 'rejected':
        color = AppColors.error;
        break;
      default:
        color = AppColors.warning;
    }
    return Text(
      status[0].toUpperCase() + status.substring(1),
      style: TextStyle(
        fontSize: 10,
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
