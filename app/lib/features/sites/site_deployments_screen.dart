

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/project.dart';
import '../../models/site.dart';
import '../../shared/formatters.dart';
import '../../shared/theme.dart';
import '../../state/deployments_notifier.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_grouped_section.dart';
import '../../widgets/app_list_row.dart';
import '../../widgets/app_status_pill.dart';
import '../../widgets/skeleton.dart';
import '../deploys/deployment_detail_screen.dart';

class SiteDeploymentsScreen extends ConsumerWidget {
  const SiteDeploymentsScreen({
    super.key,
    required this.site,
    required this.project,
  });

  final Site site;
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hh = context.hh;
    final args = (connectionId: project.connectionId, projectId: project.id);
    final deploysAsync = ref.watch(projectDeploymentsProvider(args));

    return Scaffold(
      backgroundColor: hh.bgBase,
      body: CustomScrollView(
        slivers: [
          AppNavBar(title: '${site.displayName} Deploys'),

          CupertinoSliverRefreshControl(
            onRefresh: () async {
              ref.invalidate(projectDeploymentsProvider(args));
              await ref.read(projectDeploymentsProvider(args).future);
            },
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: HHSpacing.lg),
            sliver: deploysAsync.when(
              loading: () => SliverToBoxAdapter(
                child: AppGroupedSection(
                  header: 'History',
                  children: List.generate(6, (_) => const ListRowSkeleton()),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.alertTriangle, size: 40, color: hh.statusQueued),
                      const SizedBox(height: HHSpacing.md),
                      Text('Could not load deployments', style: hh.body()),
                      const SizedBox(height: HHSpacing.sm),
                      TextButton(
                        onPressed: () {
                          ref.invalidate(projectDeploymentsProvider(args));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (deploys) {
                if (deploys.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.gitBranch, size: 40, color: hh.textTertiary),
                          const SizedBox(height: HHSpacing.md),
                          Text('No deployments found', style: hh.body()),
                        ],
                      ),
                    ),
                  );
                }

                return SliverToBoxAdapter(
                  child: AppGroupedSection(
                    header: '${deploys.length} Deployments',
                    children: deploys.map((d) {
                      return AppListRow(
                        title: (d.commitMessage?.trim().isNotEmpty == true)
                            ? d.commitMessage!.trim()
                            : relativeTime(d.createdAt),
                        titleMaxLines: 2,
                        subtitle: [
                          shortSha(d.commitSha),
                          if (d.branch != null) d.branch,
                          relativeTime(d.createdAt),
                        ].whereType<String>().where((s) => s.isNotEmpty).join(' · '),
                        trailingWidget: AppStatusPill(status: d.status),
                        showChevron: true,
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (_) => DeploymentDetailScreen(deployment: d),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
