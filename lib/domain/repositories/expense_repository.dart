import '../entities/expense_entity.dart';

abstract interface class ExpenseRepository {
  Stream<List<ExpenseEntity>> watchAllExpenses();
  Future<List<ExpenseEntity>> getExpensesByMonth(int year, int month);
  Future<void> addExpense(ExpenseEntity expense);
  Future<void> updateExpense(ExpenseEntity expense);
  Future<void> deleteExpense(int id);
  Future<double> getTotalByMonth(int year, int month);
  Stream<double> watchTotalByMonth(int year, int month);
  Stream<Map<String, double>> watchCategoryTotals(int year, int month);
}
