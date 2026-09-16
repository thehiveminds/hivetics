

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../shared/haptics.dart';
import '../shared/theme.dart';

class BottomTabBar extends StatelessWidget {
  const BottomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    _TabItem(icon: LucideIcons.layoutGrid, label: 'Sites'),
    _TabItem(icon: LucideIcons.gitBranch, label: 'Deploys'),
    _TabItem(icon: LucideIcons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 0.5, thickness: 0.5, color: hh.separator),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: hh.bgBase.withValues(alpha: 0.80),
              child: SizedBox(
                height: 49 + bottomPadding,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: Row(
                    children: List.generate(
                      _tabs.length,
                      (i) => Expanded(
                        child: _TabButton(
                          item: _tabs[i],
                          selected: currentIndex == i,
                          onTap: () {
                            HHHaptics.selectionClick();
                            onTap(i);
                          },
                          hh: hh,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TabItem {
  const _TabItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.hh,
  });

  final _TabItem item;
  final bool selected;
  final VoidCallback onTap;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    final color = selected ? hh.accent : hh.textTertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: HHTextStyles.caption(color).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
