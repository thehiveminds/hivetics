

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/connection.dart';
import '../../models/site.dart';
import '../../shared/haptics.dart';
import '../../shared/theme.dart';
import '../../state/sites_notifier.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/site_card.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/app_pressable.dart';
import '../../widgets/primary_button.dart';
import '../connect/add_connection_sheet.dart';
import 'site_detail_screen.dart';

class SitesScreen extends ConsumerStatefulWidget {
  const SitesScreen({super.key});

  @override
  ConsumerState<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends ConsumerState<SitesScreen> {
  String _search = '';
  ProviderId? _filterProvider;
  bool _filterNeedsAttention = false;
  bool _hasSetInitialAttentionFilter = false;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final sitesAsync = ref.watch(sitesProvider);

    // DESIGN.md §6.1: "Needs attention" is the default filter when any site has an alert, else "All"
    if (!_hasSetInitialAttentionFilter && sitesAsync.valueOrNull != null) {
      _hasSetInitialAttentionFilter = true;
      final hasAlerts = sitesAsync.valueOrNull!.allSites.any((s) => s.hasAlerts);
      if (hasAlerts) {
        _filterNeedsAttention = true;
      }
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        AppNavBar(
          title: 'Sites',
          showBackButton: false,
          trailing: [
            AppPressable(
              onTap: _openAddConnection,
              child: Icon(LucideIcons.plus, color: hh.accent, size: 22),
            ),
          ],
          bottom: AppSearchBar(
            placeholder: 'Search sites & domains…',
            initialValue: _search,
            onChanged: (v) => setState(() => _search = v),
          ),
        ),

        SliverToBoxAdapter(
          child: _FilterChips(
            filterProvider: _filterProvider,
            needsAttention: _filterNeedsAttention,
            hasAlerts:
                sitesAsync.valueOrNull?.allSites.any((s) => s.hasAlerts) ??
                false,
            onProviderFilter: (p) => setState(() {
              _filterProvider = p;
              _filterNeedsAttention = false;
            }),
            onAttentionFilter: () => setState(() {
              _filterNeedsAttention = !_filterNeedsAttention;
              _filterProvider = null;
            }),
          ),
        ),

        CupertinoSliverRefreshControl(
          onRefresh: () => ref.read(sitesProvider.notifier).refresh(),
        ),

        sitesAsync.when(
          loading: () => _buildSkeletons(),
          error: (e, _) => _buildGlobalError(e, hh),
          data: (state) => _buildContent(state, hh),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
      ],
    );
  }

  Widget _buildContent(SitesState state, HHTokens hh) {
    final allSites = state.allSites;
    final filtered = _applyFilters(allSites);

    if (allSites.isEmpty) return _buildEmpty(hh);

    return SliverList(
      delegate: SliverChildListDelegate([
        // Per-connection error rows
        ...state.results
            .where((r) => r.hasError)
            .map(
              (r) => _ConnectionErrorCard(
                result: r,
                hh: hh,
                onRetry: () => ref.read(sitesProvider.notifier).refresh(),
              ),
            ),

        const SizedBox(height: HHSpacing.md),

        // Site cards
        ...filtered.map(
          (site) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SiteCard(
              site: site,
              onTap: () => _openSiteDetail(site),
              onLongPress: () => _showQuickActions(site),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildEmpty(HHTokens hh) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(HHSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.layoutGrid, size: 48, color: hh.textTertiary),
            const SizedBox(height: HHSpacing.lg),
            Text(
              'Connect your first platform',
              style: hh.title2(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HHSpacing.sm),
            Text(
              'Hivetics joins your deploy status, domain expiry, and traffic in one view.',
              style: hh.body().copyWith(color: hh.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HHSpacing.xxxl),
            PrimaryButton(label: 'Add Connection', onTap: _openAddConnection),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletons() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SiteCardSkeleton(),
        ),
        childCount: 5,
      ),
    );
  }

  Widget _buildGlobalError(Object error, HHTokens hh) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(HHSpacing.xxxl),
          child: Text('Something went wrong', style: hh.body()),
        ),
      ),
    );
  }

