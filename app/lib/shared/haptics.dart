

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

abstract final class HHHaptics {
  /// Nav, filters, chips, segmented control — light selection feedback.
  static Future<void> selectionClick() =>
      HapticFeedback.selectionClick();

  /// Buttons and copy taps.
  static Future<void> lightImpact() =>
      HapticFeedback.lightImpact();

  /// Pull-to-refresh trigger.
  static Future<void> mediumImpact() =>
      HapticFeedback.mediumImpact();

  /// Subscribe success.
  static Future<void> heavyImpact() =>
      HapticFeedback.heavyImpact();

  /// Fire haptic only when animations are not disabled by accessibility settings.
  static Future<void> lightImpactIfEnabled(BuildContext context) async {
    if (MediaQuery.of(context).disableAnimations) return;
    await lightImpact();
  }

  static Future<void> selectionIfEnabled(BuildContext context) async {
    if (MediaQuery.of(context).disableAnimations) return;
    await selectionClick();
  }
}
