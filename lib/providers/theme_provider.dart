import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import 'providers.dart';

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final stored = prefs.getString(AppConstants.prefThemeKey);
    return _parse(stored);
  }

  ThemeMode _parse(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark, // dark по умолчанию
    };
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final key = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      _ => 'system',
    };
    await prefs.setString(AppConstants.prefThemeKey, key);
    state = AsyncData(mode);
  }
}

final themeModeNotifierProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// Convenience sync provider with fallback
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeModeNotifierProvider).valueOrNull ?? ThemeMode.system;
});

// ── Budget & Currency Prefs ────────────────────────────────────────────────

class UserPrefsNotifier extends AsyncNotifier<UserPrefs> {
  @override
  Future<UserPrefs> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return UserPrefs(
      currency: prefs.getString(AppConstants.prefCurrencyKey) ??
          AppConstants.defaultCurrency,
      monthlyBudget: prefs.getDouble(AppConstants.prefBudgetKey) ?? 1000.0,
      userName: prefs.getString(AppConstants.prefNameKey) ?? 'User',
    );
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(AppConstants.prefCurrencyKey, currency);
    state = AsyncData(state.value!.copyWith(currency: currency));
  }

  Future<void> setBudget(double budget) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setDouble(AppConstants.prefBudgetKey, budget);
    state = AsyncData(state.value!.copyWith(monthlyBudget: budget));
  }

  Future<void> setUserName(String name) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(AppConstants.prefNameKey, name);
    state = AsyncData(state.value!.copyWith(userName: name));
  }
}

class UserPrefs {
  final String currency;
  final double monthlyBudget;
  final String userName;

  const UserPrefs({
    required this.currency,
    required this.monthlyBudget,
    required this.userName,
  });

  UserPrefs copyWith({String? currency, double? monthlyBudget, String? userName}) =>
      UserPrefs(
        currency: currency ?? this.currency,
        monthlyBudget: monthlyBudget ?? this.monthlyBudget,
        userName: userName ?? this.userName,
      );
}

final userPrefsProvider =
    AsyncNotifierProvider<UserPrefsNotifier, UserPrefs>(UserPrefsNotifier.new);
