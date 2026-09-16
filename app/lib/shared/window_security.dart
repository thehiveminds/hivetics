import 'package:flutter/services.dart';

class WindowSecurity {
  static const _channel = MethodChannel('in.thehiveminds.hivehub/security');

  static Future<void> setSecure(bool secure) async {
    try {
      await _channel.invokeMethod<void>('setSecure', {'secure': secure});
    } catch (_) {
      // Gracefully ignore on platforms/environments without this channel
    }
  }
}
