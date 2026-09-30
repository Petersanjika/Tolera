import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/meeting.dart';
import '../../providers/providers.dart';
import '../../providers/members_provider.dart';
import '../../widgets/gradient_button.dart';

/// Screen for recording a new meeting with attendance.
class AddMeetingScreen extends ConsumerStatefulWidget {
  const AddMeetingScreen({super.key});

  @override
  ConsumerState<AddMeetingScreen> createState() => _AddMeetingScreenState();
}

class _AddMeetingScreenState extends ConsumerState<AddMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _agendaCtrl = TextEditingController();
  final _minutesCtrl = TextEditingController();
  final _createdByCtrl =
      TextEditingController(text: 'Secretary');

  String _meetingType = AppConstants.meetingTypes.first;
  DateTime _meetingDate = DateTime.now();
  bool _isLoading = false;

  // attendance: memberId → 'present' | 'absent'
  final Map<int, String> _attendance = {};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _agendaCtrl.dispose();
    _minutesCtrl.dispose();
    _createdByCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(activeMembersProvider);

    // Initialize attendance map when members load
    membersAsync.whenData((members) {
      for (final m in members) {
        _attendance.putIfAbsent(m.id!, () => 'present');
      }
    });

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
                    _buildSectionTitle(context, 'Meeting Details'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Meeting Title',
                        prefixIcon: Icon(Icons.title_rounded,
                            color: AppColors.teal, size: 20),
                      ),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _meetingType,
                      decoration: const InputDecoration(
                        labelText: 'Meeting Type',
                        prefixIcon: Icon(Icons.category_rounded,
                            color: AppColors.teal, size: 20),
                      ),
                      items: AppConstants.meetingTypes
                          .map((t) =>
                              DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _meetingType = v!),
                    ),
                    const SizedBox(height: 12),
                    // Date picker
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Meeting Date',
                            prefixIcon: const Icon(
                                Icons.calendar_today_rounded,
                                color: AppColors.teal,
                                size: 20),
                            hintText:
                                AppFormatters.date(_meetingDate),
                          ),
                          controller: TextEditingController(
                            text: AppFormatters.date(_meetingDate),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _agendaCtrl,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Agenda',
                        prefixIcon: Icon(Icons.list_alt_rounded,
                            color: AppColors.teal, size: 20),
                        alignLabelWithHint: true,
                      ),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Enter the agenda' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _minutesCtrl,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Minutes / Notes (Optional)',
                        prefixIcon: Icon(Icons.notes_rounded,
                            color: AppColors.teal, size: 20),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _createdByCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Recorded By',
                        prefixIcon: Icon(Icons.person_rounded,
                            color: AppColors.teal, size: 20),
                      ),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Attendance'),
                    const SizedBox(height: 12),
                    membersAsync.when(
                      data: (members) => Column(
                        children: [
                          // Quick select row
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => setState(() {
                                  for (final m in members) {
                                    _attendance[m.id!] = 'present';
                                  }
                                }),
                                icon: const Icon(Icons.check_circle_outline,
                                    size: 16, color: AppColors.success),
                                label: const Text('All Present',
                                    style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 13)),
                              ),
                              TextButton.icon(
                                onPressed: () => setState(() {
                                  for (final m in members) {
                                    _attendance[m.id!] = 'absent';
                                  }
                                }),
                                icon: const Icon(Icons.cancel_outlined,
                                    size: 16, color: AppColors.error),
                                label: const Text('All Absent',
                                    style: TextStyle(
                                        color: AppColors.error,
                                        fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...members.map(
                            (m) => _AttendanceRow(
                              memberName: m.fullName,
                              status: _attendance[m.id!] ?? 'present',
                              onToggle: (s) => setState(
                                  () => _attendance[m.id!] = s),
                            ),
                          ),
                        ],
                      ),
                      loading: () => const LinearProgressIndicator(
                          color: AppColors.teal),
                      error: (e, _) => Text('Error loading members: $e'),
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      label: 'Save Meeting',
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.deepBlue, AppColors.deepBlue.withBlue(200)],
        ),
      ),
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
                  'Record Meeting',
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _meetingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.teal,
            onPrimary: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _meetingDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(meetingRepositoryProvider);

      final meeting = Meeting(
        title: _titleCtrl.text.trim(),
        meetingType: _meetingType,
        agenda: _agendaCtrl.text.trim(),
        minutes: _minutesCtrl.text.trim().isEmpty
            ? null
            : _minutesCtrl.text.trim(),
        meetingDate: _meetingDate,
        createdBy: _createdByCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      final meetingId = await repo.insertMeeting(meeting);

      // Build attendance records
      final attendanceRecords = _attendance.entries
          .map(
            (e) => Attendance(
              meetingId: meetingId,
              memberId: e.key,
              status: e.value,
              memberName: '',
              createdAt: DateTime.now(),
            ),
          )
          .toList();

      await repo.bulkInsertAttendance(attendanceRecords);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.white, size: 18),
                SizedBox(width: 8),
                Text('Meeting recorded!'),
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
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _AttendanceRow extends StatelessWidget {
  final String memberName;
  final String status;
  final void Function(String) onToggle;

  const _AttendanceRow({
    required this.memberName,
    required this.status,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isPresent = status == 'present';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isPresent
            ? AppColors.success.withOpacity(0.06)
            : AppColors.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPresent
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPresent
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: isPresent ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              memberName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isPresent
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
          ),
          Switch(
            value: isPresent,
            activeColor: AppColors.success,
            inactiveThumbColor: AppColors.error,
            inactiveTrackColor: AppColors.error.withOpacity(0.3),
            onChanged: (v) =>
                onToggle(v ? 'present' : 'absent'),
          ),
        ],
      ),
    );
  }
}
