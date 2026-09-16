import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../models/gsc_models.dart';
import '../../models/project_analytics.dart';
import '../../shared/haptics.dart';
import '../../shared/theme.dart';
import '../../state/gsc_notifier.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_pressable.dart';
import '../../widgets/charts/ios_trend_chart.dart';
import '../../widgets/skeleton.dart';

enum _GscMetric {
  clicks('Clicks', Color(0xFF4285F4)),
  impressions('Impressions', Color(0xFF8B5CF6)),
  ctr('CTR', Color(0xFF10B981)),
  position('Position', Color(0xFFF59E0B));

  const _GscMetric(this.label, this.color);
  final String label;
  final Color color;
}

enum _BreakdownTab {
  queries('Queries'),
  pages('Pages'),
  countries('Countries'),
  devices('Devices'),
  sitemaps('Sitemaps');

  const _BreakdownTab(this.label);
  final String label;
}

class GscPerformanceScreen extends ConsumerStatefulWidget {
  const GscPerformanceScreen({
    super.key,
    required this.connectionId,
    this.initialSiteUrl,
  });

  final String connectionId;
  final String? initialSiteUrl;

  @override
  ConsumerState<GscPerformanceScreen> createState() =>
      _GscPerformanceScreenState();
}

class _GscPerformanceScreenState extends ConsumerState<GscPerformanceScreen> {
  String? _selectedSiteUrl;
  int _dateRangeDays = 28;
  GscSearchType _searchType = GscSearchType.web;
  _GscMetric _selectedMetric = _GscMetric.clicks;
  _BreakdownTab _activeTab = _BreakdownTab.queries;
  TimeSeriesPoint? _scrubbedPoint;
  final _inspectUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSiteUrl = widget.initialSiteUrl;
  }

  @override
  void dispose() {
    _inspectUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final sitesAsync = ref.watch(gscSitesProvider(widget.connectionId));

    return Scaffold(
      backgroundColor: hh.bgBase,
      body: CustomScrollView(
        slivers: [
          AppNavBar(
            title: 'Search Console',
            trailing: [
              AppPressable(
                onTap: () => _showInspectionSheet(context),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Icon(LucideIcons.searchCode, color: hh.accent, size: 20),
                  ),
                ),
              ),
            ],
          ),

          // Site Property Picker
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: HHSpacing.screenPadding,
                vertical: HHSpacing.sm,
              ),
              child: sitesAsync.when(
                data: (sites) {
                  if (sites.isEmpty) {
                    return _buildNoSitesCard(hh);
                  }
                  final currentSite = _selectedSiteUrl ?? sites.first.siteUrl;
                  if (_selectedSiteUrl == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedSiteUrl = currentSite);
                    });
                  }

                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.search,
                          size: 16,
                          color: Color(0xFF4285F4),
                        ),
                      ),
                      const SizedBox(width: HHSpacing.sm),
                      Expanded(
                        child: PopupMenuButton<String>(
                          initialValue: currentSite,
                          onSelected: (val) {
                            HHHaptics.selectionClick();
                            setState(() => _selectedSiteUrl = val);
                          },
                          color: hh.bgElevated,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: hh.cardBorder, width: 0.5),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: HHSpacing.sm,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: hh.bgElevated,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: hh.cardBorder, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    currentSite,
                                    style: hh.headline().copyWith(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  LucideIcons.chevronDown,
                                  size: 14,
                                  color: hh.textSecondary,
                                ),
                              ],
                            ),
                          ),
                          itemBuilder: (_) => [
                            for (final s in sites)
                              PopupMenuItem<String>(
                                value: s.siteUrl,
                                child: Text(
                                  s.siteUrl,
                                  style: hh.body().copyWith(
                                        fontSize: 13,
                                        fontWeight: s.siteUrl == currentSite
                                            ? FontWeight.w700
                                            : FontWeight.normal,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const AppSkeleton(height: 36),
                error: (e, _) => Text(
                  'Error loading properties: $e',
                  style: hh.caption().copyWith(color: hh.statusFailed),
                ),
              ),
            ),
          ),

          // Date & Search Type Controls
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: HHSpacing.screenPadding,
                vertical: HHSpacing.xs,
              ),
              child: Row(
                children: [
                  // Date Range Segmented Control
                  Expanded(
                    child: CupertinoSlidingSegmentedControl<int>(
                      groupValue: _dateRangeDays,
                      thumbColor: hh.bgElevated2,
                      backgroundColor: hh.fill.withValues(alpha: 0.35),
                      children: {
                        7: _segmentText('7d', _dateRangeDays == 7, hh),
                        28: _segmentText('28d', _dateRangeDays == 28, hh),
                        90: _segmentText('3m', _dateRangeDays == 90, hh),
                        180: _segmentText('6m', _dateRangeDays == 180, hh),
                        365: _segmentText('12m', _dateRangeDays == 365, hh),
                      },
                      onValueChanged: (val) {
                        if (val != null) {
                          HHHaptics.selectionClick();
                          setState(() => _dateRangeDays = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: HHSpacing.sm),
                  // Search Type Picker
                  PopupMenuButton<GscSearchType>(
                    initialValue: _searchType,
                    onSelected: (val) {
                      HHHaptics.selectionClick();
                      setState(() => _searchType = val);
                    },
                    color: hh.bgElevated,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: hh.cardBorder, width: 0.5),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: hh.bgElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: hh.cardBorder, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _searchType.displayName,
                            style: hh.caption2().copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: hh.textPrimary,
                                ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            LucideIcons.chevronDown,
                            size: 12,
                            color: hh.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    itemBuilder: (_) => [
                      for (final st in GscSearchType.values)
                        PopupMenuItem<GscSearchType>(
                          value: st,
                          child: Text(st.displayName, style: hh.body()),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: HHSpacing.md)),

          // Performance Query Report
          if (_selectedSiteUrl != null)
            _buildReportSection(hh)
          else
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(HHSpacing.xl),
                child: Center(child: CupertinoActivityIndicator()),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildReportSection(HHTokens hh) {
    final reportAsync = ref.watch(
      gscPerformanceProvider((
        connectionId: widget.connectionId,
        siteUrl: _selectedSiteUrl!,
        days: _dateRangeDays,
        searchType: _searchType,
      )),
    );

    return reportAsync.when(
      data: (report) => SliverList(
        delegate: SliverChildListDelegate([
          // 4 Metric KPI Cards
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HHSpacing.screenPadding,
            ),
            child: _buildMetricGrid(report, hh),
          ),
          const SizedBox(height: HHSpacing.lg),

          // Interactive iOS Trend Graph
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HHSpacing.screenPadding,
            ),
            child: _buildTrendCard(report, hh),
          ),
          const SizedBox(height: HHSpacing.xl),

          // Breakdown Segmented Tabs
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HHSpacing.screenPadding,
            ),
            child: CupertinoSlidingSegmentedControl<_BreakdownTab>(
              groupValue: _activeTab,
              thumbColor: hh.bgElevated2,
              backgroundColor: hh.fill.withValues(alpha: 0.35),
              children: {
                for (final tab in _BreakdownTab.values)
                  tab: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    child: Text(
                      tab.label,
                      style: hh.caption2().copyWith(
                            color: _activeTab == tab
                                ? hh.textPrimary
                                : hh.textTertiary,
                            fontWeight: _activeTab == tab
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                    ),
                  ),
              },
              onValueChanged: (val) {
                if (val != null) {
                  HHHaptics.selectionClick();
                  setState(() => _activeTab = val);
                }
              },
            ),
          ),
          const SizedBox(height: HHSpacing.md),

          // Tab Content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HHSpacing.screenPadding,
            ),
            child: _buildTabContent(report, hh),
          ),
        ]),
      ),
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(HHSpacing.screenPadding),
          child: Column(
            children: [
              AppSkeleton(height: 80),
              SizedBox(height: HHSpacing.md),
              AppSkeleton(height: 220),
            ],
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(HHSpacing.screenPadding),
          child: Container(
            padding: const EdgeInsets.all(HHSpacing.lg),
            decoration: BoxDecoration(
              color: hh.statusFailed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hh.statusFailed.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.alertCircle,
                      color: hh.statusFailed,
                      size: 18,
                    ),
                    const SizedBox(width: HHSpacing.xs),
                    Text(
                      'Failed to load Search Console data',
                      style: hh.headline().copyWith(color: hh.statusFailed),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  e.toString(),
                  style: hh.footnote().copyWith(color: hh.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricGrid(GscPerformanceReport report, HHTokens hh) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - HHSpacing.sm * 3) / 4;

        return Row(
          children: [
            _buildMetricCard(
              metric: _GscMetric.clicks,
              value: NumberFormat.compact().format(report.totalClicks),
              label: 'Clicks',
              isSelected: _selectedMetric == _GscMetric.clicks,
              width: cardWidth,
              hh: hh,
            ),
            const SizedBox(width: HHSpacing.sm),
            _buildMetricCard(
              metric: _GscMetric.impressions,
              value: NumberFormat.compact().format(report.totalImpressions),
              label: 'Impressions',
              isSelected: _selectedMetric == _GscMetric.impressions,
              width: cardWidth,
              hh: hh,
            ),
            const SizedBox(width: HHSpacing.sm),
            _buildMetricCard(
              metric: _GscMetric.ctr,
              value: '${(report.averageCtr * 100).toStringAsFixed(1)}%',
              label: 'Avg CTR',
              isSelected: _selectedMetric == _GscMetric.ctr,
              width: cardWidth,
              hh: hh,
            ),
            const SizedBox(width: HHSpacing.sm),
            _buildMetricCard(
              metric: _GscMetric.position,
              value: report.averagePosition.toStringAsFixed(1),
              label: 'Avg Pos',
              isSelected: _selectedMetric == _GscMetric.position,
              width: cardWidth,
              hh: hh,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required _GscMetric metric,
    required String value,
    required String label,
    required bool isSelected,
    required double width,
    required HHTokens hh,
  }) {
    return AppPressable(
      onTap: () {
        HHHaptics.selectionClick();
        setState(() => _selectedMetric = metric);
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? metric.color.withValues(alpha: 0.12)
              : hh.bgElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? metric.color.withValues(alpha: 0.8)
                : hh.cardBorder.withValues(alpha: 0.6),
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: isSelected ? hh.cardShadow : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: hh.caption2().copyWith(
                    color: isSelected ? metric.color : hh.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: hh.metric().copyWith(
                      fontSize: 20,
                      color: isSelected ? metric.color : hh.textPrimary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard(GscPerformanceReport report, HHTokens hh) {
    // Map report rows to TimeSeriesPoints
    final points = report.rows.map((row) {
      final val = switch (_selectedMetric) {
        _GscMetric.clicks => row.clicks.toDouble(),
        _GscMetric.impressions => row.impressions.toDouble(),
        _GscMetric.ctr => row.ctr * 100,
        _GscMetric.position => row.position,
      };
      return TimeSeriesPoint(
        timestamp: row.date ?? DateTime.now(),
        value: val,
      );
    }).toList();

    final scrubVal = _scrubbedPoint != null
        ? switch (_selectedMetric) {
            _GscMetric.clicks =>
              '${_scrubbedPoint!.value.toInt()} clicks',
            _GscMetric.impressions =>
              '${_scrubbedPoint!.value.toInt()} imp',
            _GscMetric.ctr =>
              '${_scrubbedPoint!.value.toStringAsFixed(2)}% CTR',
            _GscMetric.position =>
              'pos ${_scrubbedPoint!.value.toStringAsFixed(1)}',
          }
        : null;

    final scrubDate = _scrubbedPoint != null
        ? DateFormat('EEE, MMM d').format(_scrubbedPoint!.timestamp)
        : null;

    return Container(
      padding: const EdgeInsets.all(HHSpacing.md),
      decoration: BoxDecoration(
        color: hh.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hh.cardBorder.withValues(alpha: 0.8)),
        boxShadow: hh.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedMetric.label.toUpperCase(),
                style: hh.caption2().copyWith(
                      color: _selectedMetric.color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (scrubVal != null && scrubDate != null)
                Text(
                  '$scrubDate · $scrubVal',
                  style: hh.caption2().copyWith(
                        color: hh.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                )
              else
                Text(
                  'Daily trend',
                  style: hh.caption2().copyWith(color: hh.textTertiary),
                ),
            ],
          ),
          const SizedBox(height: HHSpacing.md),
          if (points.isEmpty)
            SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'No search trend data for this interval',
                  style: hh.subhead().copyWith(color: hh.textSecondary),
                ),
              ),
            )
          else
            IosTrendChart(
              points: points,
              lineColor: _selectedMetric.color,
              height: 180,
              onScrub: (p) => setState(() => _scrubbedPoint = p),
              valueFormatter: (v) => switch (_selectedMetric) {
                _GscMetric.ctr => '${v.toStringAsFixed(1)}%',
                _GscMetric.position => v.toStringAsFixed(1),
                _ => NumberFormat.compact().format(v),
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent(GscPerformanceReport report, HHTokens hh) {
    return switch (_activeTab) {
      _BreakdownTab.queries => _buildRankedList(
          items: report.topQueries,
          titleExtractor: (r) => r.query ?? 'Unknown query',
          hh: hh,
        ),
      _BreakdownTab.pages => _buildRankedList(
          items: report.topPages,
          titleExtractor: (r) => r.page ?? 'Unknown page',
          hh: hh,
        ),
      _BreakdownTab.countries => _buildRankedList(
          items: report.topCountries,
          titleExtractor: (r) => r.country ?? 'Unknown country',
          hh: hh,
        ),
      _BreakdownTab.devices => _buildRankedList(
          items: report.topDevices,
          titleExtractor: (r) => (r.device ?? 'Unknown device').toUpperCase(),
          hh: hh,
        ),
      _BreakdownTab.sitemaps => _buildSitemapsTab(hh),
    };
  }

  Widget _buildRankedList({
    required List<GscPerformanceRow> items,
    required String Function(GscPerformanceRow) titleExtractor,
    required HHTokens hh,
  }) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(HHSpacing.xl),
        alignment: Alignment.center,
        child: Text(
          'No breakdown data available',
          style: hh.subhead().copyWith(color: hh.textSecondary),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: hh.bgElevated,
        borderRadius: HHRadius.cardBr(),
        border: Border.all(
          color: hh.cardBorder.withValues(alpha: 0.8),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HHSpacing.md,
              vertical: HHSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _activeTab.label.toUpperCase(),
                    style: hh.caption2().copyWith(color: hh.textTertiary),
                  ),
                ),
                SizedBox(
                  width: 55,
                  child: Text(
                    'CLICKS',
                    textAlign: TextAlign.right,
                    style: hh.caption2().copyWith(color: hh.textTertiary),
                  ),
                ),
                SizedBox(
                  width: 55,
                  child: Text(
                    'IMP',
                    textAlign: TextAlign.right,
                    style: hh.caption2().copyWith(color: hh.textTertiary),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    'CTR',
                    textAlign: TextAlign.right,
                    style: hh.caption2().copyWith(color: hh.textTertiary),
                  ),
                ),
                SizedBox(
                  width: 45,
                  child: Text(
                    'POS',
                    textAlign: TextAlign.right,
                    style: hh.caption2().copyWith(color: hh.textTertiary),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 0.5, thickness: 0.5, color: hh.separator),
          for (int i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: HHSpacing.md,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      titleExtractor(items[i]),
                      style: hh.body().copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 55,
                    child: Text(
                      NumberFormat.compact().format(items[i].clicks),
                      textAlign: TextAlign.right,
                      style: hh.body().copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4285F4),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 55,
                    child: Text(
                      NumberFormat.compact().format(items[i].impressions),
                      textAlign: TextAlign.right,
                      style: hh.body().copyWith(
                            fontSize: 13,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${(items[i].ctr * 100).toStringAsFixed(1)}%',
                      textAlign: TextAlign.right,
                      style: hh.caption().copyWith(
                            color: hh.textSecondary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 45,
                    child: Text(
                      items[i].position.toStringAsFixed(1),
                      textAlign: TextAlign.right,
                      style: hh.caption().copyWith(
                            color: hh.textSecondary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1)
              Divider(height: 0.5, thickness: 0.5, color: hh.separator),
          ],
        ],
      ),
    );
  }

  Widget _buildSitemapsTab(HHTokens hh) {
    final sitemapsAsync = ref.watch(
      gscSitemapsProvider((
        connectionId: widget.connectionId,
        siteUrl: _selectedSiteUrl!,
      )),
    );

    return sitemapsAsync.when(
      data: (sitemaps) {
        if (sitemaps.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(HHSpacing.xl),
            alignment: Alignment.center,
            child: Text(
              'No submitted sitemaps found for this property.',
              style: hh.subhead().copyWith(color: hh.textSecondary),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: hh.bgElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: hh.cardBorder.withValues(alpha: 0.8)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < sitemaps.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.all(HHSpacing.md),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.fileSpreadsheet,
                        size: 20,
                        color: sitemaps[i].hasErrors
                            ? hh.statusFailed
                            : hh.statusReady,
                      ),
                      const SizedBox(width: HHSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sitemaps[i].path,
                              style: hh.headline().copyWith(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Type: ${sitemaps[i].type.toUpperCase()} · Submitted: ${sitemaps[i].lastSubmitted != null ? DateFormat('yyyy-MM-dd').format(sitemaps[i].lastSubmitted!) : 'Never'}',
                              style: hh.footnote().copyWith(color: hh.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (sitemaps[i].hasErrors
                                  ? hh.statusFailed
                                  : hh.statusReady)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sitemaps[i].hasErrors ? 'Errors' : 'Success',
                          style: hh.caption2().copyWith(
                                color: sitemaps[i].hasErrors
                                    ? hh.statusFailed
                                    : hh.statusReady,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < sitemaps.length - 1)
                  Divider(height: 0.5, thickness: 0.5, color: hh.separator),
              ],
            ],
          ),
        );
      },
      loading: () => const AppSkeleton(height: 120),
      error: (e, _) => Text(
        'Failed to load sitemaps: $e',
        style: hh.caption().copyWith(color: hh.statusFailed),
      ),
    );
  }

  void _showInspectionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _UrlInspectionModal(
        connectionId: widget.connectionId,
        siteUrl: _selectedSiteUrl ?? '',
      ),
    );
  }

  Widget _buildNoSitesCard(HHTokens hh) {
    return Container(
      padding: const EdgeInsets.all(HHSpacing.lg),
      decoration: BoxDecoration(
        color: hh.bgElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hh.cardBorder),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.info, color: hh.textSecondary, size: 20),
          const SizedBox(width: HHSpacing.sm),
          Expanded(
            child: Text(
              'No verified properties found in this Google Search Console account.',
              style: hh.subhead().copyWith(color: hh.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmentText(String text, bool isSelected, HHTokens hh) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text(
        text,
        style: hh.caption2().copyWith(
              color: isSelected ? hh.textPrimary : hh.textTertiary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
      ),
    );
  }
}

class _UrlInspectionModal extends ConsumerStatefulWidget {
  const _UrlInspectionModal({
    required this.connectionId,
    required this.siteUrl,
  });

  final String connectionId;
  final String siteUrl;

  @override
  ConsumerState<_UrlInspectionModal> createState() =>
      _UrlInspectionModalState();
}

class _UrlInspectionModalState extends ConsumerState<_UrlInspectionModal> {
  final _controller = TextEditingController();
  String? _inspectedUrl;

  @override
  void initState() {
    super.initState();
    final base = widget.siteUrl.startsWith('sc-domain:')
        ? 'https://${widget.siteUrl.replaceFirst('sc-domain:', '')}/'
        : widget.siteUrl;
    _controller.text = base;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: hh.bgElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(HHSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: hh.fill,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: HHSpacing.md),
            Row(
              children: [
                const Icon(
                  LucideIcons.searchCode,
                  size: 20,
                  color: Color(0xFF4285F4),
                ),
                const SizedBox(width: HHSpacing.sm),
                Text(
                  'URL Inspection',
                  style: hh.title2().copyWith(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: HHSpacing.md),
            TextField(
              controller: _controller,
              style: hh.mono().copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'https://example.com/page',
                filled: true,
                fillColor: hh.bgElevated2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: HHSpacing.md),
            CupertinoButton(
              color: const Color(0xFF4285F4),
              borderRadius: BorderRadius.circular(10),
              padding: const EdgeInsets.symmetric(vertical: 10),
              onPressed: () {
                final text = _controller.text.trim();
                if (text.isNotEmpty) {
                  HHHaptics.selectionClick();
                  setState(() => _inspectedUrl = text);
                }
              },
              child: Text(
                'Test Live URL Status',
                style: hh.headline().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: HHSpacing.lg),
            if (_inspectedUrl != null) ...[
              ref
                  .watch(gscInspectProvider((
                    connectionId: widget.connectionId,
                    siteUrl: widget.siteUrl,
                    url: _inspectedUrl!,
                  )))
                  .when(
                    data: (result) => _buildInspectionDetails(result, hh),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(HHSpacing.xl),
                      child: Center(child: CupertinoActivityIndicator()),
                    ),
                    error: (e, _) => Text(
                      'Inspection failed: $e',
                      style: hh.caption().copyWith(color: hh.statusFailed),
                    ),
                  ),
            ],
            const SizedBox(height: HHSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionDetails(GscInspectionResult res, HHTokens hh) {
    final isIndexed = res.verdict == 'PASS';

    return Container(
      padding: const EdgeInsets.all(HHSpacing.md),
      decoration: BoxDecoration(
        color: hh.bgElevated2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isIndexed ? hh.statusReady : hh.statusFailed,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIndexed ? LucideIcons.checkCircle : LucideIcons.alertCircle,
                size: 18,
                color: isIndexed ? hh.statusReady : hh.statusFailed,
              ),
              const SizedBox(width: HHSpacing.xs),
              Expanded(
                child: Text(
                  isIndexed ? 'URL is on Google' : 'URL is not on Google',
                  style: hh.headline().copyWith(
                        color: isIndexed ? hh.statusReady : hh.statusFailed,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: HHSpacing.sm),
          _kv('Coverage State', res.coverageState, hh),
          _kv('Crawled As', res.crawledAs, hh),
          _kv('Page Fetch', res.pageFetchState ?? 'SUCCESSFUL', hh),
          _kv('Indexing Allowed', res.robotsTxtState, hh),
          _kv('Mobile Friendly', res.mobileUsabilityVerdict, hh),
          if (res.lastCrawlTime != null)
            _kv(
              'Last Crawl',
              DateFormat('yyyy-MM-dd HH:mm').format(res.lastCrawlTime!),
              hh,
            ),
        ],
      ),
    );
  }

  Widget _kv(String key, String value, HHTokens hh) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: hh.footnote().copyWith(color: hh.textSecondary)),
          Text(
            value,
            style: hh.footnote().copyWith(
                  color: hh.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
