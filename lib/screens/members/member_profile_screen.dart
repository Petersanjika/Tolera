import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/members_provider.dart';
import '../../providers/contributions_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/transaction_card.dart';
import 'member_form_screen.dart';

/// Full profile screen for a single member.
class MemberProfileScreen extends ConsumerWidget {
  final int memberId;

  const MemberProfileScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberByIdProvider(memberId));
    final contribAsync = ref.watch(contributionsByMemberProvider(memberId));
    final paidIds = ref.watch(paidMemberIdsProvider).valueOrNull ?? [];

    return Scaffold(
      body: memberAsync.when(
        data: (member) {
          if (member == null) {
            return const Center(child: Text('Member not found'));
          }
          return CustomScrollView(
            slivers: [
              // ── Profile Header ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildProfileHeader(context, ref, member, paidIds),
              ),
              // ── Info Cards ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildInfoSection(context, member),
              ),
              // ── Contribution History ─────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildContributionHistory(context, contribAsync),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.teal)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    dynamic member,
    List<int> paidIds,
  ) {
    final hasPaid = paidIds.contains(member.id as int);
    final initials = AppFormatters.initials(member.fullName as String);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Back + actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        color: AppColors.white, size: 20),
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemberFormScreen(member: member),
                        ),
                      );
                      if (result == true) {
                        ref.invalidate(memberByIdProvider(memberId));
                        ref.invalidate(membersProvider);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.white, size: 20),
                    onPressed: () => _confirmDelete(context, ref, member),
                  ),
                ],
              ),
            ),
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.5), width: 3),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ).animate().scaleXY(begin: 0.6, end: 1.0, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            Text(
              member.fullName as String,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${member.houseNumber}  •  ${member.village}',
              style: TextStyle(
                color: AppColors.white.withOpacity(0.75),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            // Payment badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: hasPaid
                    ? AppColors.greenLight.withOpacity(0.25)
                    : AppColors.error.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hasPaid
                      ? AppColors.greenLight.withOpacity(0.5)
                      : AppColors.error.withOpacity(0.4),
                ),
              ),
              child: Text(
                hasPaid ? '✓  Paid This Month' : '✗  Unpaid This Month',
                style: TextStyle(
                  color: hasPaid ? AppColors.greenLight : const Color(0xFFFF6B6B),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, dynamic member) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Member Details', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.phone_rounded,
                  label: 'Phone',
                  value: AppFormatters.maskPhone(member.phone as String),
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.wc_rounded,
                  label: 'Gender',
                  value: member.gender as String,
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.people_rounded,
                  label: 'Household',
                  value: '${member.householdSize} people',
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Joined',
                  value: AppFormatters.date(member.joinDate as DateTime),
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.circle,
                  label: 'Status',
                  value: (member.status as String).toUpperCase(),
                  valueColor: (member.status as String) == 'active'
                      ? AppColors.success
                      : AppColors.textHint,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionHistory(
      BuildContext context, AsyncValue<dynamic> contribAsync) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment History', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          contribAsync.when(
            data: (contributions) {
              if ((contributions as List).isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No payments recorded yet.',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  ),
                );
              }
              return Column(
                children: (contributions as List).asMap().entries.map((e) {
                  final c = e.value;
                  return TransactionCard(
                    title: 'Monthly Contribution',
                    subtitle:
                        '${AppFormatters.formatMonthKey(c.monthKey as String)} • ${c.paymentMethod}',
                    amount: c.amount as double,
                    isExpense: false,
                    icon: Icons.payments_rounded,
                    date: c.createdAt as DateTime,
                    animationIndex: e.key,
                    badge: c.receiptNumber as String,
                    badgeColor: AppColors.teal,
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            ),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, dynamic member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text(
            'Are you sure you want to remove ${member.fullName} from the system?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final repo = ref.read(memberRepositoryProvider);
      await repo.deleteMember(member.id as int);
      ref.invalidate(membersProvider);
      ref.invalidate(memberCountProvider);
      if (context.mounted) Navigator.pop(context, true);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.teal, size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}
