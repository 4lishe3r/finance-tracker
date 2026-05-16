abstract interface class CurrencyRepository {
  Future<Map<String, double>> getRates(String baseCurrency);
  Future<double> convert({
    required double amount,
    required String from,
    required String to,
  });
}

