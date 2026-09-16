// MIT Licence — TheHiveMinds / Hivetics
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/deploy_status.dart';
import '../../models/registered_domain.dart';
import '../../models/registrar_id.dart';
import '../../models/service_ref.dart';
import '../../shared/haptics.dart';
import '../../shared/theme.dart';
import '../../state/domains_notifier.dart';
import '../../widgets/app_grouped_section.dart';
import '../../widgets/app_list_row.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_pressable.dart';
import '../../widgets/app_status_pill.dart';
import '../../widgets/provider_badge.dart';
import '../../widgets/skeleton.dart';
import '../dns/dns_records_screen.dart';

class DomainsScreen extends ConsumerStatefulWidget {
  const DomainsScreen({super.key});

  @override
  ConsumerState<DomainsScreen> createState() => _DomainsScreenState();
}

class _DomainsScreenState extends ConsumerState<DomainsScreen> {
  String _search = '';
  bool _filterExpiringOnly = false;
  RegistrarId? _filterRegistrar;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final domainsAsync = ref.watch(domainsProvider);

    return Scaffold(
      backgroundColor: hh.bgBase,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          AppNavBar(
            title: 'Domains',
            bottom: _SearchBar(onChanged: (v) => setState(() => _search = v)),
          ),

          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: HHSpacing.screenPadding,
                vertical: HHSpacing.sm,
              ),
              child: Row(
                children: [
                  _chip(
                    label: 'All',
                    selected: !_filterExpiringOnly && _filterRegistrar == null,
                    onTap: () => setState(() {
                      _filterExpiringOnly = false;
                      _filterRegistrar = null;
                    }),
                    hh: hh,
                  ),
                  _chip(
                    label: 'Expiring',
                    selected: _filterExpiringOnly,
                    onTap: () => setState(() {
                      _filterExpiringOnly = !_filterExpiringOnly;
                      _filterRegistrar = null;
                    }),
                    hh: hh,
                  ),
                  ...RegistrarId.values.map((r) => _chip(
                        label: r.displayName,
                        selected: _filterRegistrar == r,
                        onTap: () => setState(() {
                          _filterRegistrar = (_filterRegistrar == r) ? null : r;
                          _filterExpiringOnly = false;
                        }),
                        hh: hh,
                      )),
                ],
              ),
            ),
          ),

          CupertinoSliverRefreshControl(
            onRefresh: () => ref.read(domainsProvider.notifier).refresh(),
          ),

          domainsAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: HHSpacing.screenPadding,
                    vertical: 6,
                  ),
                  child: ListRowSkeleton(),
                ),
                childCount: 8,
              ),
            ),
            error: (_, __) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text('Could not load domains', style: hh.body()),
              ),
            ),
            data: (state) {
              final allDomains = state.allDomains;
              if (allDomains.isEmpty) {
                return _buildEmpty(state, hh);
              }

              final expiring = state.expiringSoonDomains;
              final filteredExpiring = _applyFilters(expiring);
              final filteredAll = _applyFilters(allDomains);
              if (filteredAll.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No matching domains',
                      style: hh.body().copyWith(color: hh.textSecondary),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  // Pinned "EXPIRING SOON" section (§5.1)
                  if (!_filterExpiringOnly && filteredExpiring.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: HHSpacing.sm),
                      child: AppGroupedSection(
                        header: 'EXPIRING SOON',
                        headerColor: hh.statusQueued,
                        children: filteredExpiring.map((d) {
                          final days = d.daysUntilExpiry ?? 0;
                          final subtitle = d.isExpired
                              ? 'Expired'
                              : (days == 1
                                  ? 'Expires tomorrow'
                                  : 'Expires in $days days');
                          return AppListRow(
                            title: d.domain,
                            subtitle: subtitle,
                            subtitleStyle: TextStyle(
                              color: d.isExpired ? hh.statusFailed : hh.statusQueued,
                              fontSize: 13,
                            ),
                            leadingWidget: RegistrarBadge(registrarId: d.registrar),
                            trailingWidget: d.autoRenew == false
                                ? const AppStatusPill(
                                    status: DeployStatus.queued,
                                    label: 'Auto-renew off',
                                  )
                                : null,
                            showChevron: true,
                            onTap: () => _openDns(d),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: HHSpacing.lg),
                  ],

                  // Grouped per registrar connection (§5.1)
                  ...state.results.map((connResult) {
                    final connDomains = _applyFilters(connResult.domains);
                    if (connDomains.isEmpty) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: HHSpacing.lg),
                      child: AppGroupedSection(
                        header: connResult.connection.displayName.toUpperCase(),
                        children: connDomains.map((d) {
                          final days = d.daysUntilExpiry;
                          final expText = days != null
                              ? (days <= 0
                                  ? 'Expired'
                                  : (days <= 30
                                      ? 'Expires in $days days'
                                      : 'Expires in $days days'))
                              : 'Active';

                          return AppListRow(
                            title: d.domain,
                            subtitle: expText,
                            leadingWidget: RegistrarBadge(registrarId: d.registrar),
                            showChevron: true,
                            onTap: () => _openDns(d),
                          );
                        }).toList(),
                      ),
                    );
                  }),

                  const SizedBox(height: 120),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required HHTokens hh,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: HHSpacing.xs),
      child: AppPressable(
        onTap: () {
          HHHaptics.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? hh.accent : hh.bgElevated2,
            borderRadius: HHRadius.pillBr(),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? const Color(0xFF000000) : hh.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  List<RegisteredDomain> _applyFilters(List<RegisteredDomain> list) {
    var result = list;
    if (_filterExpiringOnly) {
      result = result.where((d) => d.isExpiringSoon || d.isExpired).toList();
    }
    if (_filterRegistrar != null) {
      result = result.where((d) => d.registrar == _filterRegistrar).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result.where((d) => d.domain.toLowerCase().contains(q)).toList();
    }
    return result;
  }

  Widget _buildEmpty(DomainsState state, HHTokens hh) {
    final hasPorkbun = state.results.any(
      (r) =>
          r.connection.service is RegistrarRef &&
          (r.connection.service as RegistrarRef).registrar == RegistrarId.porkbun,
    );

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(HHSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.globe, size: 48, color: hh.textTertiary),
              const SizedBox(height: HHSpacing.lg),
              Text('No domains found', style: hh.title2()),
              const SizedBox(height: HHSpacing.sm),
              Text(
                hasPorkbun
                    ? 'Porkbun requires API access to be enabled per domain in your Porkbun dashboard. Domains without it won\'t appear here.'
                    : 'Connect a registrar like GoDaddy, Porkbun, or Cloudflare to view all your domains.',
                style: hh.body().copyWith(color: hh.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDns(RegisteredDomain domain) {
    HHHaptics.lightImpact();
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => DnsRecordsScreen(
          connectionId: domain.connectionId,
          domain: domain.domain,
          registrar: domain.registrar,
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget implements PreferredSizeWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(
        horizontal: HHSpacing.screenPadding,
        vertical: 4,
      ),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: hh.bgElevated2,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: HHSpacing.sm),
        child: Row(
          children: [
            Icon(LucideIcons.search, color: hh.textTertiary, size: 16),
            const SizedBox(width: HHSpacing.xs),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: hh.body().copyWith(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search domains…',
                  hintStyle: hh.body().copyWith(
                        fontSize: 15,
                        color: hh.textTertiary,
                      ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
