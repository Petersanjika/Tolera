import '../database/app_database.dart';
import '../models/app_user.dart';

/// Repository for user account management.
/// Handles CRUD operations for the users table.
class UserRepository {
  final AppDatabase _db;

  UserRepository(this._db);

  /// Fetch all active users for a given role
  Future<List<AppUser>> getUsersByRole(UserRole role) async {
    final db = await _db.database;
    final maps = await db.query(
      'users',
      where: 'role = ? AND status = ?',
      whereArgs: [role.dbValue, 'active'],
      orderBy: 'name ASC',
    );
    return maps.map(AppUser.fromMap).toList();
  }

  /// Fetch all users (for admin view)
  Future<List<AppUser>> getAllUsers() async {
    final db = await _db.database;
    final maps = await db.query('users', orderBy: 'role ASC, name ASC');
    return maps.map(AppUser.fromMap).toList();
  }

  /// Find a user by ID
  Future<AppUser?> getUserById(int id) async {
    final db = await _db.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return AppUser.fromMap(maps.first);
  }

  /// Verify a user's PIN — returns the user if correct, null otherwise
  Future<AppUser?> verifyPin(int userId, String pin) async {
    final db = await _db.database;
    final maps = await db.query(
      'users',
      where: 'id = ? AND pin = ? AND status = ?',
      whereArgs: [userId, pin, 'active'],
    );
    if (maps.isEmpty) return null;
    return AppUser.fromMap(maps.first);
  }

  /// Insert a new user
  Future<int> insertUser(AppUser user) async {
    final db = await _db.database;
    return db.insert('users', user.toMap());
  }

  /// Update user details
  Future<void> updateUser(AppUser user) async {
    final db = await _db.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Count total users with a given role
  Future<int> countByRole(UserRole role) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM users WHERE role = ? AND status = ?',
      [role.dbValue, 'active'],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Check if any chairperson account exists (for first-time setup)
  Future<bool> hasChairperson() async {
    return (await countByRole(UserRole.chairperson)) > 0;
  }
}
