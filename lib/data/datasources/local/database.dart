import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

part 'database.g.dart';

// ──────────────────────────────────────────────
// TABLE DEFINITIONS
// ──────────────────────────────────────────────

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  RealColumn get amount => real()();
  TextColumn get category => text()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ──────────────────────────────────────────────
// DATABASE
// ──────────────────────────────────────────────

@DriftDatabase(tables: [Expenses])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // ── EXPENSES DAO methods ──

  Stream<List<Expense>> watchAllExpenses() =>
      (select(expenses)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  Future<List<Expense>> getExpensesByMonth(int year, int month) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    return (select(expenses)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<int> insertExpense(ExpensesCompanion entry) =>
      into(expenses).insert(entry);

  Future<bool> updateExpense(Expense entry) => update(expenses).replace(entry);

  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((t) => t.id.equals(id))).go();

  Future<double> getTotalByMonth(int year, int month) async {
    final all = await (select(expenses)).get();
    final filtered = all.where(
      (e) => e.date.year == year && e.date.month == month,
    );
    return filtered.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  Stream<double> watchTotalByMonth(int year, int month) {
    return watchAllExpenses().map((list) {
      final filtered = list.where(
        (e) => e.date.year == year && e.date.month == month,
      );
      return filtered.fold<double>(0.0, (sum, e) => sum + e.amount);
    });
  }

  Stream<Map<String, double>> watchCategoryTotals(int year, int month) {
    return watchAllExpenses().map((list) {
      final filtered = list.where((e) {
        return e.date.year == year && e.date.month == month;
      });
      final map = <String, double>{};
      for (final e in filtered) {
        map[e.category] = (map[e.category] ?? 0) + e.amount;
      }
      return map;
    });
  }
}

QueryExecutor _openConnection() {
  if (kIsWeb) {
    return driftDatabase(
      name: 'finance_tracker',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
        onResult: (result) {
          if (result.missingFeatures.isNotEmpty) {
            debugPrint('Drift missing features: ${result.missingFeatures}');
          }
        },
      ),
    );
  }
  // Android / iOS / desktop — просто SQLite без web-опций
  return driftDatabase(name: 'finance_tracker');
}

// Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Override in main()');
});
