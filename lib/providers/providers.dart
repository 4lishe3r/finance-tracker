import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../data/datasources/local/database.dart';
import '../data/datasources/remote/currency_service.dart';
import '../data/datasources/remote/shared_expense_datasource.dart';
import '../data/repositories/currency_repository_impl.dart';
import '../data/repositories/expense_repository_impl.dart';
import '../domain/entities/expense_entity.dart';
import '../domain/repositories/currency_repository.dart';
import '../domain/repositories/expense_repository.dart';


final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (_) => SharedPreferences.getInstance(),
);


final currencyServiceProvider = Provider<CurrencyService>(
  (_) => CurrencyService.create(),
);

final sharedExpenseDatasourceProvider = Provider<SharedExpenseDataSource>(
  (_) => SharedExpenseDataSourceFirestore(FirebaseFirestore.instance),
);


final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExpenseRepositoryImpl(db);
});

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  final service = ref.watch(currencyServiceProvider);
  return CurrencyRepositoryImpl(service);
});


final allExpensesProvider = StreamProvider<List<ExpenseEntity>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchAllExpenses();
});

final monthlyExpensesProvider =
    FutureProvider.family<List<ExpenseEntity>, (int, int)>((ref, args) {
  final (year, month) = args;
  return ref.watch(expenseRepositoryProvider).getExpensesByMonth(year, month);
});

final monthlyTotalProvider =
    StreamProvider.family<double, (int, int)>((ref, args) {
  final (year, month) = args;
  return ref.watch(expenseRepositoryProvider).watchTotalByMonth(year, month);
});

final categoryTotalsProvider =
    StreamProvider.family<Map<String, double>, (int, int)>((ref, args) {
  final (year, month) = args;
  return ref
      .watch(expenseRepositoryProvider)
      .watchCategoryTotals(year, month);
});


final exchangeRatesProvider =
    FutureProvider.family<Map<String, double>, String>((ref, base) {
  return ref.watch(currencyRepositoryProvider).getRates(base);
});

final currencyConversionProvider = FutureProvider.family<double,
    ({double amount, String from, String to})>((ref, args) {
  return ref.watch(currencyRepositoryProvider).convert(
        amount: args.amount,
        from: args.from,
        to: args.to,
      );
});


final sharedExpensesProvider =
    StreamProvider.family<List<SharedExpense>, String>((ref, householdId) {
  return ref
      .watch(sharedExpenseDatasourceProvider)
      .watchSharedExpenses(householdId);
});

