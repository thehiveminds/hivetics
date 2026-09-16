import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/project_analytics.dart';
import '../../../models/site.dart';
import '../../../shared/theme.dart';
import '../../../state/project_analytics_notifier.dart';
import '../../../widgets/charts/cache_hit_bar.dart';
import '../../../widgets/charts/ios_trend_chart.dart';
import '../../../widgets/skeleton.dart';

class SiteAnalyticsSection extends ConsumerStatefulWidget {
  const SiteAnalyticsSection({
    super.key,
    required this.connectionId,
    required this.projectId,
    required this.site,
  });

  final String connectionId;
  final String projectId;
  final Site site;

  @override
  ConsumerState<SiteAnalyticsSection> createState() =>
      _SiteAnalyticsSectionState();
}

class _SiteAnalyticsSectionState extends ConsumerState<SiteAnalyticsSection> {
  AnalyticsTimeframe _timeframe = AnalyticsTimeframe.month;
  AnalyticsMetricType _selectedMetric = AnalyticsMetricType.pageViews;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final analyticsAsync = ref.watch(
      projectAnalyticsProvider((
        connectionId: widget.connectionId,
        projectId: widget.projectId,
        timeframe: _timeframe,
      )),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header & Timeframe Picker
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HHSpacing.screenPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TRAFFIC & ANALYTICS',
                style: hh.caption2().copyWith(color: hh.textTertiary),
              ),
              // Cupertino Segmented Control (§0 in DESIGN.md)
              CupertinoSlidingSegmentedControl<AnalyticsTimeframe>(
                groupValue: _timeframe,
                thumbColor: hh.bgElevated2,
                backgroundColor: hh.fill.withValues(alpha: 0.35),
                children: {
                  for (final tf in AnalyticsTimeframe.values)
                    tf: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        tf.label,
                        style: hh.caption2().copyWith(
                              color: _timeframe == tf
                                  ? hh.textPrimary
                                  : hh.textTertiary,
                              fontWeight: _timeframe == tf
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                      ),
                    ),
                },
                onValueChanged: (val) {
                  if (val != null && val != _timeframe) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _timeframe = val;
                    });
                  }
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: HHSpacing.sm),

        // Main Content Card
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HHSpacing.screenPadding,
          ),
          child: analyticsAsync.when(
            loading: () => Container(
              height: 380,
              padding: const EdgeInsets.all(HHSpacing.md),
              decoration: BoxDecoration(
                color: hh.bgElevated,
                borderRadius: HHRadius.cardBr(),
                border: Border.all(
                  color: hh.cardBorder.withValues(alpha: 0.7),
                  width: 0.5,
                ),
                boxShadow: hh.cardShadow,
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Skeleton(width: double.infinity, height: 70)),
                      SizedBox(width: 8),
                      Expanded(child: Skeleton(width: double.infinity, height: 70)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Skeleton(width: double.infinity, height: 70)),
                      SizedBox(width: 8),
                      Expanded(child: Skeleton(width: double.infinity, height: 70)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(child: Skeleton(width: double.infinity, height: 180)),
                ],
              ),
            ),
            error: (e, _) => Container(
              padding: const EdgeInsets.all(HHSpacing.md),
              decoration: BoxDecoration(
                color: hh.bgElevated,
                borderRadius: BorderRadius.circular(HHRadius.card),
              ),
              child: Text(
                'Unable to load traffic analytics',
                style: hh.subhead().copyWith(color: hh.textTertiary),
              ),
            ),
            data: (data) {
              if (data == null) {
                return const SizedBox.shrink();
              }

              final activeTimeseries = data.getTimeseriesForMetric(_selectedMetric);
              final activeColor = _selectedMetric == AnalyticsMetricType.cacheHitRate
                  ? hh.statusReady
                  : hh.accent;

              return Container(
                padding: const EdgeInsets.all(HHSpacing.md),
                decoration: BoxDecoration(
                  color: hh.bgElevated,
                  borderRadius: HHRadius.cardBr(),
                  border: Border.all(
                    color: hh.cardBorder.withValues(alpha: 0.7),
                    width: 0.5,
                  ),
                  boxShadow: hh.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metric Selector Grid (4 interactive tiles)
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            type: AnalyticsMetricType.pageViews,
                            value: data.formatValue(AnalyticsMetricType.pageViews),
                            delta: data.pageViewsDelta,
                            isSelected: _selectedMetric == AnalyticsMetricType.pageViews,
                            hh: hh,
                            onTap: () => _setMetric(AnalyticsMetricType.pageViews),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            type: AnalyticsMetricType.visitors,
                            value: data.formatValue(AnalyticsMetricType.visitors),
                            delta: data.visitorsDelta,
                            isSelected: _selectedMetric == AnalyticsMetricType.visitors,
                            hh: hh,
                            onTap: () => _setMetric(AnalyticsMetricType.visitors),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            type: AnalyticsMetricType.requests,
                            value: data.formatValue(AnalyticsMetricType.requests),
                            delta: data.requestsDelta,
                            isSelected: _selectedMetric == AnalyticsMetricType.requests,
                            hh: hh,
                            onTap: () => _setMetric(AnalyticsMetricType.requests),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            type: AnalyticsMetricType.cacheHitRate,
                            value: data.formatValue(AnalyticsMetricType.cacheHitRate),
                            delta: null,
                            isSelected: _selectedMetric == AnalyticsMetricType.cacheHitRate,
                            hh: hh,
                            onTap: () => _setMetric(AnalyticsMetricType.cacheHitRate),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: HHSpacing.md),

                    // iOS Trend Chart
                    IosTrendChart(
                      points: activeTimeseries,
                      lineColor: activeColor,
                      height: 175,
                      valueFormatter: (val) => _formatMetricVal(val, _selectedMetric),
                      unit: _selectedMetric == AnalyticsMetricType.cacheHitRate ? '%' : '',
                    ),

                    const SizedBox(height: HHSpacing.lg),

                    // Cache Efficiency Breakdown
                    CacheHitBar(
                      cache: data.cache,
                      formattedBandwidth: data.formatBandwidth(),
                    ),

                    if (!data.isWebAnalyticsEnabled) ...[
                      const SizedBox(height: HHSpacing.md),
                      _NoticeBanner(
                        site: widget.site,
                        hh: hh,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _setMetric(AnalyticsMetricType metric) {
    if (_selectedMetric != metric) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedMetric = metric;
      });
    }
  }

  String _formatMetricVal(double val, AnalyticsMetricType type) {
    if (type == AnalyticsMetricType.cacheHitRate) {
      return '${val.toStringAsFixed(1)}%';
    }
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(1)}k';
    return val.toStringAsFixed(0);
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.type,
    required this.value,
    required this.delta,
    required this.isSelected,
    required this.hh,
    required this.onTap,
  });

  final AnalyticsMetricType type;
  final String value;
  final double? delta;
  final bool isSelected;
  final HHTokens hh;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeBg = isSelected ? hh.bgElevated2 : hh.bgBase.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(
          horizontal: HHSpacing.sm,
          vertical: HHSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: activeBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? hh.accent : hh.cardBorder.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type.shortName.toUpperCase(),
                  style: hh.caption2().copyWith(
                        color: isSelected ? hh.accent : hh.textTertiary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                ),
                if (delta != null)
                  _DeltaBadge(
                    delta: delta!,
                    higherIsBetter: type.higherIsBetter,
                    hh: hh,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: hh.title2().copyWith(
                    color: hh.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({
    required this.delta,
    required this.higherIsBetter,
    required this.hh,
  });

  final double delta;
  final bool higherIsBetter;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    final isGood = (delta >= 0 && higherIsBetter) || (delta < 0 && !higherIsBetter);
    final color = delta.abs() < 1.0
        ? hh.trendFlat
        : (isGood ? hh.trendUp : hh.trendDown);

    final sign = delta > 0 ? '↑ +' : (delta < 0 ? '↓ ' : '');

    return Text(
      '$sign${delta.abs().toStringAsFixed(1)}%',
      style: hh.caption2().copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _NoticeBanner extends StatelessWidget {
  const _NoticeBanner({
    required this.site,
    required this.hh,
  });

  final Site site;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HHSpacing.sm,
        vertical: HHSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: hh.bgElevated2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hh.cardBorder.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.info,
            size: 14,
            color: hh.textTertiary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Telemetry active. Enable Web Analytics in Vercel for visitor tracking.',
              style: hh.caption2().copyWith(color: hh.textTertiary),
            ),
          ),
          if (site.hostProject != null)
            GestureDetector(
              onTap: () => launchUrl(
                Uri.parse('${site.hostProject!.dashboardUrl()}/analytics'),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                'Enable →',
                style: hh.caption2().copyWith(
                      color: hh.accent,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
