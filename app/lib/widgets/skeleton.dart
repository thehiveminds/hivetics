

import 'package:flutter/material.dart';
import '../shared/theme.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    if (MediaQuery.of(context).disableAnimations) {
      return _box(hh, 0.6);
    }
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => _box(hh, _opacity.value),
    );
  }

  Widget _box(HHTokens hh, double opacity) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: hh.bgElevated2.withValues(alpha: opacity),
          borderRadius: widget.borderRadius ?? HHRadius.badgeBr(),
        ),
      );
}

class SiteCardSkeleton extends StatelessWidget {
  const SiteCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: HHSpacing.screenPadding),
      padding: const EdgeInsets.all(HHSpacing.lg),
      decoration: BoxDecoration(
        color: hh.bgElevated,
        borderRadius: HHRadius.cardBr(),
        boxShadow: hh.cardShadow,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Skeleton(width: 160, height: 16)),
              SizedBox(width: HHSpacing.sm),
              Skeleton(width: 56, height: 22, borderRadius: BorderRadius.all(Radius.circular(999))),
            ],
          ),
          SizedBox(height: HHSpacing.sm),
          Skeleton(width: 120, height: 12),
        ],
      ),
    );
  }
}

class ListRowSkeleton extends StatelessWidget {
  const ListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: HHSpacing.lg,
        vertical: HHSpacing.md,
      ),
      child: Row(
        children: [
          Skeleton(width: 28, height: 28, borderRadius: BorderRadius.all(Radius.circular(7))),
          SizedBox(width: HHSpacing.md),
          Expanded(child: Skeleton(width: double.infinity, height: 14)),
          SizedBox(width: HHSpacing.md),
          Skeleton(width: 50, height: 12),
        ],
      ),
    );
  }
}
