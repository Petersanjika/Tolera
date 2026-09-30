import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/expense.dart';
import '../../providers/providers.dart';
import '../../widgets/gradient_button.dart';

/// Screen for adding a new expense record.
class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _paidToCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _approvedByCtrl = TextEditingController();
  final _confirmationCtrl = TextEditingController();

  String _category = AppConstants.expenseCategories.first;
  String _status = 'pending';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _paidToCtrl.dispose();
    _descCtrl.dispose();
    _approvedByCtrl.dispose();
    _confirmationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Expense Details'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Expense Title',
                        prefixIcon: Icon(Icons.receipt_long_rounded,
                            color: AppColors.teal, size: 20),
                      ),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount (MWK)',
                        prefixIcon: Icon(Icons.attach_money_rounded,
                            color: AppColors.teal, size: 20),
                      ),
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Enter amount';
                        if (double.tryParse(v!) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_rounded,
                            color: AppColors.teal, size: 20),
                      ),
                      items: AppConstants.expenseCategories
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _paidToCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Paid To',
                        prefixIcon: Icon(Icons.person_rounded,
                            color: AppColors.teal, size: 20),
                      ),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Enter recipient name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description_rounded,
                            color: AppColors.teal, size: 20),
                        alignLabelWithHint: true,
                      ),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Enter a description' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle(context, 'Approval & Verification'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _approvedByCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Approved By (Optional)',
                        prefixIcon: Icon(Icons.how_to_vote_rounded,
                            color: AppColors.teal, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmationCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Money Confirmation (Optional)',
                        hintText: 'Paste SMS confirmation text here…',
                        prefixIcon: Icon(Icons.sms_rounded,
                            color: AppColors.teal, size: 20),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Status selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _StatusOption(
                              label: 'Pending',
                              color: AppColors.warning,
                              icon: Icons.access_time_rounded,
                              selected: _status == 'pending',
                              onTap: () =>
                                  setState(() => _status = 'pending'),
                            ),
                            const SizedBox(width: 10),
                            _StatusOption(
                              label: 'Approved',
                              color: AppColors.success,
                              icon: Icons.check_circle_rounded,
                              selected: _status == 'approved',
                              onTap: () =>
                                  setState(() => _status = 'approved'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      label: 'Save Expense',
                      icon: Icons.save_rounded,
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.cardGradientOrange),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Add Expense',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.aquaGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.teal,
              ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(expenseRepositoryProvider);

      final expense = Expense(
        title: _titleCtrl.text.trim(),
        amount: double.parse(_amountCtrl.text),
        category: _category,
        paidTo: _paidToCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        confirmationText: _confirmationCtrl.text.trim().isEmpty
            ? null
            : _confirmationCtrl.text.trim(),
        approvedBy: _approvedByCtrl.text.trim().isEmpty
            ? null
            : _approvedByCtrl.text.trim(),
        status: _status,
        createdAt: DateTime.now(),
      );

      await repo.insertExpense(expense);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.white, size: 18),
                SizedBox(width: 8),
                Text('Expense saved successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _StatusOption extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.label,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppColors.divider,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? color : AppColors.textHint, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : AppColors.textSecondary,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
