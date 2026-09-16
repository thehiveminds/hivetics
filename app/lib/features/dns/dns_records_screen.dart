import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/dns_record.dart';
import '../../models/registered_domain.dart';
import '../../models/registrar_id.dart';
import '../../shared/formatters.dart';
import '../../shared/haptics.dart';
import '../../shared/theme.dart';
import '../../state/connections_notifier.dart';
import '../../state/domains_notifier.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_pressable.dart';
import '../../widgets/copyable_value.dart';
import '../../widgets/domain_status_pill.dart';
import '../../widgets/provider_badge.dart';
import '../../widgets/skeleton.dart';

class DnsRecordsScreen extends ConsumerStatefulWidget {
  const DnsRecordsScreen({
    super.key,
    required this.connectionId,
    required this.domain,
    required this.registrar,
    this.initialDomain,
  });

  final String connectionId;
  final String domain;
  final RegistrarId registrar;
  final RegisteredDomain? initialDomain;

  @override
  ConsumerState<DnsRecordsScreen> createState() => _DnsRecordsScreenState();
}

class _DnsRecordsScreenState extends ConsumerState<DnsRecordsScreen> {
  String _typeFilter = 'All';

  static const _types = ['All', 'A', 'CNAME', 'TXT', 'MX', 'NS'];

