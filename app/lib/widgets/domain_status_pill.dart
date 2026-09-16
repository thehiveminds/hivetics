import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/registered_domain.dart';
import '../shared/theme.dart';

/// Pill widget specifically designed for domain registration statuses.
/// Adheres strictly to DESIGN §4:
/// - caption label + 12px icon, padding 4 8, radius pill, bg = status @15%
/// - Never color-only (always includes icon + text)
class DomainStatusPill extends StatelessWidget {
  const DomainStatusPill({
    super.key,
    required this.status,
    this.label,
  });

  final DomainStatus status;

  /// Optional override label. Defaults to canonical status name.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final color = _resolveColor(status);
    final icon = _resolveIcon(status);
    final text = label ?? _resolveLabel(status);
    final bg = color.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HHSpacing.sm,
        vertical: HHSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: HHRadius.pillBr(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: HHSpacing.xs),
          Text(
            text,
            style: hh.caption().copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  static Color _resolveColor(DomainStatus s) => switch (s) {
        DomainStatus.active    => HHColors.statusReady,
        DomainStatus.expiring  => HHColors.statusQueued,
        DomainStatus.expired   => HHColors.statusFailed,
        DomainStatus.suspended => HHColors.statusFailed,
        DomainStatus.cancelled => HHColors.statusCancelled,
        DomainStatus.pending   => HHColors.statusBuilding,
        DomainStatus.unknown   => HHColors.statusUnknown,
      };

  static IconData _resolveIcon(DomainStatus s) => switch (s) {
        DomainStatus.active    => LucideIcons.check,
        DomainStatus.expiring  => LucideIcons.clock,
        DomainStatus.expired   => LucideIcons.alertTriangle,
        DomainStatus.suspended => LucideIcons.pauseCircle,
        DomainStatus.cancelled => LucideIcons.slash,
        DomainStatus.pending   => LucideIcons.loader,
        DomainStatus.unknown   => LucideIcons.helpCircle,
      };

  static String _resolveLabel(DomainStatus s) => switch (s) {
        DomainStatus.active    => 'Active',
        DomainStatus.expiring  => 'Expiring soon',
        DomainStatus.expired   => 'Expired',
        DomainStatus.suspended => 'Suspended',
        DomainStatus.cancelled => 'Cancelled',
        DomainStatus.pending   => 'Pending',
        DomainStatus.unknown   => 'Unknown',
      };
}
