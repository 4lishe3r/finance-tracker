import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/expenses/expenses_screen.dart';
import '../screens/expenses/add_expense_screen.dart';
import '../screens/expenses/edit_expense_screen.dart';
import '../screens/budget/budget_screen.dart';
import '../screens/converter/converter_screen.dart';
import '../screens/shared_expenses/shared_expenses_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/main_scaffold.dart';
import '../../domain/entities/expense_entity.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/expenses',
            name: 'expenses',
            builder: (_, __) => const ExpensesScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-expense',
                builder: (_, __) => const AddExpenseScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'edit-expense',
                builder: (context, state) {
                  final expense = state.extra as ExpenseEntity;
                  return EditExpenseScreen(expense: expense);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/budget',
            name: 'budget',
            builder: (_, __) => const BudgetScreen(),
          ),
          GoRoute(
            path: '/converter',
            name: 'converter',
            builder: (_, __) => const ConverterScreen(),
          ),
          GoRoute(
            path: '/shared',
            name: 'shared-expenses',
            builder: (_, __) => const SharedExpensesScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
  );
}
