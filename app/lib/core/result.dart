

import 'network/api_exception.dart';

sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T get valueOrThrow => switch (this) {
    Ok<T>(value: final v) => v,
    Err<T>(exception: final e) => throw e,
  };

  ApiException? get errorOrNull => switch (this) {
    Ok() => null,
    Err<T>(exception: final e) => e,
  };

  R when<R>({
    required R Function(T value) ok,
    required R Function(ApiException exception) err,
  }) => switch (this) {
    Ok<T>(value: final v) => ok(v),
    Err<T>(exception: final e) => err(e),
  };

  Result<U> map<U>(U Function(T value) transform) => switch (this) {
    Ok<T>(value: final v) => Ok(transform(v)),
    Err<T>(exception: final e) => Err(e),
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.exception);
  final ApiException exception;
}
