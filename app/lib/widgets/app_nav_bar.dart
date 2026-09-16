import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../shared/theme.dart';
import 'app_pressable.dart';

class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.title,
    this.trailing,
    this.bottom,
    this.pinned = true,
    this.showBackButton,
  });

  final String title;

  /// Icon-only action widgets.
  final List<Widget>? trailing;

  /// Widget that lives below the title (e.g. search field, filter chips).
  final PreferredSizeWidget? bottom;

  final bool pinned;

  /// Explicit control of back button.
  /// Set to false on root tab screens so modal sheets never cause a back button to appear.
  final bool? showBackButton;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final route = ModalRoute.of(context);
    final canPop = showBackButton ??
        (route != null && route.canPop && !route.isFirst);

    return SliverAppBar(
      pinned: pinned,
      floating: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 52,
      centerTitle: canPop,
      titleSpacing: canPop ? 0 : HHSpacing.screenPadding,
      title: Text(
        title,
        style: hh.headline().copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: canPop
          ? Center(
              child: AppPressable(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: hh.bgElevated.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hh.cardBorder.withValues(alpha: 0.6),
                      width: 0.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    LucideIcons.chevronLeft,
                    color: hh.textPrimary,
                    size: 18,
                  ),
                ),
              ),
            )
          : null,
      actions: trailing != null
          ? [
              ...trailing!.map((w) => Padding(
                    padding: const EdgeInsets.only(right: HHSpacing.sm),
                    child: Center(child: w),
                  )),
              const SizedBox(width: HHSpacing.xs),
            ]
          : null,
      bottom: bottom,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: hh.bgBase.withValues(alpha: 0.80),
              border: Border(
                bottom: BorderSide(
                  color: hh.separator.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
