import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../providers/providers.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseEntity expense;
  const EditExpenseScreen({super.key, required this.expense});

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late String _category;
  late String _currency;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.expense.title);
    _amountCtrl =
        TextEditingController(text: widget.expense.amount.toString());
    _noteCtrl = TextEditingController(text: widget.expense.note ?? '');
    _category = widget.expense.category;
    _currency = widget.expense.currency;
    _date = widget.expense.date;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final updated = widget.expense.copyWith(
        title: _titleCtrl.text.trim(),
        amount: double.parse(_amountCtrl.text),
        category: _category,
        currency: _currency,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        date: _date,
      );
      await ref.read(expenseRepositoryProvider).updateExpense(updated);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
                        child: const Text('Delete')),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await ref
                    .read(expenseRepositoryProvider)
                    .deleteExpense(widget.expense.id!);
                if (mounted) context.go('/expenses');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(labelText: 'Amount'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _currency,
                      items: AppConstants.currencies
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _currency = v!),
                      decoration: const InputDecoration(labelText: 'Currency'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                items: AppConstants.expenseCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat.yMMMMd().format(_date)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration:
                    const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Update Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

