class AppConstants {
  static const String currencyApiBase = 'https://api.frankfurter.app';
  static const String exchangeRateApiKey = 'b8104b4164bf00ca6292e9de';
  static const String exchangeRateApiBase = 'https://v6.exchangerate-api.com/v6';

  static const List<String> currencies = [
    'USD', 'EUR', 'KZT', 'RUB', 'GBP', 'JPY', 'CNY', 'AED',
    'CHF', 'CAD', 'AUD', 'INR', 'TRY', 'KRW', 'SGD', 'HKD',
  ];

  static const List<String> expenseCategories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Entertainment',
    'Health',
    'Utilities',
    'Education',
    'Travel',
    'Other',
  ];

  static const String defaultCurrency = 'USD';
  static const String prefThemeKey = 'theme_mode';
  static const String prefCurrencyKey = 'default_currency';
  static const String prefBudgetKey = 'monthly_budget';
  static const String prefNameKey = 'user_name';
}

