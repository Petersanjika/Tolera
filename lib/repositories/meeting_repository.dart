import '../database/app_database.dart';
import '../models/meeting.dart';

/// Repository for meeting and attendance database operations
class MeetingRepository {
  final AppDatabase _db;
  MeetingRepository(this._db);

  Future<List<Meeting>> getAllMeetings() async {
    final db = await _db.database;
    final maps = await db.query('meetings', orderBy: 'meetingDate DESC');
    return maps.map(Meeting.fromMap).toList();
  }

  Future<Meeting?> getMeetingById(int id) async {
    final db = await _db.database;
    final maps =
        await db.query('meetings', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Meeting.fromMap(maps.first);
  }

  Future<int> insertMeeting(Meeting meeting) async {
    final db = await _db.database;
    return db.insert('meetings', meeting.toMap());
  }

  Future<int> updateMeeting(Meeting meeting) async {
    final db = await _db.database;
    return db.update(
      'meetings',
      meeting.toMap(),
      where: 'id = ?',
      whereArgs: [meeting.id],
    );
  }

  Future<int> deleteMeeting(int id) async {
    final db = await _db.database;
    return db.delete('meetings', where: 'id = ?', whereArgs: [id]);
  }

  // ── Attendance ────────────────────────────────────────────────────────────

  /// Get all attendance records for a meeting, joined with member name
  Future<List<Attendance>> getAttendanceForMeeting(int meetingId) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT a.*, m.fullName as memberName
      FROM attendance a
      JOIN members m ON a.memberId = m.id
      WHERE a.meetingId = ?
      ORDER BY m.fullName ASC
    ''', [meetingId]);
    return maps.map(Attendance.fromMap).toList();
  }

  Future<void> upsertAttendance(Attendance attendance) async {
    final db = await _db.database;
    // Try to find existing record
    final existing = await db.query(
      'attendance',
      where: 'meetingId = ? AND memberId = ?',
      whereArgs: [attendance.meetingId, attendance.memberId],
    );
    if (existing.isEmpty) {
      await db.insert('attendance', attendance.toMap());
    } else {
      await db.update(
        'attendance',
        {'status': attendance.status},
        where: 'meetingId = ? AND memberId = ?',
        whereArgs: [attendance.meetingId, attendance.memberId],
      );
    }
  }

  Future<void> bulkInsertAttendance(List<Attendance> records) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final r in records) {
      batch.insert('attendance', r.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<int> getPresentCountForMeeting(int meetingId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM attendance WHERE meetingId = ? AND status = "present"',
      [meetingId],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getMeetingCount() async {
    final db = await _db.database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM meetings');
    return result.first['count'] as int? ?? 0;
  }
}
