

import 'package:dio/dio.dart';
import '../../models/credential.dart';

class AuthInterceptor extends Interceptor {
  const AuthInterceptor({required this.credential});

  final BearerCredential credential;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer ${credential.token}';
    options.extra['_redactedAuth'] = true;
    handler.next(options);
  }
}

class RedactingLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    assert(() {
      final headers = Map<String, dynamic>.from(options.headers);
      if (options.extra['_redactedAuth'] == true) {
        headers['Authorization'] = '[REDACTED]';
      }
      // ignore: avoid_print
      print('→ ${options.method} ${options.uri}  headers: $headers');
      return true;
    }());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('← ${response.statusCode} ${response.requestOptions.uri}');
      return true;
    }());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('✗ ${err.response?.statusCode} ${err.requestOptions.uri}: ${err.message}');
      return true;
    }());
    handler.next(err);
  }
}
