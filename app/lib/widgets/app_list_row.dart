

import 'package:flutter/material.dart';
import '../shared/theme.dart';
import 'app_pressable.dart';

class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leadingIconColor,
    this.leadingWidget,
    this.trailingValue,
    this.trailingWidget,
    this.showChevron = false,
    this.onTap,
    this.titleStyle,
    this.subtitleStyle,
  });

  final String title;
  final String? subtitle;

  /// Icon inside the 28×28 icon tile (radius 7, colour on 12% tint).
  final IconData? leadingIcon;
  final Color? leadingIconColor;

  /// Overrides the icon tile entirely (e.g. ProviderBadge).
  final Widget? leadingWidget;

  /// Optional footnote textTertiary string on the trailing side.
  final String? trailingValue;

  /// Overrides trailing entirely (e.g. AppStatusPill, CupertinoSwitch).
  final Widget? trailingWidget;

  final bool showChevron;
  final VoidCallback? onTap;

  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HHSpacing.lg,
        vertical: HHSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Leading
          if (leadingWidget != null) ...[
            leadingWidget!,
            const SizedBox(width: HHSpacing.md),
          ] else if (leadingIcon != null) ...[
            _IconTile(icon: leadingIcon!, color: leadingIconColor ?? hh.textTertiary, hh: hh),
            const SizedBox(width: HHSpacing.md),
          ],

          // Centre — title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: titleStyle ?? hh.headline(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: subtitleStyle ?? hh.subhead(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Trailing
          if (trailingWidget != null) ...[
            const SizedBox(width: HHSpacing.sm),
            trailingWidget!,
          ] else if (trailingValue != null) ...[
            const SizedBox(width: HHSpacing.sm),
            Text(trailingValue!, style: hh.footnote()),
          ],

          if (showChevron) ...[
            const SizedBox(width: HHSpacing.xs),
            Icon(Icons.chevron_right, color: hh.textTertiary, size: 14),
          ],
        ],
      ),
    );

    if (onTap != null) {
      content = AppPressable(onTap: onTap, child: content);
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: HHSpacing.rowHeight),
      child: content,
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.color, required this.hh});
  final IconData icon;
  final Color color;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: HHRadius.iconTileBr(),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 16, color: color),
    );
  }
}
