import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../data/datasources/remote/shared_expense_datasource.dart';
import '../../../providers/providers.dart';
import '../../../providers/theme_provider.dart';

class SharedExpensesScreen extends ConsumerStatefulWidget {
  const SharedExpensesScreen({super.key});

  @override
  ConsumerState<SharedExpensesScreen> createState() =>
      _SharedExpensesScreenState();
}

class _SharedExpensesScreenState
    extends ConsumerState<SharedExpensesScreen> {
  String _householdId = '';
  final _idCtrl = TextEditingController();
  bool _joined = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => _AddSharedExpenseDialog(
        householdId: _householdId,
        onAdd: (expense) async {
          await ref
              .read(sharedExpenseDatasourceProvider)
              .addSharedExpense(expense);

          ref.invalidate(sharedExpensesProvider(_householdId));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sharedAsync =
        ref.watch(sharedExpensesProvider(_householdId));
    final prefsAsync = ref.watch(userPrefsProvider);

    return Scaffold(
      body: !_joined
          ? _buildJoinScreen()
          : CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: const Text('Shared Expenses'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  avatar: const Icon(Icons.home, size: 16),
                  label: Text(_householdId),
                  onDeleted: () => setState(() {
                    _joined = false;
                    _householdId = '';
                    _idCtrl.clear();
                  }),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: sharedAsync.when(
              loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) =>
                  SliverFillRemaining(child: Center(child: Text('Error: $e'))),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_outlined, size: 64),
                          SizedBox(height: 16),
                          Text('No shared expenses yet.'),
                          Text('Add one to split with your household!'),
                        ],
                      ),
                    ),
                  );
                }

                final total =
                    expenses.fold(0.0, (s, e) => s + e.amount);
                final perPerson = total / 2; // 2 people
                final fmt = NumberFormat.currency(symbol: '\$');

                return SliverList(
                  delegate: SliverChildListDelegate([

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: [
                            _InfoColumn(
                                label: 'Total',
                                value: fmt.format(total)),
                            _InfoColumn(
                                label: 'Per Person',
                                value: fmt.format(perPerson)),
                            _InfoColumn(
                                label: 'Expenses',
                                value: '${expenses.length}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...expenses.map(
                      (e) => _SharedExpenseTile(
                        expense: e,
                        onDelete: () async {
                          await ref
                              .read(sharedExpenseDatasourceProvider)
                              .deleteSharedExpense(e.id, _householdId);
                          ref.invalidate(
                              sharedExpensesProvider(_householdId));
                        },
                      ),
                    ),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _joined
          ? FloatingActionButton.extended(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Shared'),
            )
          : null,
    );
  }

  Widget _buildJoinScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Enter Household ID',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Share this ID with your household members to see shared expenses',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _idCtrl,
              decoration: const InputDecoration(
                labelText: 'Household ID',
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                final id = _idCtrl.text.trim();
                if (id.isNotEmpty) {
                  setState(() {
                    _householdId = id;
                    _joined = true;
                  });
                }
              },
              icon: const Icon(Icons.login),
              label: const Text('Join'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                final newId = 'household-${DateTime.now().millisecondsSinceEpoch}';
                _idCtrl.text = newId;
                setState(() {
                  _householdId = newId;
                  _joined = true;
                });
              },
              icon: const Icon(Icons.add_home),
              label: const Text('Create new household'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SharedExpenseTile extends StatelessWidget {
  final SharedExpense expense;
  final VoidCallback onDelete;

  const _SharedExpenseTile({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '');
    final perPerson = expense.amount / (expense.splitWith.length + 1);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.group)),
        title: Text(expense.title),
        subtitle: Text(
          'Paid by ${expense.paidBy} · '
          '${DateFormat.MMMd().format(expense.date)}\n'
          '${expense.currency} ${fmt.format(perPerson)} / person',
        ),
        isThreeLine: true,
        trailing: SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${expense.currency} ${fmt.format(expense.amount)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddSharedExpenseDialog extends ConsumerStatefulWidget {
  final String householdId;
  final void Function(SharedExpense) onAdd;

  const _AddSharedExpenseDialog({
    required this.householdId,
    required this.onAdd,
  });

  @override
  ConsumerState<_AddSharedExpenseDialog> createState() =>
      _AddSharedExpenseDialogState();
}

class _AddSharedExpenseDialogState
    extends ConsumerState<_AddSharedExpenseDialog> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _paidByCtrl = TextEditingController(text: 'Me');

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _paidByCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Shared Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _amountCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount (USD)'),
          ),
          TextField(
            controller: _paidByCtrl,
            decoration: const InputDecoration(labelText: 'Paid by'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleCtrl.text.trim();
            final amount = double.tryParse(_amountCtrl.text);
            if (title.isEmpty || amount == null || amount <= 0) return;

            widget.onAdd(SharedExpense(
              id: const Uuid().v4(),
              title: title,
              amount: amount,
              currency: 'USD',
              paidBy: _paidByCtrl.text.trim(),
              splitWith: ['Partner'],
              date: DateTime.now(),
              householdId: widget.householdId,
            ));
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

