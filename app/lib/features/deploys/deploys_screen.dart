

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/deployment.dart';
import '../../models/deploy_status.dart';
import '../../models/connection.dart';
import '../../shared/formatters.dart';
import '../../shared/haptics.dart';
import '../../shared/theme.dart';
import '../../state/deployments_notifier.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_status_pill.dart';
import '../../widgets/app_pressable.dart';
import '../../widgets/skeleton.dart';
import 'deployment_detail_screen.dart';

class DeploysScreen extends ConsumerStatefulWidget {
  const DeploysScreen({super.key});

  @override
  ConsumerState<DeploysScreen> createState() => _DeploysScreenState();
}

class _DeploysScreenState extends ConsumerState<DeploysScreen> {
  final String _search = '';
  DeployStatus? _filterStatus;
  ProviderId? _filterProvider;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final deploysAsync = ref.watch(deploymentsProvider);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const AppNavBar(title: 'Deploys'),

        SliverToBoxAdapter(
          child: _FilterRow(
            filterStatus: _filterStatus,
            filterProvider: _filterProvider,
            onStatusFilter: (s) => setState(() {
              _filterStatus = s;
              HHHaptics.selectionClick();
            }),
            onProviderFilter: (p) => setState(() {
              _filterProvider = p;
              HHHaptics.selectionClick();
            }),
          ),
        ),

        CupertinoSliverRefreshControl(
          onRefresh: () => ref.read(deploymentsProvider.notifier).refresh(),
        ),

        deploysAsync.when(
          loading: () => SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: HHSpacing.screenPadding),
                child: ListRowSkeleton(),
              ),
              childCount: 10,
            ),
          ),
          error: (_, __) => SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text('Could not load deployments', style: hh.body()),
            ),
          ),
          data: (deploys) {
            final filtered = _filter(deploys);
            if (filtered.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.gitBranch, size: 40, color: hh.textTertiary),
                      const SizedBox(height: HHSpacing.md),
                      Text('No deployments found', style: hh.body()),
                    ],
                  ),
                ),
              );
            }

            // Group by day
            final grouped = _groupByDay(filtered);
            final items = <_DayItem>[];
            for (final entry in grouped.entries) {
              items.add(_DayItem.header(entry.key));
              for (final d in entry.value) {
                items.add(_DayItem.deploy(d));
              }
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final item = items[i];
                  if (item.isHeader) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        HHSpacing.screenPadding, HHSpacing.lg, HHSpacing.screenPadding, HHSpacing.sm,
                      ),
                      child: Text(item.header!, style: hh.caption2()),
                    );
                  }
                  return _DeployRow(
                    deployment: item.deployment!,
                    hh: hh,
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) => DeploymentDetailScreen(deployment: item.deployment!),
                      ),
                    ),
                  );
                },
                childCount: items.length,
              ),
            );
          },
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
      ],
    );
  }

  List<Deployment> _filter(List<Deployment> all) {
    var result = all;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result
          .where((d) =>
              (d.commitMessage?.toLowerCase().contains(q) ?? false) ||
              (d.commitSha?.contains(q) ?? false))
          .toList();
    }
    if (_filterStatus != null) {
      result = result.where((d) => d.status == _filterStatus).toList();
    }

    return result;
  }

  Map<String, List<Deployment>> _groupByDay(List<Deployment> deploys) {
    final result = <String, List<Deployment>>{};
    for (final d in deploys) {
      final label = deployGroupLabel(d.createdAt);
      result.putIfAbsent(label, () => []).add(d);
    }
    return result;
  }
}

class _DayItem {
  const _DayItem.header(String h)
      : header = h,
        deployment = null;
  const _DayItem.deploy(Deployment d)
      : deployment = d,
        header = null;

  final String? header;
  final Deployment? deployment;
  bool get isHeader => header != null;
}

class _DeployRow extends StatelessWidget {
  const _DeployRow({
    required this.deployment,
    required this.hh,
    required this.onTap,
  });
  final Deployment deployment;
  final HHTokens hh;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final commitTitle = deployment.commitMessage?.trim().isNotEmpty == true
        ? deployment.commitMessage!.split('\n').first
        : (deployment.url ?? 'Deployment');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HHSpacing.screenPadding,
        vertical: 4,
      ),
      child: AppPressable(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: hh.bgElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hh.cardBorder.withValues(alpha: 0.7),
              width: 0.5,
            ),
          ),
          padding: const EdgeInsets.all(HHSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppStatusPill(status: deployment.status),
                  const SizedBox(width: HHSpacing.sm),
                  Expanded(
                    child: Text(
                      commitTitle,
                      style: hh.headline().copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: HHSpacing.xs),
              Text(
                [
                  if (deployment.commitSha != null) shortSha(deployment.commitSha),
                  if (deployment.branch != null) deployment.branch,
                  relativeTime(deployment.createdAt),
                  if (deployment.duration != null) formatDuration(deployment.duration),
                ].join(' · '),
                style: hh.footnote(),
              ),
              if (deployment.status == DeployStatus.failed &&
                  deployment.errorMessage != null) ...[
                const SizedBox(height: HHSpacing.xs),
                Text(
                  deployment.errorMessage!,
                  style: hh.footnote().copyWith(color: hh.statusFailed),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filterStatus,
    required this.filterProvider,
    required this.onStatusFilter,
    required this.onProviderFilter,
  });
  final DeployStatus? filterStatus;
  final ProviderId? filterProvider;
  final ValueChanged<DeployStatus?> onStatusFilter;
  final ValueChanged<ProviderId?> onProviderFilter;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: HHSpacing.screenPadding,
          vertical: HHSpacing.sm,
        ),
        children: [
          _FilterChip(
            label: 'All',
            selected: filterStatus == null && filterProvider == null,
            onTap: () {
              onStatusFilter(null);
              onProviderFilter(null);
            },
            hh: hh,
          ),
          const SizedBox(width: HHSpacing.sm),
          _FilterChip(
            label: 'Failed',
            selected: filterStatus == DeployStatus.failed,
            onTap: () => onStatusFilter(
              filterStatus == DeployStatus.failed ? null : DeployStatus.failed,
            ),
            hh: hh,
          ),
          const SizedBox(width: HHSpacing.sm),
          _FilterChip(
            label: 'Building',
            selected: filterStatus == DeployStatus.building,
            onTap: () => onStatusFilter(
              filterStatus == DeployStatus.building ? null : DeployStatus.building,
            ),
            hh: hh,
          ),
          ...ProviderId.values.map((p) => Padding(
                padding: const EdgeInsets.only(left: HHSpacing.sm),
                child: _FilterChip(
                  label: p.displayName,
                  selected: filterProvider == p,
                  onTap: () =>
                      onProviderFilter(filterProvider == p ? null : p),
                  hh: hh,
                ),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.hh,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: HHMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? hh.accent : hh.bgElevated,
          borderRadius: HHRadius.pillBr(),
          border: Border.all(
            color: selected ? hh.accent : hh.cardBorder.withValues(alpha: 0.7),
            width: 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: hh.caption().copyWith(
                color: selected ? const Color(0xFF000000) : hh.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
