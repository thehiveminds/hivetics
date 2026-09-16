// MIT Licence — TheHiveMinds / Hivetics
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/dns_record.dart';
import '../../models/registrar_id.dart';
import '../../shared/haptics.dart';
import '../../shared/theme.dart';
import '../../state/domains_notifier.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_pressable.dart';
import '../../widgets/copyable_value.dart';
import '../../widgets/skeleton.dart';

class DnsRecordsScreen extends ConsumerStatefulWidget {
  const DnsRecordsScreen({
    super.key,
    required this.connectionId,
    required this.domain,
    required this.registrar,
  });

  final String connectionId;
  final String domain;
  final RegistrarId registrar;

  @override
  ConsumerState<DnsRecordsScreen> createState() => _DnsRecordsScreenState();
}

class _DnsRecordsScreenState extends ConsumerState<DnsRecordsScreen> {
  String _typeFilter = 'All';

  static const _types = ['All', 'A', 'CNAME', 'TXT', 'MX', 'NS'];

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final recordsAsync = ref.watch(dnsRecordsProvider((
      connectionId: widget.connectionId,
      domain: widget.domain,
      registrar: widget.registrar,
    )));

    return Scaffold(
      backgroundColor: hh.bgBase,
      body: CustomScrollView(
        slivers: [
          AppNavBar(
            title: widget.domain,
          ),

          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: HHSpacing.screenPadding,
                vertical: HHSpacing.sm,
              ),
              child: Row(
                children: _types.map((t) {
                  final selected = _typeFilter == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: HHSpacing.xs),
                    child: AppPressable(
                      onTap: () {
                        HHHaptics.selectionClick();
                        setState(() => _typeFilter = t);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? hh.accent : hh.bgElevated2,
                          borderRadius: HHRadius.pillBr(),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            color: selected ? const Color(0xFF000000) : hh.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

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
                  child: Text('Could not load DNS records', style: hh.body()),
                ),
              ),
            ),
            data: (records) {
              final filtered = _applyFilters(records);
              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No DNS records found',
                      style: hh.body().copyWith(color: hh.textSecondary),
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

          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
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
                  const Icon(
                    LucideIcons.cloud,
                    color: Color(0xFFF6821F),
                    size: 20,
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
                  Text(
                    record.name,
                    style: hh.headline().copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    record.content,
                    style: HHTextStyles.mono(hh.textSecondary).copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (record.proxied) ...[
              const SizedBox(width: HHSpacing.xs),
              const Icon(
                LucideIcons.cloud,
                color: Color(0xFFF6821F),
                size: 16,
              ),
            ],
            const SizedBox(width: HHSpacing.sm),
            Text(
              record.isAutoTtl ? 'Auto' : (record.ttl != null ? '${record.ttl}s' : ''),
              style: hh.footnote(),
            ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 26,
      decoration: BoxDecoration(
        color: hh.bgElevated2,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        type.toUpperCase(),
        style: HHTextStyles.mono(hh.textPrimary).copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
