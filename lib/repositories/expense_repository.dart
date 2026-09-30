import '../database/app_database.dart';
import '../models/expense.dart';

/// Repository for expense-related database operations
class ExpenseRepository {
  final AppDatabase _db;
  ExpenseRepository(this._db);

  Future<List<Expense>> getAllExpenses() async {
    final db = await _db.database;
    final maps = await db.query('expenses', orderBy: 'createdAt DESC');
    return maps.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> getExpensesByCategory(String category) async {
    final db = await _db.database;
    final maps = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'createdAt DESC',
    );
    return maps.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> getExpensesByStatus(String status) async {
    final db = await _db.database;
    final maps = await db.query(
      'expenses',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdAt DESC',
    );
    return maps.map(Expense.fromMap).toList();
  }

  Future<double> getTotalExpenses() async {
    final db = await _db.database;
    final result =
        await db.rawQuery('SELECT SUM(amount) as total FROM expenses');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalApprovedExpenses() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE status = "approved"',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await _db.database;
    return db.insert('expenses', expense.toMap());
  }

  Future<int> updateExpenseStatus(int id, String status) async {
    final db = await _db.database;
    return db.update(
      'expenses',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await _db.database;
    return db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await _db.database;
    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
