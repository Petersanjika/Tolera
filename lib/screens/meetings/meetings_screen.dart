import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/meetings_provider.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/empty_state_widget.dart';
import 'add_meeting_screen.dart';
import 'meeting_detail_screen.dart';

/// Meetings screen – lists all recorded committee meetings.
class MeetingsScreen extends ConsumerWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetings = ref.watch(meetingsProvider);
    final meetingCount = ref.watch(meetingCountProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, meetingCount),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.teal,
              onRefresh: () async => ref.invalidate(meetingsProvider),
              child: meetings.when(
                data: (list) {
                  if (list.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.groups_outlined,
                      title: 'No Meetings Recorded',
                      subtitle:
                          'Document committee meetings and attendance here.',
                      actionLabel: 'Record Meeting',
                      onAction: () => _navigateToAdd(context, ref),
                    );
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: list.length,
                    itemBuilder: (context, i) => _MeetingCard(
                      meeting: list[i],
                      index: i,
                    ),
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
        onPressed: () => _navigateToAdd(context, ref),
        backgroundColor: AppColors.deepBlue,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Record Meeting',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildHeader(
      BuildContext context, AsyncValue<int> meetingCount) {
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Row(
            children: [
              const Icon(Icons.groups_rounded,
                  color: AppColors.white, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meetings',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Committee minutes & attendance',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.25)),
                ),
                child: Column(
                  children: [
                    meetingCount.when(
                      data: (v) => Text(
                        '$v',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      loading: () => const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      ),
                      error: (_, __) => const Text('—',
                          style: TextStyle(color: AppColors.white)),
                    ),
                    const Text(
                      'Total',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
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
      MaterialPageRoute(builder: (_) => const AddMeetingScreen()),
    );
    if (result == true) {
      ref.invalidate(meetingsProvider);
      ref.invalidate(meetingCountProvider);
    }
  }
}

class _MeetingCard extends ConsumerWidget {
  final dynamic meeting;
  final int index;

  const _MeetingCard({required this.meeting, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final attendanceAsync =
        ref.watch(attendanceForMeetingProvider(meeting.id as int));
    final presentCount = attendanceAsync.valueOrNull
            ?.where((a) => a.status == 'present')
            .length ??
        0;
    final totalCount = attendanceAsync.valueOrNull?.length ?? 0;

    Color typeColor;
    IconData typeIcon;
    switch (meeting.meetingType as String) {
      case 'General Assembly':
        typeColor = AppColors.deepBlue;
        typeIcon = Icons.groups_rounded;
        break;
      case 'Emergency':
        typeColor = AppColors.error;
        typeIcon = Icons.warning_amber_rounded;
        break;
      case 'Financial Review':
        typeColor = AppColors.success;
        typeIcon = Icons.account_balance_wallet_rounded;
        break;
      case 'Technical':
        typeColor = AppColors.teal;
        typeIcon = Icons.build_rounded;
        break;
      default:
        typeColor = AppColors.deepBlue;
        typeIcon = Icons.event_rounded;
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
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  MeetingDetailScreen(meetingId: meeting.id as int)),
        ),
        child: Card(
          color: isDark ? AppColors.darkCard : AppColors.white,
          margin: const EdgeInsets.only(bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: typeColor.withOpacity(0.3)),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meeting.title as String,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              meeting.meetingType as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        meeting.agenda as String,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppFormatters.date(meeting.meetingDate as DateTime),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textHint),
                    ),
                    const SizedBox(height: 8),
                    if (totalCount > 0) ...[
                      Row(
                        children: [
                          const Icon(Icons.how_to_reg_rounded,
                              size: 14, color: AppColors.teal),
                          const SizedBox(width: 4),
                          Text(
                            '$presentCount/$totalCount',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.teal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textHint, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
