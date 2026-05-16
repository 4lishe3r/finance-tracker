import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/expense_entity.dart';
import '../../../providers/providers.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  String _filterCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(allExpensesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: const Text('Expenses'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
              ),
            ],
          ),
          allAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (expenses) {
              final filtered = _filterCategory == 'All'
                  ? expenses
                  : expenses
                      .where((e) => e.category == _filterCategory)
                      .toList();

              if (filtered.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No expenses found.')),
                );
              }

              // Group by month
              final grouped = <String, List<ExpenseEntity>>{};
              for (final e in filtered) {
                final key = DateFormat.yMMMM().format(e.date);
                grouped.putIfAbsent(key, () => []).add(e);
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entries = grouped.entries.toList();
                      final entry = entries[index];
                      return _MonthGroup(
                        month: entry.key,
                        expenses: entry.value,
                        onDelete: (id) => ref
                            .read(expenseRepositoryProvider)
                            .deleteExpense(id),
                        onEdit: (e) =>
                            context.go('/expenses/edit/${e.id}', extra: e),
                      );
                    },
                    childCount: grouped.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/expenses/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => _FilterSheet(
        selected: _filterCategory,
        onSelected: (cat) {
          setState(() => _filterCategory = cat);
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
    );
  }
}

class _MonthGroup extends StatelessWidget {
  final String month;
  final List<ExpenseEntity> expenses;
  final void Function(int id) onDelete;
  final void Function(ExpenseEntity e) onEdit;

  const _MonthGroup({
    required this.month,
    required this.expenses,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final total =
        expenses.fold(0.0, (s, e) => s + e.amount);
    final fmt = NumberFormat.currency(symbol: '\$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(month,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(fmt.format(total),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        ...expenses.map((e) => _ExpenseTile(
              expense: e,
              onDelete: () => onDelete(e.id!),
              onEdit: () => onEdit(e),
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseEntity expense;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ExpenseTile({
    required this.expense,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '');
    return Dismissible(
      key: Key('expense_${expense.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            child: Text(expense.category[0].toUpperCase()),
          ),
          title: Text(expense.title),
          subtitle: Text(
            '${expense.category} · ${DateFormat.MMMd().format(expense.date)}',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${expense.currency} ${fmt.format(expense.amount)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (expense.note != null && expense.note!.isNotEmpty)
                Text(
                  expense.note!,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          onTap: onEdit,
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final String selected;
  final void Function(String) onSelected;

  const _FilterSheet({required this.selected, required this.onSelected});

  static const _categories = [
    'All', 'Food & Dining', 'Transport', 'Shopping',
    'Entertainment', 'Health', 'Utilities', 'Education', 'Travel', 'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(16),
        children: [
          Text('Filter by Category',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._categories.map((cat) => ListTile(
                title: Text(cat),
                trailing: cat == selected
                    ? const Icon(Icons.check_circle)
                    : null,
                onTap: () => onSelected(cat),
              )),
        ],
      ),
    );
  }
}
