import 'package:flutter/material.dart';
import '../shared/theme.dart';

class AppGroupedSection extends StatelessWidget {
  const AppGroupedSection({
    super.key,
    required this.children,
    this.header,
    this.headerColor,
    this.footer,
    this.margin = const EdgeInsets.symmetric(horizontal: HHSpacing.screenPadding),
  });

  /// Optional UPPERCASE caption2 / textTertiary header above the container.
  final String? header;

  /// Optional color override for the header.
  final Color? headerColor;

  /// Optional footnote / textTertiary footer below the container.
  final String? footer;

  final EdgeInsetsGeometry? margin;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;

    Widget section = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: HHSpacing.sm,
              bottom: HHSpacing.sm,
            ),
            child: Text(
              header!.toUpperCase(),
              style: hh.caption2().copyWith(color: headerColor),
            ),
          ),
        ],
        // Container
        ClipRRect(
          borderRadius: HHRadius.cardBr(),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: hh.bgElevated,
              borderRadius: HHRadius.cardBr(),
              boxShadow: hh.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildChildren(hh, children),
            ),
          ),
        ),
        if (footer != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: HHSpacing.sm,
              top: HHSpacing.sm,
            ),
            child: Text(footer!, style: hh.footnote()),
          ),
        ],
      ],
    );

    if (margin != null) {
      section = Padding(padding: margin!, child: section);
    }

    return section;
  }

  List<Widget> _buildChildren(HHTokens hh, List<Widget> items) {
    if (items.isEmpty) return [];
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(
          Padding(
            padding: const EdgeInsets.only(left: HHSpacing.lg),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: hh.separator,
            ),
          ),
        );
      }
    }
    return result;
  }
}
