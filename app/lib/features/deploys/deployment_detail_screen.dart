

import 'package:flutter/material.dart';
import '../../models/deployment.dart';
import '../../models/deploy_status.dart';
import '../../shared/formatters.dart';
import '../../shared/theme.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_grouped_section.dart';
import '../../widgets/app_list_row.dart';
import '../../widgets/app_status_pill.dart';
import '../../widgets/copyable_value.dart';

class DeploymentDetailScreen extends StatelessWidget {
  const DeploymentDetailScreen({super.key, required this.deployment});
  final Deployment deployment;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;

    return Scaffold(
      backgroundColor: hh.bgBase,
      body: CustomScrollView(
        slivers: [
          const AppNavBar(title: 'Deployment'),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: HHSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HHSpacing.screenPadding,
                    vertical: HHSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      AppStatusPill(status: deployment.status),
                      if (deployment.duration != null) ...[
                        const SizedBox(height: HHSpacing.xs),
                        Text(
                          formatDuration(deployment.duration),
                          style: hh.footnote(),
                        ),
                      ],
                    ],
                  ),
                ),

                AppGroupedSection(
                  header: 'Commit',
                  children: [
                    if (deployment.commitSha != null)
                      AppListRow(
                        title: 'SHA',
                        trailingWidget: CopyableValue(
                          value: deployment.commitSha!,
                          label: shortSha(deployment.commitSha),
                        ),
                      ),
                    if (deployment.commitAuthor != null)
                      AppListRow(
                        title: 'Author',
                        trailingValue: deployment.commitAuthor,
                      ),
                    if (deployment.commitMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: HHSpacing.lg,
                          vertical: HHSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MESSAGE',
                              style: hh.caption2().copyWith(color: hh.textTertiary),
                            ),
                            const SizedBox(height: HHSpacing.xs),
                            SelectableText(
                              deployment.commitMessage!,
                              style: hh.body().copyWith(height: 1.4),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: HHSpacing.xl),

                AppGroupedSection(
                  header: 'Details',
                  children: [
                    if (deployment.branch != null)
                      AppListRow(title: 'Branch', trailingValue: deployment.branch),
                    if (deployment.environment != null)
                      AppListRow(title: 'Environment',
                          trailingValue: _envLabel(deployment.environment!)),
                    AppListRow(
                      title: 'Created',
                      trailingValue: deployment.createdAt.toLocal().toString().substring(0, 16),
                    ),
                    if (deployment.duration != null)
                      AppListRow(
                        title: 'Duration',
                        trailingValue: formatDuration(deployment.duration),
                      ),
                  ],
                ),

                const SizedBox(height: HHSpacing.xl),

                if (deployment.url != null)
                  AppGroupedSection(
                    header: 'URLs',
                    children: [
                      AppListRow(
                        title: 'Deploy URL',
                        trailingWidget: CopyableValue(
                          value: deployment.url!,
                          label: _shortenUrl(deployment.url!),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: HHSpacing.xl),

                if (deployment.status == DeployStatus.failed &&
                    deployment.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HHSpacing.screenPadding,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(HHSpacing.md),
                      decoration: BoxDecoration(
                        color: hh.bgElevated,
                        borderRadius: HHRadius.cardBr(),
                        border: Border(
                          left: BorderSide(color: hh.statusFailed, width: 3),
                        ),
                      ),
                      child: SelectableText(
                        deployment.errorMessage!,
                        style: hh.mono().copyWith(color: hh.textSecondary),
                      ),
                    ),
                  ),

                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _envLabel(String raw) => switch (raw.toLowerCase()) {
        'production' => 'Production',
        'preview'    => 'Preview',
        _            => raw,
      };

  String _shortenUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri?.host ?? url;
  }
}
