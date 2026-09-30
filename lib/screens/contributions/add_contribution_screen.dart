import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/contribution.dart';
import '../../models/member.dart';
import '../../providers/providers.dart';
import '../../providers/members_provider.dart';
import '../../providers/contributions_provider.dart';
import '../../widgets/gradient_button.dart';

/// Screen for recording a new monthly contribution payment.
class AddContributionScreen extends ConsumerStatefulWidget {
  const AddContributionScreen({super.key});

  @override
  ConsumerState<AddContributionScreen> createState() =>
      _AddContributionScreenState();
}

class _AddContributionScreenState
    extends ConsumerState<AddContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _collectorCtrl = TextEditingController(text: 'Treasurer');
  final _notesCtrl = TextEditingController();
  final _amountCtrl =
      TextEditingController(text: AppConstants.defaultMonthlyContribution.toStringAsFixed(0));

  Member? _selectedMember;
  String _paymentMethod = AppConstants.paymentMethods.first;
  String _monthKey = AppFormatters.currentMonthKey();
  bool _isLoading = false;
  bool _alreadyPaid = false;

  @override
  void dispose() {
    _collectorCtrl.dispose();
    _notesCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(activeMembersProvider);

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
                    // Receipt preview
                    _buildReceiptPreview(context),
                    const SizedBox(height: 20),
                    _buildSectionTitle(context, 'Member'),
                    const SizedBox(height: 12),
                    // Member selector
                    membersAsync.when(
                      data: (members) => _buildMemberSelector(context, members),
                      loading: () => const LinearProgressIndicator(
                          color: AppColors.teal),
                      error: (e, _) => Text('Error: $e'),
                    ),
                    if (_alreadyPaid) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: AppColors.warning, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This member has already paid for the selected month.',
                                style: TextStyle(
                                    color: AppColors.warning, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildSectionTitle(context, 'Payment Details'),
                    const SizedBox(height: 12),
                    _buildMonthSelector(context),
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
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        prefixIcon: Icon(Icons.payment_rounded,
                            color: AppColors.teal, size: 20),
                      ),
                      items: AppConstants.paymentMethods
                          .map((m) =>
                              DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _paymentMethod = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _collectorCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Collector Name',
                        prefixIcon: Icon(Icons.person_rounded,
                            color: AppColors.teal, size: 20),
                      ),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Enter collector name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        prefixIcon: Icon(Icons.notes_rounded,
                            color: AppColors.teal, size: 20),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      label: 'Record Payment',
                      icon: Icons.check_rounded,
                      isLoading: _isLoading,
                      onPressed: _alreadyPaid ? null : _submit,
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
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
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
                  'Record Payment',
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

  /// Shows a live receipt preview at the top
  Widget _buildReceiptPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.aquaGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_rounded,
                  color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'PAYMENT RECEIPT PREVIEW',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                AppFormatters.formatMonthKey(_monthKey),
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 16),
          if (_selectedMember != null)
            Text(
              _selectedMember!.fullName,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          if (_selectedMember == null)
            Text(
              'Select a member…',
              style: TextStyle(
                color: AppColors.white.withOpacity(0.6),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            AppFormatters.currency(
                double.tryParse(_amountCtrl.text) ??
                    AppConstants.defaultMonthlyContribution),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_paymentMethod}  •  ${_collectorCtrl.text}',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.75),
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
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

  Widget _buildMemberSelector(BuildContext context, List<Member> members) {
    return DropdownButtonFormField<Member>(
      value: _selectedMember,
      decoration: const InputDecoration(
        labelText: 'Select Member',
        prefixIcon: Icon(Icons.person_rounded, color: AppColors.teal, size: 20),
      ),
      hint: const Text('Choose a member…'),
      items: members
          .map(
            (m) => DropdownMenuItem(
              value: m,
              child: Text(
                '${m.fullName} (${m.houseNumber})',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (m) async {
        setState(() => _selectedMember = m);
        if (m != null) {
          await _checkIfAlreadyPaid(m.id!);
        }
      },
      validator: (v) => v == null ? 'Please select a member' : null,
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final now = DateTime.now();
    // Generate last 6 months
    final months = List.generate(6, (i) {
      final d = DateTime(now.year, now.month - i);
      return '${d.year}-${d.month.toString().padLeft(2, '0')}';
    });

    return DropdownButtonFormField<String>(
      value: _monthKey,
      decoration: const InputDecoration(
        labelText: 'Payment Month',
        prefixIcon: Icon(Icons.calendar_month_rounded,
            color: AppColors.teal, size: 20),
      ),
      items: months
          .map(
            (mk) => DropdownMenuItem(
              value: mk,
              child: Text(AppFormatters.formatMonthKey(mk)),
            ),
          )
          .toList(),
      onChanged: (v) async {
        setState(() => _monthKey = v!);
        if (_selectedMember != null) {
          await _checkIfAlreadyPaid(_selectedMember!.id!);
        }
      },
    );
  }

  Future<void> _checkIfAlreadyPaid(int memberId) async {
    final repo = ref.read(contributionRepositoryProvider);
    final paid = await repo.hasMemberPaidForMonth(memberId, _monthKey);
    if (mounted) setState(() => _alreadyPaid = paid);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(contributionRepositoryProvider);
      final count = await repo.getContributionCount();

      final contribution = Contribution(
        memberId: _selectedMember!.id!,
        amount: double.parse(_amountCtrl.text),
        monthKey: _monthKey,
        paymentMethod: _paymentMethod,
        collectorName: _collectorCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        receiptNumber: AppFormatters.receiptNumber(count + 1),
        createdAt: DateTime.now(),
      );

      await repo.insertContribution(contribution);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.white, size: 18),
                SizedBox(width: 8),
                Text('Payment recorded successfully!'),
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
