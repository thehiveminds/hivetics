

sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => 'ApiException: $message';
}

final class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Token invalid or expired']);
}

final class ForbiddenException extends ApiException {
  const ForbiddenException([super.message = 'Token lacks required permission']);
}

final class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Resource not found']);
}

final class RateLimitedException extends ApiException {
  const RateLimitedException({
    String message = 'Rate limit exceeded',
    this.retryAfterSeconds,
  }) : super(message);

  final int? retryAfterSeconds;
}

final class NetworkException extends ApiException {
  const NetworkException([super.message = 'Network unavailable']);
}

final class UnknownException extends ApiException {
  const UnknownException([super.message = 'An unexpected error occurred']);

  factory UnknownException.fromError(Object e) =>
      UnknownException(e.toString());
}

ApiException apiExceptionFromHttpStatus(
  int statusCode, {
  String? body,
  int? retryAfter,
}) {
  return switch (statusCode) {
    401 => const UnauthorizedException(),
    403 => const ForbiddenException(),
    404 => const NotFoundException(),
    429 => RateLimitedException(retryAfterSeconds: retryAfter),
    _ when statusCode >= 500 =>
      UnknownException('Server error $statusCode'),
    _ => UnknownException('HTTP $statusCode'),
  };
}