  List<Site> _applyFilters(List<Site> sites) {
    var filtered = sites;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      filtered = filtered
          .where(
            (s) =>
                s.displayName.toLowerCase().contains(q) ||
                (s.domain?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    if (_filterNeedsAttention) {
      filtered = filtered.where((s) => s.hasAlerts).toList();
    }
    if (_filterProvider != null) {
      filtered = filtered
          .where((s) => s.hostProject?.providerId == _filterProvider)
          .toList();
    }
    return filtered;
  }

  void _openAddConnection() {
    HHHaptics.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddConnectionSheet(),
    );
  }

  void _openSiteDetail(Site site) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => SiteDetailScreen(site: site)),
    );
  }

  void _showQuickActions(Site site) {
    HHHaptics.mediumImpact();
    final project = site.hostProject;
    final deploy = site.latestDeployment;
    final siteUrl = site.domain != null
        ? 'https://${site.domain}'
        : (deploy?.url != null && deploy!.url!.isNotEmpty ? deploy.url : null);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(site.displayName),
        message: site.domain != null ? Text(site.domain!) : null,
        actions: [
          if (siteUrl != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(ctx).pop();
                launchUrl(
                  Uri.parse(siteUrl),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: const Text('Open site'),
            ),
          if (site.domain != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(ctx).pop();
                Clipboard.setData(ClipboardData(text: site.domain!));
                HHHaptics.selectionClick();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied ${site.domain} to clipboard'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Copy domain'),
            ),
          if (project != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(ctx).pop();
                launchUrl(
                  Uri.parse(project.dashboardUrl()),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Text('Open in ${project.providerId.displayName}'),
            ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(ctx).pop();
              _openSiteDetail(site);
            },
            child: const Text('View details'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filterProvider,
    required this.needsAttention,
    required this.hasAlerts,
    required this.onProviderFilter,
    required this.onAttentionFilter,
  });

  final ProviderId? filterProvider;
  final bool needsAttention;
  final bool hasAlerts;
  final ValueChanged<ProviderId?> onProviderFilter;
  final VoidCallback onAttentionFilter;

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
          _Chip(
            label: 'All',
            selected: filterProvider == null && !needsAttention,
            onTap: () => onProviderFilter(null),
            hh: hh,
          ),
          if (hasAlerts) ...[
            const SizedBox(width: HHSpacing.sm),
            _Chip(
              label: 'Needs attention',
              selected: needsAttention,
              onTap: onAttentionFilter,
              hh: hh,
            ),
          ],
          ...ProviderId.values.map(
            (p) => Padding(
              padding: const EdgeInsets.only(left: HHSpacing.sm),
              child: _Chip(
                label: p.displayName,
                selected: filterProvider == p,
                onTap: () => onProviderFilter(p),
                hh: hh,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
      onTap: () {
        HHHaptics.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: HHMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? hh.accent : hh.bgElevated,
          borderRadius: HHRadius.pillBr(),
          border: Border.all(
            color: selected
                ? hh.accent
                : hh.cardBorder.withValues(alpha: 0.7),
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

class _ConnectionErrorCard extends StatelessWidget {
  const _ConnectionErrorCard({
    required this.result,
    required this.hh,
    required this.onRetry,
  });
  final ConnectionFetchResult result;
  final HHTokens hh;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        HHSpacing.screenPadding,
        0,
        HHSpacing.screenPadding,
        HHSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(HHSpacing.md),
        decoration: BoxDecoration(
          color: hh.statusQueued.withValues(alpha: 0.10),
          borderRadius: HHRadius.cardBr(),
          border: Border.all(color: hh.statusQueued.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.alertTriangle, size: 16, color: hh.statusQueued),
            const SizedBox(width: HHSpacing.sm),
            Expanded(
              child: Text(
                '${result.connection.displayName} — ${result.error?.message ?? 'Could not load'}',
                style: hh.subhead().copyWith(color: hh.statusQueued),
              ),
            ),
            AppPressable(
              onTap: onRetry,
              child: Text('Retry', style: hh.body().copyWith(color: hh.accent)),
            ),
          ],
        ),
      ),
    );
  }
}
