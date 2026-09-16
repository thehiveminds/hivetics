import 'package:flutter/material.dart';
import '../../models/project_analytics.dart';
import '../../shared/theme.dart';

class CacheHitBar extends StatelessWidget {
  const CacheHitBar({
    super.key,
    required this.cache,
    required this.formattedBandwidth,
  });

  final CacheBreakdown cache;
  final String formattedBandwidth;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final total = cache.total;

    final hitPct = total > 0 ? (cache.hits / total) : 0.0;
    final missPct = total > 0 ? (cache.misses / total) : 0.0;
    final bypassPct = total > 0 ? (cache.bypasses / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(HHSpacing.md),
      decoration: BoxDecoration(
        color: hh.bgElevated2,
        borderRadius: HHRadius.cardBr(),
        border: Border.all(
          color: hh.cardBorder.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edge Cache Efficiency',
                      style: hh.caption().copyWith(color: hh.textTertiary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          '${cache.hitRate.toStringAsFixed(1)}%',
                          style: hh.title2().copyWith(
                                color: hh.statusReady,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: hh.statusReady.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'OPTIMIZED',
                            style: hh.caption2().copyWith(
                                  color: hh.statusReady,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: HHSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Data Transfer',
                    style: hh.caption().copyWith(color: hh.textTertiary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedBandwidth,
                    style: hh.headline().copyWith(
                          color: hh.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: HHSpacing.md),

          // Segmented Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 7,
              child: Row(
                children: [
                  if (hitPct > 0)
                    Expanded(
                      flex: (hitPct * 1000).round().clamp(1, 1000),
                      child: Container(color: hh.statusReady),
                    ),
                  if (missPct > 0) ...[
                    const SizedBox(width: 1.5),
                    Expanded(
                      flex: (missPct * 1000).round().clamp(1, 1000),
                      child: Container(color: hh.statusBuilding),
                    ),
                  ],
                  if (bypassPct > 0) ...[
                    const SizedBox(width: 1.5),
                    Expanded(
                      flex: (bypassPct * 1000).round().clamp(1, 1000),
                      child: Container(color: hh.fill),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: HHSpacing.sm),

          // Legend Row
          Wrap(
            spacing: HHSpacing.md,
            runSpacing: 4,
            children: [
              _LegendItem(
                color: hh.statusReady,
                label: 'Hit (${(hitPct * 100).toStringAsFixed(1)}%)',
                hh: hh,
              ),
              _LegendItem(
                color: hh.statusBuilding,
                label: 'Miss (${(missPct * 100).toStringAsFixed(1)}%)',
                hh: hh,
              ),
              _LegendItem(
                color: hh.fill,
                label: 'Bypass (${(bypassPct * 100).toStringAsFixed(1)}%)',
                hh: hh,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.hh,
  });

  final Color color;
  final String label;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: hh.caption2().copyWith(color: hh.textSecondary),
        ),
      ],
    );
  }
}
