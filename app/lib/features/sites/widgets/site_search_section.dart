import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../models/gsc_models.dart';
import '../../../models/service_ref.dart';
import '../../../models/site.dart';
import '../../../shared/haptics.dart';
import '../../../shared/theme.dart';
import '../../../state/gsc_notifier.dart';
import '../../../widgets/app_pressable.dart';
import '../../../widgets/provider_badge.dart';
import '../../../widgets/skeleton.dart';
import '../../analytics/gsc_performance_screen.dart';
import '../../connect/add_connection_sheet.dart';

class SiteSearchSection extends ConsumerWidget {
  const SiteSearchSection({
    super.key,
    required this.site,
  });

  final Site site;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hh = context.hh;
    final gscConnections = ref.watch(gscConnectionsProvider).valueOrNull ?? const [];

    if (gscConnections.isEmpty) {
      return _buildConnectBanner(context, hh);
    }

    final connection = gscConnections.first;
    final domain = site.domain;
    final siteUrlCandidate = site.gscSiteUrl ??
        (domain != null ? 'sc-domain:$domain' : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HHSpacing.screenPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GOOGLE SEARCH CONSOLE',
                style: hh.caption2().copyWith(color: hh.textTertiary),
              ),
              AppPressable(
                onTap: () {
                  HHHaptics.selectionClick();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GscPerformanceScreen(
                        connectionId: connection.id,
                        initialSiteUrl: siteUrlCandidate,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Report',
                      style: hh.caption2().copyWith(
                            color: hh.accent,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 12,
                      color: hh.accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: HHSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HHSpacing.screenPadding,
          ),
          child: _SearchSummaryCard(
            connectionId: connection.id,
            siteUrl: siteUrlCandidate,
            domain: domain ?? site.displayName,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectBanner(BuildContext context, HHTokens hh) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HHSpacing.screenPadding,
      ),
      child: AppPressable(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const AddConnectionSheet(),
        ),
        child: Container(
          padding: const EdgeInsets.all(HHSpacing.md),
          decoration: BoxDecoration(
            color: hh.bgElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: hh.cardBorder.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              const AnalyticsBadge(
                providerId: AnalyticsProviderId.gsc,
                size: 32,
              ),
              const SizedBox(width: HHSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect Search Console',
                      style: hh.headline().copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Track clicks, impressions & indexing for this site',
                      style: hh.footnote().copyWith(color: hh.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.plus, size: 16, color: hh.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSummaryCard extends ConsumerWidget {
  const _SearchSummaryCard({
    required this.connectionId,
    required this.siteUrl,
    required this.domain,
  });

  final String connectionId;
  final String? siteUrl;
  final String domain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hh = context.hh;
    final effectiveSiteUrl = siteUrl ?? 'sc-domain:$domain';

    final reportAsync = ref.watch(
      gscPerformanceProvider((
        connectionId: connectionId,
        siteUrl: effectiveSiteUrl,
        days: 28,
        searchType: GscSearchType.web,
      )),
    );

    return reportAsync.when(
      data: (report) {
        return AppPressable(
          onTap: () {
            HHHaptics.selectionClick();
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => GscPerformanceScreen(
                  connectionId: connectionId,
                  initialSiteUrl: effectiveSiteUrl,
                ),
              ),
            );
          },
          child: Container(
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
                    Row(
                      children: [
                        const AnalyticsBadge(
                          providerId: AnalyticsProviderId.gsc,
                          size: 20,
                        ),
                        const SizedBox(width: HHSpacing.xs),
                        Text(
                          'Last 28 Days',
                          style: hh.caption().copyWith(color: hh.textSecondary),
                        ),
                      ],
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: hh.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: HHSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _kpi(
                      'Clicks',
                      NumberFormat.compact().format(report.totalClicks),
                      const Color(0xFF4285F4),
                      hh,
                    ),
                    _kpi(
                      'Impressions',
                      NumberFormat.compact().format(report.totalImpressions),
                      const Color(0xFF8B5CF6),
                      hh,
                    ),
                    _kpi(
                      'Avg CTR',
                      '${(report.averageCtr * 100).toStringAsFixed(1)}%',
                      const Color(0xFF10B981),
                      hh,
                    ),
                    _kpi(
                      'Avg Pos',
                      report.averagePosition.toStringAsFixed(1),
                      const Color(0xFFF59E0B),
                      hh,
                    ),
                  ],
                ),
                if (report.topQueries.isNotEmpty) ...[
                  const SizedBox(height: HHSpacing.md),
                  Divider(height: 0.5, thickness: 0.5, color: hh.separator),
                  const SizedBox(height: HHSpacing.sm),
                  Text(
                    'Top query: "${report.topQueries.first.query}" · ${report.topQueries.first.clicks} clicks',
                    style: hh.footnote().copyWith(color: hh.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const AppSkeleton(height: 110),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(HHSpacing.md),
        decoration: BoxDecoration(
          color: hh.bgElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: hh.cardBorder),
        ),
        child: Row(
          children: [
            const AnalyticsBadge(
              providerId: AnalyticsProviderId.gsc,
              size: 24,
            ),
            const SizedBox(width: HHSpacing.sm),
            Expanded(
              child: Text(
                'Search Console property not linked or pending verification.',
                style: hh.footnote().copyWith(color: hh.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpi(String label, String value, Color color, HHTokens hh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: hh.caption2().copyWith(color: hh.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: hh.headline().copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
      ],
    );
  }
}
