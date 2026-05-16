// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$CurrencyService extends CurrencyService {
  _$CurrencyService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = CurrencyService;

  @override
  Future<Response<Map<String, dynamic>>> getLatestRates(
      {required String from}) {
    final Uri $url = Uri.parse('/latest');
    final Map<String, dynamic> $params = <String, dynamic>{'from': from};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> convertAmount({
    required double amount,
    required String from,
    required String to,
  }) {
    final Uri $url = Uri.parse('/latest/${amount}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'from': from,
      'to': to,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }
}
