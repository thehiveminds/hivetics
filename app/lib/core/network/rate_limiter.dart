import 'package:dio/dio.dart';


import 'dart:async';

enum ProviderRateLimit {
  /// ~3000/min — not a practical constraint.
  vercel(maxRequests: 3000, windowSeconds: 60),

  /// 500/min.
  netlify(maxRequests: 500, windowSeconds: 60),

  /// 1200 / 5 min — tightest. CF Pages + DNS + Registrar share this quota.
  cloudflare(maxRequests: 1200, windowSeconds: 300),

  /// ~20k/month ≈ 660/day. Conservative 60/min burst.
  godaddy(maxRequests: 60, windowSeconds: 60),

  /// Conservative 60/min bucket. Backs off on 429 via RetryInterceptor.
  porkbun(maxRequests: 60, windowSeconds: 60);

  const ProviderRateLimit({
    required this.maxRequests,
    required this.windowSeconds,
  });

  final int maxRequests;
  final int windowSeconds;
}

/// Token-bucket rate limiter per provider.
/// Also enforces a global max-4-concurrent cap.
class RateLimiter {
  RateLimiter._();
  static final RateLimiter instance = RateLimiter._();

  static const int _maxConcurrent = 4;
  int _currentConcurrent = 0;
  final _concurrentCompleter = <Completer<void>>[];

  final _buckets = <String, _TokenBucket>{};

  _TokenBucket _bucket(ProviderRateLimit policy) {
    return _buckets.putIfAbsent(
      policy.name,
      () => _TokenBucket(
        maxTokens: policy.maxRequests,
        refillWindowMs: policy.windowSeconds * 1000,
      ),
    );
  }

  /// Acquires a slot. Awaits until both the provider bucket and the global
  /// concurrent cap allow the request through.
  Future<void> acquire(ProviderRateLimit policy) async {
    await _bucket(policy).acquire();
    await _acquireGlobalSlot();
  }

  /// Release the global concurrent slot after the request completes.
  /// If a waiter is queued, ownership of the slot is passed directly to the waiter.
  void release() {
    if (_concurrentCompleter.isNotEmpty) {
      final next = _concurrentCompleter.removeAt(0);
      next.complete();
    } else if (_currentConcurrent > 0) {
      _currentConcurrent--;
    }
  }

  Future<void> _acquireGlobalSlot() async {
    if (_currentConcurrent < _maxConcurrent) {
      _currentConcurrent++;
      return;
    }
    final c = Completer<void>();
    _concurrentCompleter.add(c);
    await c.future;
  }
}

class _TokenBucket {
  _TokenBucket({required this.maxTokens, required this.refillWindowMs})
      : _tokens = maxTokens,
        _lastRefill = DateTime.now().millisecondsSinceEpoch;

  final int maxTokens;
  final int refillWindowMs;
  int _tokens;
  int _lastRefill;

  Future<void> acquire() async {
    _refill();
    while (_tokens <= 0) {
      await Future<void>.delayed(Duration(milliseconds: refillWindowMs ~/ 10));
      _refill();
    }
    _tokens--;
  }

  void _refill() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastRefill >= refillWindowMs) {
      _tokens = maxTokens;
      _lastRefill = now;
    }
  }
}

/// Dio interceptor that routes every request through [RateLimiter] for its
/// provider, and always releases the global concurrency slot — on success,
/// on error, and on a cancelled request alike.
class RateLimitInterceptor extends Interceptor {
  RateLimitInterceptor({required this.policy});

  final ProviderRateLimit policy;

  static const _slotHeldKey = '_rateLimitSlotHeld';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await RateLimiter.instance.acquire(policy);
    options.extra[_slotHeldKey] = true;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _release(response.requestOptions);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _release(err.requestOptions);
    handler.next(err);
  }

  void _release(RequestOptions options) {
    if (options.extra.remove(_slotHeldKey) == true) {
      RateLimiter.instance.release();
    }
  }
}
