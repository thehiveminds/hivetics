import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/haptics.dart';
import '../shared/theme.dart';

class CopyableValue extends StatefulWidget {
  const CopyableValue({
    super.key,
    required this.value,
    this.label,
    this.maxLines = 1,
  });

  final String value;

  /// Optional visible label — if null, shows the raw value.
  final String? label;
  final int maxLines;

  @override
  State<CopyableValue> createState() => _CopyableValueState();
}

class _CopyableValueState extends State<CopyableValue> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    HHHaptics.lightImpact();
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;

    return GestureDetector(
      onTap: _copy,
      behavior: HitTestBehavior.opaque,
      child: AnimatedSwitcher(
        duration: HHMotion.fast,
        child: _copied
            ? Text(
                'Copied',
                key: const ValueKey('copied'),
                style: hh.mono().copyWith(color: hh.accent),
              )
            : Text(
                widget.label ?? widget.value,
                key: const ValueKey('value'),
                style: hh.mono(),
                maxLines: widget.maxLines,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}
