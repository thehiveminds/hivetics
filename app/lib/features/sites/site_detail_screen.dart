

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/connection.dart';
import '../../models/registered_domain.dart';
import '../../models/site.dart';
import '../../models/deployment.dart';
import '../../models/deploy_status.dart';
import '../../shared/formatters.dart';
import '../../shared/theme.dart';
import '../../state/deployments_notifier.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_grouped_section.dart';
import '../../widgets/app_list_row.dart';
import '../../widgets/app_status_pill.dart';
import '../../widgets/provider_badge.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/copyable_value.dart';
import '../deploys/deployment_detail_screen.dart';
import '../dns/dns_records_screen.dart';
import 'site_deployments_screen.dart';
import 'widgets/site_analytics_section.dart';
import 'widgets/site_search_section.dart';

class SiteDetailScreen extends ConsumerWidget {
  const SiteDetailScreen({super.key, required this.site});
  final Site site;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hh = context.hh;
    final project = site.hostProject;

    final deploysAsync = project != null
        ? ref.watch(projectDeploymentsProvider((
            connectionId: project.connectionId,
            projectId: project.id,
          )))
        : null;

    return Scaffold(
      backgroundColor: hh.bgBase,
      body: CustomScrollView(
        slivers: [
          AppNavBar(
            title: site.displayName,
            subtitle: [
              if (project != null) project.providerId.displayName,
              if (project?.framework != null) project!.framework!,
            ].join(' · ').isNotEmpty
                ? [
                    if (project != null) project.providerId.displayName,
                    if (project?.framework != null) project!.framework!,
                  ].join(' · ')
                : null,
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: HHSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: HHSpacing.screenPadding),
                  child: _HeroSection(site: site, hh: hh),
                ),

                const SizedBox(height: HHSpacing.xl),

                if (deploysAsync != null)
                  deploysAsync.when(
                    loading: () => _deploysSection(
                      hh: hh,
                      children: List.generate(3, (_) => const ListRowSkeleton()),
                    ),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (deploys) => _deploysSection(
                      hh: hh,
                      children: [
                        ...deploys.take(5).map((d) => _DeployRow(
                              deployment: d,
                              hh: hh,
                              onTap: () => Navigator.of(context).push(
                                CupertinoPageRoute<void>(
                                  builder: (_) => DeploymentDetailScreen(deployment: d),
                                ),
                              ),
                            )),
                        if (deploys.length > 5 && project != null)
                          AppListRow(
                            title: 'See all deployments',
                            showChevron: true,
                            titleStyle: hh.body().copyWith(color: hh.accent),
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute<void>(
                                builder: (_) => SiteDeploymentsScreen(
                                  site: site,
                                  project: project,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: HHSpacing.xl),

                if (project != null && project.providerId == ProviderId.vercel) ...[
                  SiteAnalyticsSection(
                    connectionId: project.connectionId,
                    projectId: project.id,
                    site: site,
                  ),
                  const SizedBox(height: HHSpacing.xl),
                ],

                SiteSearchSection(site: site),
                const SizedBox(height: HHSpacing.xl),

                if (site.registration != null) ...[
                  _domainSection(
                    context: context,
                    hh: hh,
                    reg: site.registration!,
                  ),
                  const SizedBox(height: HHSpacing.xl),
                ],

                if (project != null)
                  AppGroupedSection(
                    header: 'Links',
                    children: [
                      AppListRow(
                        title: 'Open in ${project.providerId.displayName}',
                        leadingIcon: LucideIcons.externalLink,
                        leadingIconColor: hh.accent,
                        showChevron: true,
                        onTap: () => launchUrl(
                          Uri.parse(project.dashboardUrl()),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      if (site.domain != null)
                        AppListRow(
                          title: 'Open site',
                          leadingIcon: LucideIcons.globe,
                          leadingIconColor: hh.accent,
                          showChevron: true,
                          onTap: () => launchUrl(
                            Uri.parse('https://${site.domain}'),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                    ],
                  ),

                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deploysSection({required HHTokens hh, required List<Widget> children}) {
    return AppGroupedSection(
      header: 'Deployments',
      children: children,
    );
  }

  Widget _domainSection({
    required BuildContext context,
    required HHTokens hh,
    required RegisteredDomain reg,
  }) {
    final days = reg.daysUntilExpiry;
    final expColor = reg.isExpired
        ? hh.statusFailed
        : (reg.isExpiringSoon ? hh.statusQueued : hh.textSecondary);
    final expiryFormatted = reg.expiresAt != null
        ? DateFormat('d MMM yyyy').format(reg.expiresAt!.toLocal())
        : '—';
    final expirySubtitle = days != null
        ? '$expiryFormatted (${daysUntilExpiry(days)})'
        : expiryFormatted;

    return AppGroupedSection(
      header: 'Domain',
      headerColor: reg.isExpired
          ? hh.statusFailed
          : (reg.isExpiringSoon ? hh.statusQueued : null),
      children: [
        AppListRow(
          title: reg.domain,
          leadingWidget: RegistrarBadge(registrarId: reg.registrar),
          trailingValue: reg.registrar.displayName,
        ),
        AppListRow(
          title: 'Expires',
          trailingWidget: Text(
            expirySubtitle,
            style: hh.body().copyWith(
                  color: expColor,
                  fontSize: 14,
                ),
          ),
        ),
        if (reg.autoRenew != null)
          AppListRow(
            title: 'Auto-renew',
            trailingWidget: Text(
              reg.autoRenew! ? 'On' : 'Off',
              style: hh.body().copyWith(
                    color: (!reg.autoRenew! && days != null && days <= 60)
                        ? hh.statusQueued
                        : hh.textSecondary,
                    fontSize: 14,
                    fontWeight: (!reg.autoRenew! && days != null && days <= 60)
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
            ),
          ),
        if (reg.locked != null)
          AppListRow(
            title: 'Transfer lock',
            trailingValue: reg.locked! ? 'Locked' : 'Unlocked',
          ),
        if (reg.nameServers.isNotEmpty)
          AppListRow(
            title: 'Nameservers',
            subtitle: reg.nameServers.join(', '),
          ),
        AppListRow(
          title: 'DNS records',
          leadingIcon: LucideIcons.globe,
          leadingIconColor: hh.accent,
          showChevron: true,
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute<void>(
              builder: (_) => DnsRecordsScreen(
                connectionId: reg.connectionId,
                domain: reg.domain,
                registrar: reg.registrar,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.site, required this.hh});
  final Site site;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    final deploy = site.latestDeployment;
    final project = site.hostProject;

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
              if (deploy != null)
                AppStatusPill(status: deploy.status)
              else
                const AppStatusPill(status: DeployStatus.unknown),
              const Spacer(),
              if (deploy?.createdAt != null)
                Text(
                  relativeTime(deploy!.createdAt),
                  style: hh.footnote().copyWith(color: hh.textSecondary),
                ),
            ],
          ),
          if (deploy?.url != null) ...[
            const SizedBox(height: HHSpacing.md),
            CopyableValue(value: deploy!.url!, label: deploy.url),
          ],
          const SizedBox(height: HHSpacing.md),
          Divider(height: 0.5, thickness: 0.5, color: hh.separator),
          const SizedBox(height: HHSpacing.sm),
          Row(
            children: [
              if (project != null) ...[
                ProviderBadge(providerId: project.providerId),
                const SizedBox(width: HHSpacing.xs),
                Text(
                  project.providerId.displayName,
                  style: hh.footnote().copyWith(color: hh.textSecondary),
                ),
              ],
              if (deploy?.branch != null) ...[
                const SizedBox(width: HHSpacing.xs),
                Text('·', style: hh.footnote().copyWith(color: hh.textTertiary)),
                const SizedBox(width: HHSpacing.xs),
                Icon(LucideIcons.gitBranch, size: 13, color: hh.textTertiary),
                const SizedBox(width: 3),
                Text(
                  deploy!.branch!,
                  style: hh.footnote().copyWith(color: hh.textSecondary),
                ),
              ],
              if (project?.framework != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: hh.bgElevated2,
                    borderRadius: HHRadius.pillBr(),
                    border: Border.all(
                      color: hh.cardBorder.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    project!.framework!,
                    style: hh.caption().copyWith(fontSize: 11, color: hh.textSecondary),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
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
    return AppListRow(
      title: (deployment.commitMessage?.trim().isNotEmpty == true)
          ? deployment.commitMessage!.trim()
          : relativeTime(deployment.createdAt),
      titleMaxLines: 2,
      subtitle: [
        shortSha(deployment.commitSha),
        if (deployment.branch != null) deployment.branch,
      ].whereType<String>().where((s) => s.isNotEmpty).join(' · '),
      trailingWidget: AppStatusPill(status: deployment.status),
      showChevron: true,
      onTap: onTap,
    );
  }
}
