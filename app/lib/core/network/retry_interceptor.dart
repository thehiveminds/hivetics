

import 'dart:math';
import 'package:dio/dio.dart';
import 'api_exception.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({this.maxRetries = 3});

  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final attempt = (err.requestOptions.extra['_retryCount'] as int?) ?? 0;

    final shouldRetry = attempt < maxRetries &&
        (statusCode == 429 || (statusCode != null && statusCode >= 500));

    if (!shouldRetry) {
      handler.next(err);
      return;
    }

    final retryAfter = _parseRetryAfter(err.response);
    final delay = retryAfter != null
        ? Duration(seconds: retryAfter)
        : Duration(milliseconds: (200 * pow(2, attempt)).toInt());

    await Future<void>.delayed(delay);

    final options = err.requestOptions.copyWith(
      extra: {
        ...err.requestOptions.extra,
        '_retryCount': attempt + 1,
      },
    );

    try {
      final response = await Dio().fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  int? _parseRetryAfter(Response? response) {
    if (response == null) return null;
    final raw = response.headers.value('retry-after') ??
        response.headers.value('x-ratelimit-reset');
    if (raw == null) return null;
    final value = int.tryParse(raw);
    if (value == null) return null;
    if (value > 1_000_000_000) {
      final secondsFromNow =
          value - DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return secondsFromNow.clamp(1, 300);
    }
    return value.clamp(1, 300);
  }
}

ApiException dioExceptionToApiException(DioException e) {
  final statusCode = e.response?.statusCode;
  if (statusCode != null) {
    final retryAfter = _parseRetryAfterFromError(e);
    return apiExceptionFromHttpStatus(statusCode, retryAfter: retryAfter);
  }
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return const NetworkException();
  }
  return UnknownException.fromError(e);
}

int? _parseRetryAfterFromError(DioException e) {
  final raw = e.response?.headers.value('retry-after') ??
      e.response?.headers.value('x-ratelimit-reset');
  return raw != null ? int.tryParse(raw) : null;
}
