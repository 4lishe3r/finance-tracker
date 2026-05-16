import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/providers.dart';
import '../../../providers/theme_provider.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  late TextEditingController _budgetCtrl;

  @override
  void initState() {
    super.initState();
    _budgetCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final prefsAsync = ref.watch(userPrefsProvider);
    final totalAsync = ref.watch(monthlyTotalProvider((now.year, now.month)));

    final months = List.generate(6, (i) {
      final d = DateTime(now.year, now.month - 5 + i);
      return d;
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.medium(title: Text('Budget')),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                prefsAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (prefs) {
                    _budgetCtrl.text = prefs.monthlyBudget.toStringAsFixed(0);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Monthly Budget Limit',
                                style:
                                    Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _budgetCtrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'Budget (${prefs.currency})',
                                      prefixIcon:
                                          const Icon(Icons.attach_money),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: () {
                                    final v = double.tryParse(_budgetCtrl.text);
                                    if (v != null) {
                                      ref
                                          .read(userPrefsProvider.notifier)
                                          .setBudget(v);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Budget saved!')),
                                      );
                                    }
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                prefsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (prefs) => totalAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (total) {
                      final remaining = prefs.monthlyBudget - total;
                      final fmt =
                          NumberFormat.currency(symbol: prefs.currency + ' ');
                      return Row(
                        children: [
                          Expanded(
                            child: _SummaryChip(
                              label: 'Spent',
                              value: fmt.format(total),
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SummaryChip(
                              label: remaining >= 0 ? 'Remaining' : 'Over',
                              value: fmt.format(remaining.abs()),
                              color: remaining >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                Text('Last 6 Months',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: _SixMonthChart(months: months),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SixMonthChart extends ConsumerWidget {
  final List<DateTime> months;
  const _SixMonthChart({required this.months});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futures = months
        .map((m) => ref.watch(monthlyTotalProvider((m.year, m.month))))
        .toList();

    final totals =
        futures.map((f) => f.valueOrNull ?? 0.0).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: List.generate(6, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: totals[i],
                color: Theme.of(context).colorScheme.primary,
                width: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final m = months[value.toInt()];
                return Text(
                  DateFormat.MMM().format(m),
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, _) => Text(
                '\$${value.toInt()}',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label,
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

