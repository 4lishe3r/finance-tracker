import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/remote/currency_service.dart';
import '../models/currency_rate_model.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyService _service;

  CurrencyRepositoryImpl(this._service);

  static const _apiBase = AppConstants.exchangeRateApiBase;
  static const _apiKey = AppConstants.exchangeRateApiKey;
  static const _corsProxy = 'https://corsproxy.io/';

  String _url(String path) => kIsWeb
      ? '$_corsProxy${Uri.encodeFull('$_apiBase$path')}'
      : '$_apiBase$path';

  @override
  Future<Map<String, double>> getRates(String baseCurrency) async {
    final uri = Uri.parse(_url('/$_apiKey/latest/$baseCurrency'));
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final rawRates = data['conversion_rates'] as Map<String, dynamic>? ?? {};

      return Map.fromEntries(
        AppConstants.currencies
            .where((c) => rawRates.containsKey(c))
            .map((c) => MapEntry(c, (rawRates[c] as num).toDouble())),
      );
    }
    throw Exception('Failed to load rates: ${response.statusCode}');
  }

  @override
  Future<double> convert({
    required double amount,
    required String from,
    required String to,
  }) async {
    if (from == to) return amount;
    final uri = Uri.parse(_url('/$_apiKey/pair/$from/$to/$amount'));
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return (data['conversion_result'] as num).toDouble();
    }
    throw Exception('Conversion failed: ${response.statusCode}');
  }
}

