

import 'package:flutter/material.dart';
import '../shared/theme.dart';
import 'app_pressable.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  bool get _enabled => onTap != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;

    return AppPressable(
      enabled: _enabled,
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: _enabled ? 1.0 : 0.30,
        duration: HHMotion.fast,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: hh.accent,
            borderRadius: HHRadius.buttonBr(),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF000000)),
                  ),
                )
              : Text(
                  label,
                  style: HHTextStyles.headline(const Color(0xFF000000)),
                ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;

    return AppPressable(
      enabled: onTap != null,
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: hh.bgElevated2,
          borderRadius: HHRadius.buttonBr(),
        ),
        alignment: Alignment.center,
        child: Text(label, style: hh.headline()),
      ),
    );
  }
}

class TextActionButton extends StatelessWidget {
  const TextActionButton({super.key, required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    return AppPressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HHSpacing.md,
          vertical: HHSpacing.sm,
        ),
        child: Text(label, style: hh.body().copyWith(color: hh.accent)),
      ),
    );
  }
}
