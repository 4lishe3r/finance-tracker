class CurrencyRateModel {
  final String base;
  final String date;
  final Map<String, double> rates;

  const CurrencyRateModel({
    required this.base,
    required this.date,
    required this.rates,
  });

  factory CurrencyRateModel.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    return CurrencyRateModel(
      base: json['base'] as String? ?? '',
      date: json['date'] as String? ?? '',
      rates: rawRates.map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

  Map<String, dynamic> toJson() => {
        'base': base,
        'date': date,
        'rates': rates,
      };

  @override
  String toString() => 'CurrencyRateModel(base: $base, date: $date, rates: $rates)';
}

