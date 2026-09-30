import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meeting.dart';
import 'providers.dart';

final meetingsProvider = FutureProvider<List<Meeting>>((ref) async {
  final repo = ref.watch(meetingRepositoryProvider);
  return repo.getAllMeetings();
});

final meetingByIdProvider =
    FutureProvider.family<Meeting?, int>((ref, id) async {
  final repo = ref.watch(meetingRepositoryProvider);
  return repo.getMeetingById(id);
});

final attendanceForMeetingProvider =
    FutureProvider.family<List<Attendance>, int>((ref, meetingId) async {
  final repo = ref.watch(meetingRepositoryProvider);
  return repo.getAttendanceForMeeting(meetingId);
});

final meetingCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(meetingRepositoryProvider);
  return repo.getMeetingCount();
});
