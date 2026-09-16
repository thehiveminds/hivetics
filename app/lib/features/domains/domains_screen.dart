import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/registered_domain.dart';
import '../../models/registrar_id.dart';
import '../../models/service_ref.dart';
import '../../shared/haptics.dart';
import '../../shared/theme.dart';
import '../../state/domains_notifier.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/app_pressable.dart';
import '../../widgets/domain_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/skeleton.dart';
import '../connect/add_connection_sheet.dart';
import '../dns/dns_records_screen.dart';

class DomainsScreen extends ConsumerStatefulWidget {
  const DomainsScreen({super.key});

  @override
  ConsumerState<DomainsScreen> createState() => _DomainsScreenState();
}

class _DomainsScreenState extends ConsumerState<DomainsScreen> {
  String _search = '';
  RegistrarId? _filterRegistrar;
  bool _filterNeedsAttention = false;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final domainsAsync = ref.watch(domainsProvider);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        AppNavBar(
          title: 'Domains',
          showBackButton: false,
          trailing: [
            AppPressable(
              onTap: _openAddConnection,
              child: Icon(LucideIcons.plus, color: hh.accent, size: 22),
            ),
          ],
          bottom: AppSearchBar(
            placeholder: 'Search domains…',
            initialValue: _search,
            onChanged: (v) => setState(() => _search = v),
          ),
        ),

        SliverToBoxAdapter(
          child: _FilterChips(
            filterRegistrar: _filterRegistrar,
            needsAttention: _filterNeedsAttention,
            hasAlerts: domainsAsync.valueOrNull?.allDomains.any(
                  (d) => d.isExpiringSoon || d.isExpired || d.autoRenew == false,
                ) ??
                false,
            onRegistrarFilter: (r) => setState(() {
              _filterRegistrar = r;
              _filterNeedsAttention = false;
            }),
            onAttentionFilter: () => setState(() {
              _filterNeedsAttention = !_filterNeedsAttention;
              _filterRegistrar = null;
            }),
          ),
        ),

        CupertinoSliverRefreshControl(
          onRefresh: () => ref.read(domainsProvider.notifier).refresh(),
        ),

        domainsAsync.when(
          loading: () => _buildSkeletons(),
          error: (e, _) => _buildGlobalError(e, hh),
          data: (state) => _buildContent(state, hh),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
      ],
    );
  }

  Widget _buildContent(DomainsState state, HHTokens hh) {
    final allDomains = state.allDomains;
    final filtered = _applyFilters(allDomains);

    if (allDomains.isEmpty) {
      return _buildEmpty(state, hh);
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        // Per-connection error rows (matching SitesScreen)
        ...state.results
            .where((r) => r.hasError)
            .map(
              (r) => _ConnectionErrorCard(
                result: r,
                hh: hh,
                onRetry: () => ref.read(domainsProvider.notifier).refresh(),
              ),
            ),

        const SizedBox(height: HHSpacing.md),

        // Domain cards (matching SitesScreen)
        ...filtered.map(
          (domain) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DomainCard(
              domain: domain,
              onTap: () => _openDomainDetail(domain),
              onLongPress: () => _showQuickActions(domain),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildEmpty(DomainsState state, HHTokens hh) {
    final hasPorkbun = state.results.any(
      (r) =>
          r.connection.service is RegistrarRef &&
          (r.connection.service as RegistrarRef).registrar == RegistrarId.porkbun,
    );

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(HHSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.globe, size: 48, color: hh.textTertiary),
            const SizedBox(height: HHSpacing.lg),
            Text(
              'No domains found',
              style: hh.title2(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HHSpacing.sm),
            Text(
              hasPorkbun
                  ? 'Porkbun requires API access to be enabled per domain in your Porkbun dashboard. Domains without it won\'t appear here.'
                  : 'Connect a registrar like GoDaddy, Porkbun, or Cloudflare to monitor domain expiry and DNS records.',
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
          child: Text('Could not load domains', style: hh.body()),
        ),
      ),
    );
  }

  List<RegisteredDomain> _applyFilters(List<RegisteredDomain> list) {
    var result = list;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result.where((d) => d.domain.toLowerCase().contains(q)).toList();
    }
    if (_filterNeedsAttention) {
      result = result
          .where((d) => d.isExpiringSoon || d.isExpired || d.autoRenew == false)
          .toList();
    }
    if (_filterRegistrar != null) {
      result = result.where((d) => d.registrar == _filterRegistrar).toList();
    }
    return result;
  }

  void _openAddConnection() {
    HHHaptics.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddConnectionSheet(),
    );
  }

  void _openDomainDetail(RegisteredDomain domain) {
    HHHaptics.lightImpact();
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => DnsRecordsScreen(
          connectionId: domain.connectionId,
          domain: domain.domain,
          registrar: domain.registrar,
          initialDomain: domain,
        ),
      ),
    );
  }

  void _showQuickActions(RegisteredDomain domain) {
    HHHaptics.mediumImpact();
    final siteUrl = 'https://${domain.domain}';
    final dashboardUrl = switch (domain.registrar) {
      RegistrarId.godaddy =>
        'https://dcc.godaddy.com/control/${domain.domain}/dns',
      RegistrarId.porkbun =>
        'https://porkbun.com/account/domains',
      RegistrarId.cloudflareregistrar =>
        'https://dash.cloudflare.com',
      RegistrarId.spaceship =>
        'https://www.spaceship.com/application/',
      RegistrarId.namecom =>
        'https://www.name.com/account/domain',
      RegistrarId.namesilo =>
        'https://www.namesilo.com/account_domains.php',
      RegistrarId.gandi =>
        'https://admin.gandi.net/domain',
      RegistrarId.dynadot =>
        'https://www.dynadot.com/account/domain/manage.html',
    };

    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(domain.domain),
        message: Text(domain.registrar.displayName),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(ctx).pop();
              launchUrl(
                Uri.parse(siteUrl),
                mode: LaunchMode.externalApplication,
              );
            },
            child: const Text('Open in browser'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(ctx).pop();
              Clipboard.setData(ClipboardData(text: domain.domain));
              HHHaptics.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied ${domain.domain} to clipboard'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Copy domain'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(ctx).pop();
              launchUrl(
                Uri.parse(dashboardUrl),
                mode: LaunchMode.externalApplication,
              );
            },
            child: Text('Open in ${domain.registrar.displayName}'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(ctx).pop();
              _openDomainDetail(domain);
            },
            child: const Text('View details & DNS'),
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
    required this.filterRegistrar,
    required this.needsAttention,
    required this.hasAlerts,
    required this.onRegistrarFilter,
    required this.onAttentionFilter,
  });

  final RegistrarId? filterRegistrar;
  final bool needsAttention;
  final bool hasAlerts;
  final ValueChanged<RegistrarId?> onRegistrarFilter;
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
            selected: filterRegistrar == null && !needsAttention,
            onTap: () => onRegistrarFilter(null),
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
          ...RegistrarId.values.map(
            (r) => Padding(
              padding: const EdgeInsets.only(left: HHSpacing.sm),
              child: _Chip(
                label: r.displayName,
                selected: filterRegistrar == r,
                onTap: () => onRegistrarFilter(r),
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
  final ConnectionDomainsResult result;
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
