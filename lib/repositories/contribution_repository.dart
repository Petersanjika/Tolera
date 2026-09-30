import '../database/app_database.dart';
import '../models/contribution.dart';

/// Repository for contribution-related database operations
class ContributionRepository {
  final AppDatabase _db;
  ContributionRepository(this._db);

  Future<List<Contribution>> getAllContributions() async {
    final db = await _db.database;
    final maps = await db.query('contributions', orderBy: 'createdAt DESC');
    return maps.map(Contribution.fromMap).toList();
  }

  Future<List<Contribution>> getContributionsByMember(int memberId) async {
    final db = await _db.database;
    final maps = await db.query(
      'contributions',
      where: 'memberId = ?',
      whereArgs: [memberId],
      orderBy: 'createdAt DESC',
    );
    return maps.map(Contribution.fromMap).toList();
  }

  Future<List<Contribution>> getContributionsByMonth(String monthKey) async {
    final db = await _db.database;
    final maps = await db.query(
      'contributions',
      where: 'monthKey = ?',
      whereArgs: [monthKey],
      orderBy: 'createdAt DESC',
    );
    return maps.map(Contribution.fromMap).toList();
  }

  /// Get IDs of members who have paid for a specific month
  Future<List<int>> getPaidMemberIdsForMonth(String monthKey) async {
    final db = await _db.database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT memberId FROM contributions WHERE monthKey = ?',
      [monthKey],
    );
    return maps.map((m) => m['memberId'] as int).toList();
  }

  Future<bool> hasMemberPaidForMonth(int memberId, String monthKey) async {
    final db = await _db.database;
    final maps = await db.query(
      'contributions',
      where: 'memberId = ? AND monthKey = ?',
      whereArgs: [memberId, monthKey],
    );
    return maps.isNotEmpty;
  }

  Future<double> getTotalContributions() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM contributions',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalContributionsForMonth(String monthKey) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM contributions WHERE monthKey = ?',
      [monthKey],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Returns monthly totals for chart: [{monthKey: "2026-03", total: 22000.0}, ...]
  Future<List<Map<String, dynamic>>> getMonthlyTotals({int months = 6}) async {
    final db = await _db.database;
    final results = await db.rawQuery('''
      SELECT monthKey, SUM(amount) as total
      FROM contributions
      GROUP BY monthKey
      ORDER BY monthKey DESC
      LIMIT ?
    ''', [months]);
    return results
        .map((r) => {
              'monthKey': r['monthKey'] as String,
              'total': (r['total'] as num?)?.toDouble() ?? 0.0,
            })
        .toList()
        .reversed
        .toList();
  }

  Future<int> insertContribution(Contribution contribution) async {
    final db = await _db.database;
    return db.insert('contributions', contribution.toMap());
  }

  Future<int> deleteContribution(int id) async {
    final db = await _db.database;
    return db.delete('contributions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getContributionCount() async {
    final db = await _db.database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM contributions');
    return result.first['count'] as int? ?? 0;
  }
}
