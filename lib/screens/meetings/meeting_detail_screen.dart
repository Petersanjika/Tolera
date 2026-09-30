import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/meetings_provider.dart';

/// Detail view for a meeting — shows agenda, minutes, and attendance list.
class MeetingDetailScreen extends ConsumerWidget {
  final int meetingId;

  const MeetingDetailScreen({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingAsync = ref.watch(meetingByIdProvider(meetingId));
    final attendanceAsync =
        ref.watch(attendanceForMeetingProvider(meetingId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: meetingAsync.when(
        data: (meeting) {
          if (meeting == null) {
            return const Center(child: Text('Meeting not found.'));
          }

          final presentCount = attendanceAsync.valueOrNull
                  ?.where((a) => a.status == 'present')
                  .length ??
              0;
          final totalCount =
              attendanceAsync.valueOrNull?.length ?? 0;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: AppColors.deepBlue,
                foregroundColor: AppColors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    meeting.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.deepBlue,
                          AppColors.deepBlue.withBlue(200)
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.groups_rounded,
                          color: Colors.white24, size: 80),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Meta chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(
                          label: meeting.meetingType,
                          icon: Icons.event_rounded,
                          color: AppColors.deepBlue,
                        ),
                        _Chip(
                          label: AppFormatters.date(
                              meeting.meetingDate),
                          icon: Icons.calendar_today_rounded,
                          color: AppColors.teal,
                        ),
                        _Chip(
                          label: 'By ${meeting.createdBy}',
                          icon: Icons.person_rounded,
                          color: AppColors.success,
                        ),
                        _Chip(
                          label: '$presentCount/$totalCount Present',
                          icon: Icons.how_to_reg_rounded,
                          color: presentCount == totalCount
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 24),

                    _Section(
                      title: 'Agenda',
                      icon: Icons.list_alt_rounded,
                      child: Text(
                        meeting.agenda,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),

                    if (meeting.minutes != null &&
                        meeting.minutes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _Section(
                        title: 'Minutes',
                        icon: Icons.notes_rounded,
                        child: Text(
                          meeting.minutes!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    _Section(
                      title: 'Attendance',
                      icon: Icons.how_to_reg_rounded,
                      child: attendanceAsync.when(
                        data: (list) {
                          if (list.isEmpty) {
                            return const Text(
                                'No attendance recorded.',
                                style: TextStyle(
                                    color: AppColors.textHint));
                          }

                          final present = list
                              .where((a) => a.status == 'present')
                              .toList();
                          final absent = list
                              .where((a) => a.status == 'absent')
                              .toList();

                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              if (present.isNotEmpty) ...[
                                const _AttendanceGroupHeader(
                                    'Present',
                                    AppColors.success),
                                const SizedBox(height: 6),
                                ...present.map((a) => _AttendanceTile(
                                    attendance: a,
                                    isDark: isDark)),
                              ],
                              if (absent.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const _AttendanceGroupHeader(
                                    'Absent',
                                    AppColors.error),
                                const SizedBox(height: 6),
                                ...absent.map((a) => _AttendanceTile(
                                    attendance: a,
                                    isDark: isDark)),
                              ],
                            ],
                          );
                        },
                        loading: () => const LinearProgressIndicator(
                            color: AppColors.teal),
                        error: (e, _) => Text('Error: $e'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.teal)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Chip(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Section(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.offWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.teal, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _AttendanceGroupHeader extends StatelessWidget {
  final String label;
  final Color color;

  const _AttendanceGroupHeader(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color),
        ),
      ],
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  final dynamic attendance;
  final bool isDark;

  const _AttendanceTile({required this.attendance, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isPresent = (attendance.status as String) == 'present';
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isPresent
                ? AppColors.success.withOpacity(0.15)
                : AppColors.error.withOpacity(0.15),
            child: Text(
              AppFormatters.initials(attendance.memberName as String),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isPresent ? AppColors.success : AppColors.error,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              attendance.memberName as String,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Icon(
            isPresent
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: isPresent ? AppColors.success : AppColors.error,
            size: 18,
          ),
        ],
      ),
    );
  }
}
