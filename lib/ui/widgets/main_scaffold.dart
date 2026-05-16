import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  static const _tabs = [
    (icon: Icons.dashboard_rounded, label: 'Dashboard', path: '/dashboard'),
    (icon: Icons.receipt_long_rounded, label: 'Expenses', path: '/expenses'),
    (icon: Icons.pie_chart_rounded, label: 'Budget', path: '/budget'),
    (icon: Icons.currency_exchange_rounded, label: 'Convert', path: '/converter'),
    (icon: Icons.group_rounded, label: 'Shared', path: '/shared'),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _selectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

