import '../database/app_database.dart';
import '../models/member.dart';

/// Repository for all member-related database operations
class MemberRepository {
  final AppDatabase _db;
  MemberRepository(this._db);

  Future<List<Member>> getAllMembers() async {
    final db = await _db.database;
    final maps = await db.query('members', orderBy: 'fullName ASC');
    return maps.map(Member.fromMap).toList();
  }

  Future<List<Member>> getActiveMembers() async {
    final db = await _db.database;
    final maps = await db.query(
      'members',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'fullName ASC',
    );
    return maps.map(Member.fromMap).toList();
  }

  Future<Member?> getMemberById(int id) async {
    final db = await _db.database;
    final maps = await db.query('members', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Member.fromMap(maps.first);
  }

  Future<List<Member>> searchMembers(String query) async {
    final db = await _db.database;
    final pattern = '%${query.toLowerCase()}%';
    final maps = await db.rawQuery(
      '''SELECT * FROM members WHERE
         LOWER(fullName) LIKE ? OR
         phone LIKE ? OR
         houseNumber LIKE ? OR
         village LIKE ?
         ORDER BY fullName ASC''',
      [pattern, pattern, pattern, pattern],
    );
    return maps.map(Member.fromMap).toList();
  }

  Future<int> insertMember(Member member) async {
    final db = await _db.database;
    return db.insert('members', member.toMap());
  }

  Future<int> updateMember(Member member) async {
    final db = await _db.database;
    return db.update(
      'members',
      member.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> deleteMember(int id) async {
    final db = await _db.database;
    return db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getMemberCount() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM members WHERE status = "active"');
    return result.first['count'] as int? ?? 0;
  }
}
