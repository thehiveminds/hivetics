import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/registered_domain.dart';
import '../shared/formatters.dart';
import '../shared/theme.dart';
import 'app_pressable.dart';
import 'domain_status_pill.dart';
import 'provider_badge.dart';

/// Card component representing a registered domain.
/// Follows the visual architecture of [SiteCard] with consistent padding,
/// typography, borders, and alert badges.
class DomainCard extends StatelessWidget {
  const DomainCard({
    super.key,
    required this.domain,
    this.onTap,
    this.onLongPress,
  });

  final RegisteredDomain domain;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final status = _effectiveStatus(domain);

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
              // Row 1: Domain Name + Status Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      domain.domain,
                      style: hh.headline(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: HHSpacing.sm),
                  DomainStatusPill(status: status),
                ],
              ),

              const SizedBox(height: HHSpacing.xs),

              // Row 2: Registrar Icon + Registrar Name + Expiration Date + Auto-Renew + Lock
              Row(
                children: [
                  RegistrarBadge(registrarId: domain.registrar),
                  const SizedBox(width: HHSpacing.xs),
                  Text(
                    domain.registrar.displayName,
                    style: hh.footnote(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (domain.expiresAt != null) ...[
                    Text(' · ', style: hh.footnote()),
                    Text(
                      formatDate(domain.expiresAt!),
                      style: hh.footnote(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (domain.autoRenew != null) ...[
                    Text(' · ', style: hh.footnote()),
                    Text(
                      domain.autoRenew! ? 'Auto-renew on' : 'Auto-renew off',
                      style: hh.footnote().copyWith(
                            color: domain.autoRenew!
                                ? hh.textSecondary
                                : hh.statusQueued,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (domain.locked == true) ...[
                    Text(' · ', style: hh.footnote()),
                    Icon(
                      LucideIcons.lock,
                      size: 11,
                      color: hh.textTertiary,
                    ),
                  ],
                ],
              ),

              // Row 3: Alert Row (matching SiteCard's _AlertRow)
              if (_hasAlerts(domain)) ...[
                const SizedBox(height: HHSpacing.sm),
                _DomainAlertRow(domain: domain, hh: hh),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static DomainStatus _effectiveStatus(RegisteredDomain d) {
    if (d.isExpired) return DomainStatus.expired;
    if (d.isExpiringSoon) return DomainStatus.expiring;
    return d.status;
  }

  static bool _hasAlerts(RegisteredDomain d) =>
      d.isExpired || d.isExpiringSoon || d.autoRenew == false;
}

class _DomainAlertRow extends StatelessWidget {
  const _DomainAlertRow({required this.domain, required this.hh});

  final RegisteredDomain domain;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    final isError = domain.isExpired;
    final color = isError ? hh.statusFailed : hh.statusQueued;
    final icon = isError ? Icons.error_outline : Icons.warning_amber_rounded;

    final String message;
    if (domain.isExpired) {
      message = 'Domain expired — renew immediately to prevent loss';
    } else if (domain.isExpiringSoon) {
      final days = domain.daysUntilExpiry ?? 0;
      message = 'Expires in $days days';
    } else {
      message = 'Auto-renew is disabled';
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: HHSpacing.xs),
        Expanded(
          child: Text(
            message,
            style: hh.footnote().copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
