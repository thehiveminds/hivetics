

import 'package:dio/dio.dart';
import '../../models/credential.dart';
import 'auth_interceptor.dart';
import 'rate_limiter.dart';
import 'retry_interceptor.dart';

const String _appVersion = '0.1.0';

Dio buildClient({
  required String baseUrl,
  required Credential credential,
  required ProviderRateLimit rateLimit,
  Map<String, String> extraHeaders = const {},
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'User-Agent': 'Hivetics/$_appVersion', ...extraHeaders},
    ),
  );

  dio.interceptors.addAll([
    RateLimitInterceptor(policy: rateLimit),
    AuthInterceptor(credential: credential),
    RedactingLogInterceptor(),
    RetryInterceptor(),
  ]);

  return dio;
}
