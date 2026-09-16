

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/deploy_status.dart';
import '../shared/theme.dart';

class AppStatusPill extends StatefulWidget {
  const AppStatusPill({super.key, required this.status, this.label});

  final DeployStatus status;

  /// Override label text. Defaults to the canonical status name.
  final String? label;

  @override
  State<AppStatusPill> createState() => _AppStatusPillState();
}

class _AppStatusPillState extends State<AppStatusPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.status == DeployStatus.building) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(AppStatusPill old) {
    super.didUpdateWidget(old);
    if (widget.status == DeployStatus.building) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final statusColor = _resolveColor(widget.status);
    final icon = _resolveIcon(widget.status);
    final label = widget.label ?? _resolveLabel(widget.status);
    final bg = statusColor.withValues(alpha: 0.15);

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
          if (widget.status == DeployStatus.building)
            AnimatedBuilder(
              animation: _rotationController,
              builder: (_, child) => Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159,
                child: child,
              ),
              child: Icon(icon, size: 12, color: statusColor),
            )
          else
            Icon(icon, size: 12, color: statusColor),

          const SizedBox(width: HHSpacing.xs),

          Text(
            label,
            style: hh.caption().copyWith(color: statusColor),
          ),
        ],
      ),
    );
  }

  static Color _resolveColor(DeployStatus s) => switch (s) {
        DeployStatus.ready     => HHColors.statusReady,
        DeployStatus.building  => HHColors.statusBuilding,
        DeployStatus.queued    => HHColors.statusQueued,
        DeployStatus.failed    => HHColors.statusFailed,
        DeployStatus.cancelled => HHColors.statusCancelled,
        DeployStatus.unknown   => HHColors.statusUnknown,
      };

  static IconData _resolveIcon(DeployStatus s) => switch (s) {
        DeployStatus.ready     => LucideIcons.check,
        DeployStatus.building  => LucideIcons.loader,
        DeployStatus.queued    => LucideIcons.clock,
        DeployStatus.failed    => LucideIcons.x,
        DeployStatus.cancelled => LucideIcons.minus,
        DeployStatus.unknown   => LucideIcons.helpCircle,
      };

  static String _resolveLabel(DeployStatus s) => switch (s) {
        DeployStatus.ready     => 'Ready',
        DeployStatus.building  => 'Building',
        DeployStatus.queued    => 'Queued',
        DeployStatus.failed    => 'Failed',
        DeployStatus.cancelled => 'Cancelled',
        DeployStatus.unknown   => 'Unknown',
      };
}
