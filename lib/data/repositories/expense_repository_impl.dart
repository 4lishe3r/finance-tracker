import 'package:drift/drift.dart';

import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/local/database.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final AppDatabase _db;

  ExpenseRepositoryImpl(this._db);

  // Map Drift row → Domain entity
  ExpenseEntity _toEntity(Expense row) => ExpenseEntity(
        id: row.id,
        title: row.title,
        amount: row.amount,
        category: row.category,
        currency: row.currency,
        note: row.note,
        date: row.date,
      );

  // Map Domain entity → Drift companion
  ExpensesCompanion _toCompanion(ExpenseEntity e) => ExpensesCompanion(
        title: Value(e.title),
        amount: Value(e.amount),
        category: Value(e.category),
        currency: Value(e.currency),
        note: Value(e.note),
        date: Value(e.date),
      );

  @override
  Stream<List<ExpenseEntity>> watchAllExpenses() =>
      _db.watchAllExpenses().map((rows) => rows.map(_toEntity).toList());

  @override
  Future<List<ExpenseEntity>> getExpensesByMonth(int year, int month) async {
    final rows = await _db.getExpensesByMonth(year, month);
    return rows.map(_toEntity).toList();
  }

  @override
  Future<void> addExpense(ExpenseEntity expense) async {
    await _db.insertExpense(_toCompanion(expense));
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    final row = Expense(
      id: expense.id!,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      currency: expense.currency,
      note: expense.note,
      date: expense.date,
      createdAt: DateTime.now(),
    );
    await _db.updateExpense(row);
  }

  @override
  Future<void> deleteExpense(int id) async {
    await _db.deleteExpense(id);
  }

  @override
  Future<double> getTotalByMonth(int year, int month) =>
      _db.getTotalByMonth(year, month);

  @override
  Stream<double> watchTotalByMonth(int year, int month) =>
      _db.watchTotalByMonth(year, month);

  @override
  Stream<Map<String, double>> watchCategoryTotals(int year, int month) =>
      _db.watchCategoryTotals(year, month);
}
