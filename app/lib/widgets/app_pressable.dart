

import 'package:flutter/material.dart';
import '../shared/haptics.dart';
import '../shared/theme.dart';

class AppPressable extends StatefulWidget {
  const AppPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _pressed = false;

  void _handleTapDown(_) {
    if (!widget.enabled) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(_) {
    if (!widget.enabled) return;
    setState(() => _pressed = false);
  }

  void _handleTapCancel() => setState(() => _pressed = false);

  void _handleTap() {
    if (!widget.enabled || widget.onTap == null) return;
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    if (!disableAnimations) HHHaptics.lightImpact();
    widget.onTap!();
  }

  void _handleLongPress() {
    if (!widget.enabled || widget.onLongPress == null) return;
    HHHaptics.mediumImpact();
    widget.onLongPress!();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final animate = !disableAnimations;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      onLongPress: widget.onLongPress != null ? _handleLongPress : null,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: HHSpacing.rowHeight,
          minHeight: HHSpacing.rowHeight,
        ),
        child: AnimatedScale(
          scale: animate && _pressed ? HHMotion.pressScale : 1.0,
          duration: HHMotion.pressDown,
          curve: HHMotion.defaultCurve,
          child: AnimatedOpacity(
            opacity: animate && _pressed ? HHMotion.pressOpacity : 1.0,
            duration: HHMotion.pressDown,
            curve: HHMotion.defaultCurve,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
