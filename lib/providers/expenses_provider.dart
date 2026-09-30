import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import 'providers.dart';

final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getAllExpenses();
});

final totalExpensesProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getTotalApprovedExpenses();
});

final pendingExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getExpensesByStatus('pending');
});

final approvedExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getExpensesByStatus('approved');
});
