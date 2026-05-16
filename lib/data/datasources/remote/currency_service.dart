import 'package:chopper/chopper.dart';

part 'currency_service.chopper.dart';

@ChopperApi(baseUrl: '/latest')
abstract class CurrencyService extends ChopperService {
  @Get()
  Future<Response<Map<String, dynamic>>> getLatestRates({
    @Query('from') required String from,
  });

  @Get(path: '/{amount}')
  Future<Response<Map<String, dynamic>>> convertAmount({
    @Path('amount') required double amount,
    @Query('from') required String from,
    @Query('to') required String to,
  });

  static CurrencyService create() {
    final client = ChopperClient(
      baseUrl: Uri.parse('https://api.frankfurter.app'),
      services: [_$CurrencyService()],
      converter: JsonConverter(),
      interceptors: [HttpLoggingInterceptor()],
    );
    return _$CurrencyService(client);
  }
}

