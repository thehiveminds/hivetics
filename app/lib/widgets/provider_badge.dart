

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/connection.dart';
import '../models/registrar_id.dart';
import '../shared/theme.dart';

class ProviderBadge extends StatelessWidget {
  const ProviderBadge({
    super.key,
    required this.providerId,
    this.size = 18,
    this.showLabel = false,
  });

  final ProviderId providerId;
  final double size;

  /// Force a text label alongside the badge. Always true for Cloudflare.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final config = _config(providerId, hh);
    final alwaysLabel = providerId == ProviderId.cloudflarepages || showLabel;

    final badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(HHRadius.providerBadge),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        config.svgPath,
        width: size * 0.65,
        height: size * 0.65,
        colorFilter: ColorFilter.mode(config.fg, BlendMode.srcIn),
        placeholderBuilder: (_) => Icon(
          config.fallbackIcon,
          size: size * 0.65,
          color: config.fg,
        ),
      ),
    );

    if (!alwaysLabel) return badge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        const SizedBox(width: HHSpacing.xs),
        Text(
          providerId.displayName,
          style: HHTextStyles.caption(hh.textSecondary),
        ),
      ],
    );
  }

  static _BadgeConfig _config(ProviderId id, HHTokens hh) => switch (id) {
        ProviderId.vercel => _BadgeConfig(
            svgPath: 'assets/icons/vercel.svg',
            fallbackIcon: LucideIcons.triangle,
            bg: hh.isDark ? HHColors.vercelBg : const Color(0xFFFFFFFF),
            fg: hh.isDark ? HHColors.vercelFg : const Color(0xFF000000),
          ),
        ProviderId.netlify => const _BadgeConfig(
            svgPath: 'assets/icons/netlify.svg',
            fallbackIcon: LucideIcons.box,
            bg: HHColors.netlifyBg,
            fg: Color(0xFFFFFFFF),
          ),
        ProviderId.cloudflarepages => const _BadgeConfig(
            svgPath: 'assets/icons/cloudflare.svg',
            fallbackIcon: LucideIcons.cloud,
            bg: HHColors.cloudflareBg,
            fg: Color(0xFFFFFFFF),
          ),
      };
}

class RegistrarBadge extends StatelessWidget {
  const RegistrarBadge({
    super.key,
    required this.registrarId,
    this.size = 18,
    this.showLabel = false,
  });

  final RegistrarId registrarId;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;
    final config = _config(registrarId, hh);
    final alwaysLabel =
        registrarId == RegistrarId.cloudflareregistrar || showLabel;

    final badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(HHRadius.providerBadge),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        config.svgPath,
        width: size * 0.65,
        height: size * 0.65,
        colorFilter: ColorFilter.mode(config.fg, BlendMode.srcIn),
        placeholderBuilder: (_) => Icon(
          config.fallbackIcon,
          size: size * 0.65,
          color: config.fg,
        ),
      ),
    );

    if (!alwaysLabel) return badge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        const SizedBox(width: HHSpacing.xs),
        Text(
          registrarId.displayName,
          style: HHTextStyles.caption(hh.textSecondary),
        ),
      ],
    );
  }

  static _BadgeConfig _config(RegistrarId id, HHTokens hh) => switch (id) {
        RegistrarId.godaddy => const _BadgeConfig(
            svgPath: 'assets/icons/godaddy.svg',
            fallbackIcon: LucideIcons.globe,
            bg: Color(0xFF1BDBDB),
            fg: Color(0xFF000000),
          ),
        RegistrarId.porkbun => const _BadgeConfig(
            svgPath: 'assets/icons/porkbun.svg',
            fallbackIcon: LucideIcons.globe,
            bg: Color(0xFFEF7878),
            fg: Color(0xFFFFFFFF),
          ),
        RegistrarId.cloudflareregistrar => const _BadgeConfig(
            svgPath: 'assets/icons/cloudflare.svg',
            fallbackIcon: LucideIcons.cloud,
            bg: HHColors.cloudflareBg,
            fg: Color(0xFFFFFFFF),
          ),
      };
}

class _BadgeConfig {
  const _BadgeConfig({
    required this.svgPath,
    required this.fallbackIcon,
    required this.bg,
    required this.fg,
  });
  final String svgPath;
  final IconData fallbackIcon;
  final Color bg;
  final Color fg;
}
