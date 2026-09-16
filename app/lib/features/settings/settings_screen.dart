

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/connection.dart';
import '../../models/deploy_status.dart';
import '../../models/service_ref.dart';
import '../../shared/theme.dart';
import '../../state/connections_notifier.dart';
import '../../state/theme_notifier.dart';
import '../../widgets/app_nav_bar.dart';
import '../../widgets/app_grouped_section.dart';
import '../../widgets/app_list_row.dart';
import '../../widgets/app_status_pill.dart';
import '../../widgets/provider_badge.dart';
import '../connect/add_connection_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hh = context.hh;
    final connectionsAsync = ref.watch(connectionsProvider);
    final themeMode = ref.watch(themeProvider);

    return CustomScrollView(
      slivers: [
        const AppNavBar(title: 'Settings'),

        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: HHSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              connectionsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (connections) => AppGroupedSection(
                  header: 'Connections',
                  children: [
                    ...connections.map(
                      (c) => _ConnectionRow(connection: c, hh: hh, ref: ref),
                    ),
                    AppListRow(
                      title: 'Add connection',
                      leadingIcon: LucideIcons.plus,
                      leadingIconColor: hh.accent,
                      onTap: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const AddConnectionSheet(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: HHSpacing.xl),

              AppGroupedSection(
                header: 'Subscription',
                children: [
                  AppListRow(
                    title: 'Hivetics Pro',
                    subtitle: 'Coming in a future update',
                    leadingIcon: LucideIcons.zap,
                    leadingIconColor: hh.accent,
                  ),
                ],
              ),

              const SizedBox(height: HHSpacing.xl),

              AppGroupedSection(
                header: 'Appearance',
                children: [
                  AppListRow(
                    title: 'Theme',
                    trailingWidget: _ThemePicker(
                      current: themeMode,
                      onChanged: (m) =>
                          ref.read(themeProvider.notifier).setMode(m),
                      hh: hh,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: HHSpacing.xl),

              AppGroupedSection(
                header: 'About',
                children: [
                  const AppListRow(title: 'Version', trailingValue: '0.1.0'),
                  AppListRow(
                    title: 'GitHub',
                    leadingIcon: LucideIcons.code,
                    showChevron: true,
                    onTap: () => launchUrl(
                      Uri.parse('https://github.com/thehiveminds/hivetics'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  AppListRow(
                    title: 'thehiveminds.in',
                    leadingIcon: LucideIcons.globe,
                    showChevron: true,
                    onTap: () => launchUrl(
                      Uri.parse('https://thehiveminds.in'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  AppListRow(
                    title: 'Privacy Policy',
                    leadingIcon: LucideIcons.shield,
                    showChevron: true,
                    onTap: () => launchUrl(
                      Uri.parse('https://thehiveminds.in/hive-hub/privacy'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  AppListRow(
                    title: 'Open Source Licences',
                    leadingIcon: LucideIcons.fileText,
                    showChevron: true,
                    onTap: () => showLicensePage(context: context),
                  ),
                ],
              ),

              const SizedBox(height: 120),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow({
    required this.connection,
    required this.hh,
    required this.ref,
  });
  final Connection connection;
  final HHTokens hh;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return AppListRow(
      title: connection.displayName,
      subtitle: connection.service.displayName,
      leadingWidget: switch (connection.service) {
        HostRef(:final provider) => ProviderBadge(providerId: provider),
        // Registrar badge lands with the Settings grouping in §5.6.
        RegistrarRef() => const SizedBox(width: 18, height: 18),
      },
      trailingWidget: connection.hasError
          ? AppStatusPill(
              status: connection.isUnauthorized
                  ? DeployStatus.queued
                  : DeployStatus.unknown,
              label: connection.isUnauthorized ? 'Reconnect' : 'Error',
            )
          : null,
      showChevron: true,
      onTap: () => _showConnectionOptions(context),
    );
  }

  void _showConnectionOptions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text(connection.displayName),
        message: Text(connection.service.displayName),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(connectionsProvider.notifier)
                  .deleteConnection(connection.id);
            },
            child: const Text('Remove connection'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({
    required this.current,
    required this.onChanged,
    required this.hh,
  });
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<ThemeMode>(
      groupValue: current,
      children: const {
        ThemeMode.system: Text('Auto'),
        ThemeMode.light: Text('Light'),
        ThemeMode.dark: Text('Dark'),
      },
      onValueChanged: (m) {
        if (m != null) onChanged(m);
      },
      backgroundColor: hh.fill,
      thumbColor: hh.bgElevated,
    );
  }
}
