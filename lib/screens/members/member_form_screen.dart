import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/member.dart';
import '../../providers/providers.dart';
import '../../providers/members_provider.dart';
import '../../widgets/gradient_button.dart';

/// Form screen for registering a new member or editing an existing one.
class MemberFormScreen extends ConsumerStatefulWidget {
  final Member? member; // null = create new

  const MemberFormScreen({super.key, this.member});

  @override
  ConsumerState<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends ConsumerState<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _houseCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();

  String _gender = 'Male';
  String _village = AppConstants.villages.first;
  int _householdSize = 1;
  bool _isLoading = false;

  bool get _isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.member!.fullName;
      _phoneCtrl.text = widget.member!.phone;
      _houseCtrl.text = widget.member!.houseNumber;
      _nationalIdCtrl.text = widget.member!.nationalId ?? '';
      _gender = widget.member!.gender;
      _village = widget.member!.village;
      _householdSize = widget.member!.householdSize;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _houseCtrl.dispose();
    _nationalIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _buildHeader(context),
          // ── Form ─────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Personal Information'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      context,
                      controller: _nameCtrl,
                      label: 'Full Name',
                      icon: Icons.person_rounded,
                      validator: (v) =>
                          v?.isEmpty == true ? 'Please enter full name' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildGenderSelector(),
                    const SizedBox(height: 12),
                    _buildTextField(
                      context,
                      controller: _phoneCtrl,
                      label: 'Phone Number',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      hint: '0888 123 456',
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Enter phone number';
                        if (v!.length < 9) return 'Enter a valid phone number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      context,
                      controller: _nationalIdCtrl,
                      label: 'National ID (Optional)',
                      icon: Icons.badge_rounded,
                      required: false,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Location Information'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      context,
                      controller: _houseCtrl,
                      label: 'House Number',
                      icon: Icons.home_rounded,
                      hint: 'HH-001',
                      validator: (v) =>
                          v?.isEmpty == true ? 'Enter house number' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildVillageDropdown(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Household Information'),
                    const SizedBox(height: 12),
                    _buildHouseholdSizeSelector(),
                    const SizedBox(height: 32),
                    GradientButton(
                      label:
                          _isEditing ? 'Update Member' : 'Register Member',
                      icon: _isEditing
                          ? Icons.save_rounded
                          : Icons.person_add_rounded,
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
              Expanded(
                child: Text(
                  _isEditing ? 'Edit Member' : 'Register Member',
                  style: const TextStyle(
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

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hint,
    String? Function(String?)? validator,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.teal, size: 20),
      ),
      validator: required ? validator : null,
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['Male', 'Female', 'Other'].map((g) {
            final isSelected = _gender == g;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _gender = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.aquaGradient : null,
                      color: isSelected ? null : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.teal
                            : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      g,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVillageDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _village,
      decoration: const InputDecoration(
        labelText: 'Village / Area',
        prefixIcon:
            Icon(Icons.location_on_rounded, color: AppColors.teal, size: 20),
      ),
      items: AppConstants.villages
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) => setState(() => _village = v!),
    );
  }

  Widget _buildHouseholdSizeSelector() {
    return Row(
      children: [
        const Icon(Icons.people_rounded, color: AppColors.teal, size: 20),
        const SizedBox(width: 8),
        Text(
          'Household Size:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        IconButton(
          onPressed: _householdSize > 1
              ? () => setState(() => _householdSize--)
              : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: AppColors.teal,
        ),
        Container(
          width: 44,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$_householdSize',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.teal,
            ),
          ),
        ),
        IconButton(
          onPressed: _householdSize < 20
              ? () => setState(() => _householdSize++)
              : null,
          icon: const Icon(Icons.add_circle_outline),
          color: AppColors.teal,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(memberRepositoryProvider);
      final now = DateTime.now();

      if (_isEditing) {
        final updated = widget.member!.copyWith(
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          gender: _gender,
          houseNumber: _houseCtrl.text.trim(),
          village: _village,
          nationalId: _nationalIdCtrl.text.trim().isEmpty
              ? null
              : _nationalIdCtrl.text.trim(),
          householdSize: _householdSize,
          updatedAt: now,
        );
        await repo.updateMember(updated);
        if (mounted) {
          _showSuccess('Member updated successfully!');
          Navigator.pop(context, true);
        }
      } else {
        final member = Member(
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          gender: _gender,
          houseNumber: _houseCtrl.text.trim(),
          village: _village,
          nationalId: _nationalIdCtrl.text.trim().isEmpty
              ? null
              : _nationalIdCtrl.text.trim(),
          householdSize: _householdSize,
          joinDate: now,
          status: 'active',
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertMember(member);
        if (mounted) {
          _showSuccess('Member registered successfully!');
          Navigator.pop(context, true);
        }
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.white, size: 18),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
