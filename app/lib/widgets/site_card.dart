

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/site.dart';
import '../models/site_alert.dart';
import '../models/deploy_status.dart';
import '../shared/theme.dart';
import '../shared/formatters.dart';
import 'app_pressable.dart';
import 'app_status_pill.dart';
import 'provider_badge.dart';

class SiteCard extends StatelessWidget {
  const SiteCard({
    super.key,
    required this.site,
    this.onTap,
    this.onLongPress,
  });

  final Site site;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final deploy = site.latestDeployment;
    final project = site.hostProject;
    final status = deploy?.status ?? DeployStatus.unknown;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HHSpacing.screenPadding),
      child: AppPressable(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      site.displayName,
                      style: hh.headline(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: HHSpacing.sm),
                  AppStatusPill(status: status),
                ],
              ),

              const SizedBox(height: HHSpacing.xs),

              if (project != null)
                Row(
                  children: [
                    ProviderBadge(providerId: project.providerId),
                    const SizedBox(width: HHSpacing.xs),
                    if (deploy?.branch != null) ...[
                      Text(
                        deploy!.branch!,
                        style: hh.footnote(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(' · ', style: hh.footnote()),
                    ],
                    Text(
                      relativeTime(deploy?.createdAt),
                      style: hh.footnote(),
                    ),
                  ],
                ),

              if (site.hasAlerts) ...[
                const SizedBox(height: HHSpacing.sm),
                _AlertRow(alerts: site.alerts, hh: hh),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alerts, required this.hh});
  final List<SiteAlert> alerts;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    final sorted = [...alerts]..sort((a, b) =>
        b.severity.index.compareTo(a.severity.index));
    final top = sorted.first;
    final color = top.isError ? hh.statusFailed : hh.statusQueued;
    final icon = top.isError ? LucideIcons.alertCircle : LucideIcons.alertTriangle;

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: HHSpacing.xs),
        Expanded(
          child: Text(
            sorted.map((a) => a.message).join(' · '),
            style: hh.footnote().copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
