import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/empty_state_widget.dart';
import 'add_expense_screen.dart';

/// Expenses screen – lists all expense records with category filtering.
class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expensesProvider);
    final totalExpenses = ref.watch(totalExpensesProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, totalExpenses),
          _buildStatusFilter(context),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.teal,
              onRefresh: () async {
                ref.invalidate(expensesProvider);
                ref.invalidate(totalExpensesProvider);
              },
              child: expenses.when(
                data: (list) {
                  var filtered = list;
                  if (_statusFilter != 'All') {
                    filtered = list
                        .where((e) =>
                            e.status.toLowerCase() ==
                            _statusFilter.toLowerCase())
                        .toList();
                  }

                  if (filtered.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.receipt_long_outlined,
                      title: 'No Expenses Found',
                      subtitle: _statusFilter != 'All'
                          ? 'No $_statusFilter expenses recorded.'
                          : 'Record community water expenses to track spending.',
                      actionLabel: 'Add Expense',
                      onAction: () => _navigateToAdd(context),
                    );
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _ExpenseCard(expense: filtered[i], index: i),
                  );
                },
                loading: () => Padding(
                  padding: const EdgeInsets.all(16),
                  child: LoadingSkeleton(itemCount: 5),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _navigateToAdd(context),
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildHeader(
      BuildContext context, AsyncValue<double> totalExpenses) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.cardGradientOrange),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded,
                      color: AppColors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expenses',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Tracking all community spending',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Total badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                        totalExpenses.when(
                          data: (v) => Text(
                            AppFormatters.currency(v),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          loading: () => const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          error: (_, __) => const Text('—',
                              style: TextStyle(color: AppColors.white)),
                        ),
                      ],
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

  Widget _buildStatusFilter(BuildContext context) {
    final filters = ['All', 'Pending', 'Approved', 'Rejected'];
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.offWhite,
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          final isSelected = _statusFilter == f;
          Color chipColor;
          switch (f) {
            case 'Pending':
              chipColor = AppColors.warning;
              break;
            case 'Approved':
              chipColor = AppColors.success;
              break;
            case 'Rejected':
              chipColor = AppColors.error;
              break;
            default:
              chipColor = AppColors.deepBlue;
          }

          return FilterChip(
            label: Text(f),
            selected: isSelected,
            onSelected: (_) => setState(() => _statusFilter = f),
            selectedColor: chipColor.withOpacity(0.15),
            checkmarkColor: chipColor,
            labelStyle: TextStyle(
              color: isSelected ? chipColor : AppColors.textSecondary,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
            side: BorderSide(
              color: isSelected ? chipColor : AppColors.divider,
            ),
          );
        },
      ),
    );
  }

  void _navigateToAdd(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
    if (result == true) {
      ref.invalidate(expensesProvider);
      ref.invalidate(totalExpensesProvider);
    }
  }
}

/// Individual expense card with status indicator and approval actions.
class _ExpenseCard extends ConsumerWidget {
  final dynamic expense;
  final int index;

  const _ExpenseCard({required this.expense, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = expense.status as String;

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'approved':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.access_time_rounded;
    }

    return Animate(
      delay: Duration(milliseconds: 60 * index),
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 400)),
        SlideEffect(
          begin: Offset(0, 0.1),
          end: Offset.zero,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOut,
        ),
      ],
      child: Card(
        color: isDark ? AppColors.darkCard : AppColors.white,
        margin: const EdgeInsets.only(bottom: 10),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradientOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _categoryIcon(expense.category as String),
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title as String,
                          style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          expense.category as String,
                          style: theme.textTheme.bodySmall,
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
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            status[0].toUpperCase() + status.substring(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                expense.description as String,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    'Paid to: ${expense.paidTo}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint),
                  ),
                  const Spacer(),
                  Text(
                    AppFormatters.date(expense.createdAt as DateTime),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint),
                  ),
                ],
              ),
              // Approve/Reject buttons if pending
              if (status == 'pending') ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _updateStatus(context, ref, 'rejected'),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side:
                              const BorderSide(color: AppColors.error),
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _updateStatus(context, ref, 'approved'),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Pipe Repair':
        return Icons.plumbing_rounded;
      case 'Tap Repair':
        return Icons.water_rounded;
      case 'Fuel':
        return Icons.local_gas_station_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Maintenance':
        return Icons.build_rounded;
      case 'Salaries':
        return Icons.payments_rounded;
      case 'Electricity':
        return Icons.bolt_rounded;
      case 'Water Treatment':
        return Icons.science_rounded;
      case 'Meetings':
        return Icons.groups_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Future<void> _updateStatus(
      BuildContext context, WidgetRef ref, String status) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.updateExpenseStatus(expense.id as int, status);
    ref.invalidate(expensesProvider);
    ref.invalidate(totalExpensesProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense ${status == 'approved' ? 'approved' : 'rejected'}.'),
          backgroundColor:
              status == 'approved' ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}
