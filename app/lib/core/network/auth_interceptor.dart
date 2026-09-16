

import 'package:dio/dio.dart';
import '../../models/credential.dart';

/// Header set for a credential. Both shapes are plain headers — never a
/// query param, never a POST body field (Porkbun's old auth style).
Map<String, String> credentialHeaders(Credential credential) => switch (credential) {
      BearerCredential(:final token) => {
          'Authorization': _formatAuthToken(token),
        },
      KeyPairCredential(:final apiKey, :final secretKey) => {
          'X-API-Key': apiKey,
          'X-Secret-API-Key': secretKey,
        },
      OAuthCredential(:final accessToken) => {
          'Authorization': 'Bearer $accessToken',
        },
    };

String _formatAuthToken(String token) {
  final trimmed = token.trim();
  if (trimmed.startsWith('sso-key ') || trimmed.startsWith('Bearer ')) {
    return trimmed;
  }
  if (trimmed.contains(':')) {
    return 'sso-key $trimmed';
  }
  return 'Bearer $trimmed';
}

class AuthInterceptor extends Interceptor {
  const AuthInterceptor({required this.credential});

  final Credential credential;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final defHeaders = credentialHeaders(credential);
    for (final entry in defHeaders.entries) {
      if (!options.headers.containsKey(entry.key)) {
        options.headers[entry.key] = entry.value;
      }
    }
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
        for (final key in const [
          'Authorization',
          'X-API-Key',
          'X-Secret-API-Key',
        ]) {
          if (headers.containsKey(key)) headers[key] = '[REDACTED]';
        }
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