  Future<void> _refresh() async {
    HHHaptics.selectionClick();
    final db = ref.read(dbProvider);
    await db.replaceDnsRecordsForDomain(
      widget.connectionId,
      widget.domain,
      const [],
    );
    ref.invalidate(dnsRecordsProvider((
      connectionId: widget.connectionId,
      domain: widget.domain,
      registrar: widget.registrar,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final recordsAsync = ref.watch(dnsRecordsProvider((
      connectionId: widget.connectionId,
      domain: widget.domain,
      registrar: widget.registrar,
    )));

    // Look up domain registration if not provided directly
    final domainsState = ref.watch(domainsProvider).valueOrNull;
    final domainObj = widget.initialDomain ??
        domainsState?.allDomains.firstWhere(
          (d) => d.domain == widget.domain && d.connectionId == widget.connectionId,
          orElse: () => RegisteredDomain(
            domain: widget.domain,
            connectionId: widget.connectionId,
            registrar: widget.registrar,
            status: DomainStatus.active,
            fetchedAt: DateTime.now().toUtc(),
          ),
        );

    final hasExternalNs = domainObj != null &&
        domainObj.nameServers.isNotEmpty &&
        !domainObj.nameServers.any(
          (ns) => _isRegistrarNameserver(widget.registrar, ns),
        );

    return Scaffold(
      backgroundColor: hh.bgBase,
      body: CustomScrollView(
        slivers: [
          AppNavBar(
            title: widget.domain,
            showBackButton: true,
            trailing: [
              AppPressable(
                onTap: _refresh,
                child: Icon(LucideIcons.refreshCw, size: 18, color: hh.accent),
              ),
            ],
          ),

          CupertinoSliverRefreshControl(
            onRefresh: _refresh,
          ),

          // Domain Overview Card (§5.1 & §6.6)
          if (domainObj != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  HHSpacing.screenPadding,
                  HHSpacing.sm,
                  HHSpacing.screenPadding,
                  HHSpacing.md,
                ),
                child: _DomainOverviewCard(
                  domain: domainObj,
                  registrar: widget.registrar,
                  hasExternalNs: hasExternalNs,
                  hh: hh,
                ),
              ),
            ),

          // DNS Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                HHSpacing.screenPadding,
                HHSpacing.xs,
                HHSpacing.screenPadding,
                HHSpacing.xs,
              ),
              child: Text(
                'DNS RECORDS',
                style: hh.caption().copyWith(
                      color: hh.textTertiary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
              ),
            ),
          ),

          // DNS Type Filter Chips (matching SitesScreen and DomainsScreen)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: HHSpacing.screenPadding,
                  vertical: HHSpacing.sm,
                ),
                children: _types.map((t) {
                  final selected = _typeFilter == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: HHSpacing.sm),
                    child: AppPressable(
                      onTap: () {
                        HHHaptics.selectionClick();
                        setState(() => _typeFilter = t);
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
                          t,
                          style: hh.caption().copyWith(
                                color: selected
                                    ? const Color(0xFF000000)
                                    : hh.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Records List or Empty / External notice
          recordsAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: HHSpacing.screenPadding,
                    vertical: 4,
                  ),
                  child: ListRowSkeleton(),
                ),
                childCount: 6,
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(HHSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.alertCircle,
                          size: 36, color: hh.statusFailed),
                      const SizedBox(height: HHSpacing.md),
                      Text('Could not load DNS records', style: hh.body()),
                      const SizedBox(height: HHSpacing.xs),
                      Text(
                        'Ensure your API credentials have DNS read permission.',
                        style: hh.footnote().copyWith(color: hh.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: HHSpacing.lg),
                      AppPressable(
                        onTap: _refresh,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: hh.bgElevated,
                            borderRadius: HHRadius.pillBr(),
                            border: Border.all(color: hh.cardBorder, width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.refreshCw, size: 14, color: hh.textPrimary),
                              const SizedBox(width: 6),
                              Text('Retry', style: hh.caption().copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (records) {
              final filtered = _applyFilters(records);
              if (filtered.isEmpty) {
                final isFiltered = _typeFilter != 'All' && records.isNotEmpty;
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(HHSpacing.xxl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFiltered
                                ? LucideIcons.filter
                                : (hasExternalNs ? LucideIcons.globe : LucideIcons.fileQuestion),
                            size: 36,
                            color: hh.textTertiary,
                          ),
                          const SizedBox(height: HHSpacing.md),
                          Text(
                            isFiltered
                                ? 'No $_typeFilter records'
                                : 'No DNS records found',
                            style: hh.headline(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: HHSpacing.xs),
                          Text(
                            isFiltered
                                ? 'No records of type $_typeFilter were found. Select "All" to view all records.'
                                : (hasExternalNs
                                    ? 'This domain uses external nameservers. Live DNS records could not be resolved from authoritative servers.'
                                    : 'No records configured on ${widget.registrar.displayName}.'),
                            style: hh.body().copyWith(color: hh.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          if (!isFiltered) ...[
                            const SizedBox(height: HHSpacing.lg),
                            AppPressable(
                              onTap: _refresh,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: hh.bgElevated,
                                  borderRadius: HHRadius.pillBr(),
                                  border: Border.all(
                                    color: hh.cardBorder.withValues(alpha: 0.8),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.refreshCw, size: 14, color: hh.textPrimary),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Refresh Live DNS',
                                      style: hh.caption().copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: HHSpacing.screenPadding,
                  vertical: HHSpacing.sm,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final r = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _DnsRecordRow(
                          record: r,
                          hh: hh,
                          onTap: () => _showRecordSheet(context, r, hh),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              );
            },
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
        ],
      ),
    );
  }

  List<DnsRecord> _applyFilters(List<DnsRecord> all) {
    var list = all;
    if (_typeFilter != 'All') {
      list = list.where((r) => r.type.toUpperCase() == _typeFilter).toList();
    }
    return list;
  }

  void _showRecordSheet(BuildContext context, DnsRecord r, HHTokens hh) {
    HHHaptics.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: hh.bgElevated,
          borderRadius: HHRadius.sheetBr(),
        ),
        padding: const EdgeInsets.fromLTRB(
          HHSpacing.lg,
          HHSpacing.md,
          HHSpacing.lg,
          HHSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: hh.fill,
                  borderRadius: HHRadius.pillBr(),
                ),
              ),
            ),
            const SizedBox(height: HHSpacing.lg),
            Row(
              children: [
                _TypeBadge(type: r.type, hh: hh),
                const SizedBox(width: HHSpacing.sm),
                Expanded(
                  child: Text(
                    r.name,
                    style: hh.headline(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (r.proxied)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6821F).withValues(alpha: 0.12),
                      borderRadius: HHRadius.pillBr(),
                      border: Border.all(
                        color: const Color(0xFFF6821F).withValues(alpha: 0.28),
                        width: 0.5,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.cloud, color: Color(0xFFF6821F), size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Proxied',
                          style: TextStyle(
                            color: Color(0xFFF6821F),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: HHSpacing.xl),
            Text('CONTENT', style: hh.caption2()),
            const SizedBox(height: HHSpacing.xs),
            CopyableValue(value: r.content),
            const SizedBox(height: HHSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TTL', style: hh.caption2()),
                      const SizedBox(height: HHSpacing.xs),
                      Text(
                        r.isAutoTtl ? 'Auto' : (r.ttl != null ? '${r.ttl}s' : '—'),
                        style: hh.body(),
                      ),
                    ],
                  ),
                ),
                if (r.priority != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PRIORITY', style: hh.caption2()),
                        const SizedBox(height: HHSpacing.xs),
                        Text('${r.priority}', style: hh.body()),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

bool _isRegistrarNameserver(RegistrarId registrar, String ns) {
  final lower = ns.toLowerCase();
  return switch (registrar) {
    RegistrarId.godaddy =>
      lower.contains('domaincontrol.com') ||
      lower.contains('godaddy.com') ||
      lower.contains('secureserver.net'),
    RegistrarId.spaceship =>
      lower.contains('spaceship.com') ||
      lower.contains('registrar-servers.com'),
    RegistrarId.porkbun =>
      lower.contains('porkbun.com'),
    RegistrarId.cloudflareregistrar =>
      lower.contains('cloudflare.com'),
    RegistrarId.namecom =>
      lower.contains('name.com'),
    RegistrarId.namesilo =>
      lower.contains('namesilo.com') ||
      lower.contains('dnsowl.com'),
    RegistrarId.gandi =>
      lower.contains('gandi.net'),
    RegistrarId.dynadot =>
      lower.contains('dynadot.com'),
  };
}

class _DomainOverviewCard extends StatelessWidget {
  const _DomainOverviewCard({
    required this.domain,
    required this.registrar,
    required this.hasExternalNs,
    required this.hh,
  });

  final RegisteredDomain domain;
  final RegistrarId registrar;
  final bool hasExternalNs;
  final HHTokens hh;

  static DomainStatus _effectiveStatus(RegisteredDomain d) {
    if (d.isExpired) return DomainStatus.expired;
    if (d.isExpiringSoon) return DomainStatus.expiring;
    return d.status;
  }

  @override
  Widget build(BuildContext context) {
    final days = domain.daysUntilExpiry;

    return Container(
      decoration: BoxDecoration(
        color: hh.bgElevated,
        borderRadius: HHRadius.cardBr(),
        border: Border.all(
          color: hh.cardBorder.withValues(alpha: 0.7),
          width: 0.5,
        ),
        boxShadow: hh.cardShadow,
      ),
      padding: const EdgeInsets.all(HHSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RegistrarBadge(registrarId: registrar, showLabel: true),
              const Spacer(),
              DomainStatusPill(status: _effectiveStatus(domain)),
            ],
          ),

          const SizedBox(height: HHSpacing.md),
          Divider(height: 0.5, thickness: 0.5, color: hh.separator),
          const SizedBox(height: HHSpacing.md),

          // Expiration & countdown
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 14, color: hh.textSecondary),
              const SizedBox(width: HHSpacing.xs),
              Text(
                domain.expiresAt != null
                    ? 'Expires ${formatDate(domain.expiresAt!)}'
                    : 'Expiration not specified',
                style: hh.footnote().copyWith(color: hh.textSecondary),
              ),
              if (days != null) ...[
                const SizedBox(width: HHSpacing.xs),
                Text('·', style: hh.footnote().copyWith(color: hh.textSecondary)),
                const SizedBox(width: HHSpacing.xs),
                Text(
                  days <= 0
                      ? 'Expired'
                      : (days == 1 ? '1 day left' : '$days days left'),
                  style: hh.footnote().copyWith(
                        color: days <= 0
                            ? hh.statusFailed
                            : (days <= 30 ? hh.statusQueued : hh.textSecondary),
                        fontWeight: days <= 30 ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
              ],
            ],
          ),

          const SizedBox(height: HHSpacing.md),

          // Status feature badges (proper pills)
          Wrap(
            spacing: HHSpacing.sm,
            runSpacing: HHSpacing.xs,
            children: [
              if (domain.autoRenew != null)
                _FeatureBadge(
                  icon: domain.autoRenew!
                      ? LucideIcons.refreshCw
                      : LucideIcons.minusCircle,
                  label: domain.autoRenew! ? 'Auto-renew on' : 'Auto-renew off',
                  color: domain.autoRenew! ? hh.statusReady : hh.statusQueued,
                  hh: hh,
                ),
              if (domain.locked != null)
                _FeatureBadge(
                  icon: domain.locked! ? LucideIcons.lock : LucideIcons.unlock,
                  label: domain.locked! ? 'Transfer locked' : 'Unlocked',
                  color: domain.locked! ? hh.statusReady : hh.textSecondary,
                  hh: hh,
                ),
              if (domain.privacy != null)
                _FeatureBadge(
                  icon: domain.privacy! ? LucideIcons.shieldCheck : LucideIcons.shield,
                  label: domain.privacy! ? 'Privacy on' : 'Privacy off',
                  color: domain.privacy! ? hh.statusReady : hh.textSecondary,
                  hh: hh,
                ),
            ],
          ),

          // Nameservers
          if (domain.nameServers.isNotEmpty) ...[
            const SizedBox(height: HHSpacing.md),
            Divider(height: 0.5, thickness: 0.5, color: hh.separator),
            const SizedBox(height: HHSpacing.sm),
            Text(
              'NAMESERVERS',
              style: hh.caption2().copyWith(color: hh.textTertiary),
            ),
            const SizedBox(height: HHSpacing.xs),
            ...domain.nameServers.map(
              (ns) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  ns,
                  style: hh.mono().copyWith(fontSize: 12, color: hh.textSecondary),
                ),
              ),
            ),
            if (hasExternalNs) ...[
              const SizedBox(height: HHSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.info, size: 13, color: hh.textTertiary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'External nameservers active. Live DNS records are resolved from public authoritative DNS.',
                      style: hh.footnote().copyWith(color: hh.textTertiary, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.hh,
  });

  final IconData icon;
  final String label;
  final Color color;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: HHRadius.pillBr(),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: hh.caption().copyWith(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DnsRecordRow extends StatelessWidget {
  const _DnsRecordRow({
    required this.record,
    required this.hh,
    required this.onTap,
  });

  final DnsRecord record;
  final HHTokens hh;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            _TypeBadge(type: record.type, hh: hh),
            const SizedBox(width: HHSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          record.name,
                          style: hh.headline().copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (record.proxied) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6821F).withValues(alpha: 0.12),
                            borderRadius: HHRadius.pillBr(),
                            border: Border.all(
                              color: const Color(0xFFF6821F).withValues(alpha: 0.28),
                              width: 0.5,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.cloud,
                                color: Color(0xFFF6821F),
                                size: 10,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Proxied',
                                style: TextStyle(
                                  color: Color(0xFFF6821F),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    record.content,
                    style: HHTextStyles.mono(hh.textSecondary).copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: HHSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record.isAutoTtl ? 'Auto' : (record.ttl != null ? '${record.ttl}s' : ''),
                  style: hh.footnote().copyWith(fontSize: 11, color: hh.textTertiary),
                ),
                if (record.priority != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Prio ${record.priority}',
                    style: hh.caption2().copyWith(color: hh.textTertiary),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 4),
            Icon(LucideIcons.chevronRight, size: 14, color: hh.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type, required this.hh});
  final String type;
  final HHTokens hh;

  static Color colorForType(String type) => switch (type.toUpperCase()) {
        'A'     => const Color(0xFF38BDF8),
        'AAAA'  => const Color(0xFF60A5FA),
        'CNAME' => const Color(0xFFA855F7),
        'TXT'   => const Color(0xFFF59E0B),
        'MX'    => const Color(0xFF10B981),
        'NS'    => const Color(0xFFEC4899),
        'SRV'   => const Color(0xFF818CF8),
        'CAA'   => const Color(0xFF14B8A6),
        _       => const Color(0xFF94A3B8),
      };

  @override
  Widget build(BuildContext context) {
    final c = colorForType(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      constraints: const BoxConstraints(minWidth: 44),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: HHRadius.pillBr(),
        border: Border.all(
          color: c.withValues(alpha: 0.28),
          width: 0.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        type.toUpperCase(),
        style: HHTextStyles.mono(c).copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

