import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/expense_entity.dart';
import '../../../providers/providers.dart';
import '../../../providers/theme_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final prefsAsync = ref.watch(userPrefsProvider);
    final totalAsync = ref.watch(monthlyTotalProvider((now.year, now.month)));
    final categoryAsync =
        ref.watch(categoryTotalsProvider((now.year, now.month)));
    final allExpensesAsync = ref.watch(allExpensesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: prefsAsync.when(
              data: (p) => Text('Hi, ${p.userName} 👋'),
              loading: () => const Text('Finance Tracker'),
              error: (_, __) => const Text('Finance Tracker'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                onPressed: () => context.go('/settings'),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                prefsAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (prefs) => totalAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                    data: (total) =>
                        _BudgetCard(total: total, budget: prefs.monthlyBudget),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Spending by Category',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                categoryAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (cats) => cats.isEmpty
                      ? const _EmptyState(message: 'No expenses this month')
                      : _CategoryPieChart(categories: cats),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go('/expenses'),
                      child: const Text('See all'),
                    ),
                  ],
                ),
                allExpensesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (expenses) {
                    final recent = expenses.take(5).toList();
                    if (recent.isEmpty) {
                      return const _EmptyState(
                          message: 'No transactions yet. Add one!');
                    }
                    return Column(
                      children: [
                        ...recent.map((e) => _TransactionTile(expense: e)),
                        const SizedBox(height: 80),
                      ],
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/expenses/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final double total;
  final double budget;

  const _BudgetCard({required this.total, required this.budget});

  @override
  Widget build(BuildContext context) {
    final progress = (total / budget).clamp(0.0, 1.0);
    final remaining = budget - total;
    final color = progress < 0.7
        ? Colors.green
        : progress < 0.9
            ? Colors.orange
            : Colors.red;
    final fmt = NumberFormat.currency(symbol: '\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Budget',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fmt.format(total),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Text(
                  'of ${fmt.format(budget)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              color: color,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              remaining >= 0
                  ? '${fmt.format(remaining)} remaining'
                  : '${fmt.format(-remaining)} over budget!',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final Map<String, double> categories;
  const _CategoryPieChart({required this.categories});

  static const _colors = [
    Color(0xFF6C63FF), Color(0xFFFF6584), Color(0xFF43C6AC),
    Color(0xFFF7971E), Color(0xFF56CCF2), Color(0xFFEB5757),
    Color(0xFF6FCF97), Color(0xFF9B51E0),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = categories.entries.toList();
    final total = entries.fold(0.0, (s, e) => s + e.value);

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: List.generate(entries.length, (i) {
                  final pct = entries[i].value / total * 100;
                  return PieChartSectionData(
                    value: entries[i].value,
                    color: _colors[i % _colors.length],
                    title: '${pct.toStringAsFixed(0)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                }),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entries.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _colors[i % _colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entries[i].key,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final ExpenseEntity expense;
  const _TransactionTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(expense.category.isNotEmpty
              ? expense.category[0].toUpperCase()
              : '?'),
        ),
        title: Text(expense.title),
        subtitle: Text(
          '${expense.category} · ${DateFormat.yMMMd().format(expense.date)}',
        ),
        trailing: Text(
          '${expense.currency} ${fmt.format(expense.amount)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  )),
        ),
      );
}

