

import 'package:dio/dio.dart';
import '../../models/credential.dart';
import 'auth_interceptor.dart';
import 'retry_interceptor.dart';

const String _appVersion = '0.1.0';

Dio buildClient({
  required String baseUrl,
  required BearerCredential credential,
  Map<String, String> extraHeaders = const {},
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'User-Agent': 'HiveHub/$_appVersion', ...extraHeaders},
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(credential: credential),
    RedactingLogInterceptor(),
    RetryInterceptor(),
  ]);

  return dio;
}
