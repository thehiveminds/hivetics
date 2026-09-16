// MIT Licence — TheHiveMinds / Hive Hub
// ─────────────────────────────────────────────────────────────────────────────
// shared/theme.dart — SINGLE SOURCE OF TRUTH for every design token.
//
// Reference: DESIGN.md §0–§1.7, §2 (component specs).
// Dark is default (developer tool, checked at night).
// Light is a full parallel palette — not a tint flip.
//
// Rules baked in:
//   • MaterialApp + custom theme. NOT CupertinoApp.
//   • No Material ripple anywhere (NoSplash.splashFactory).
//   • Push transitions: CupertinoPageTransitionsBuilder (swipe-back mandatory).
//   • No FAB, no Material AppBar, no floating pill nav.
//   • Colour is NEVER the only signal (enforced in component specs, not here).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// § 1.1 / 1.2  COLOUR TOKENS
// ═══════════════════════════════════════════════════════════════════════════════

abstract final class HHColors {
  // ── Dark palette (default) ─────────────────────────────────────────────────
  static const darkBgBase = Color(0xFF000000); // OLED scaffold
  static const darkBgElevated = Color(0xFF1C1C1E); // cards, grouped rows
  static const darkBgElevated2 = Color(0xFF2C2C2E); // nested/pressed, inputs
  static const darkSeparator = Color(0xFF38383A); // hairlines — render at 0.5px
  static const darkFill = Color(0xFF3A3A3C); // seg track, sparkline baseline

  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0x99EBEBF5); // #EBEBF5 @ 60%
  static const darkTextTertiary = Color(0x4DEBEBF5); // #EBEBF5 @ 30%

  /// Hive Amber — brand, active nav, primary buttons, links.
  static const darkAccent = Color(0xFFF5A623);
  static const darkAccentPressed = Color(0xFFD18C14);

  // ── Light palette ──────────────────────────────────────────────────────────
  static const lightBgBase = Color(0xFFF2F2F7); // iOS grouped grey, NOT white
  static const lightBgElevated = Color(0xFFFFFFFF);
  static const lightBgElevated2 = Color(0xFFF2F2F7);
  static const lightSeparator = Color(0xFFC6C6C8);
  static const lightFill = Color(0xFFE3E3E8);

  static const lightTextPrimary = Color(0xFF000000);
  static const lightTextSecondary = Color(0x993C3C43); // #3C3C43 @ 60%
  static const lightTextTertiary = Color(0x4D3C3C43); // #3C3C43 @ 30%

  /// Darker amber for light theme — #F5A623 fails contrast on white.
  static const lightAccent = Color(0xFFE09112);
  static const lightAccentPressed = Color(0xFFB87510);

  // ── § 1.3  Status colours (identical in both themes) ──────────────────────
  /// deploy live · domain active · DNS proxied
  static const statusReady = Color(0xFF30D158); // green
  /// building · uploading · processing
  static const statusBuilding = Color(0xFF0A84FF); // blue
  /// queued · pending · NEEDS ATTENTION · connection errors
  static const statusQueued = Color(0xFFFF9F0A); // orange
  /// build FAILED · domain EXPIRED only — do not repurpose
  static const statusFailed = Color(0xFFFF453A); // red
  /// cancelled · skipped
  static const statusCancelled = Color(0xFF8E8E93); // grey
  /// unrecognised API value — must read as "nothing to worry about", not error
  static const statusUnknown = Color(
    0xFF8E8E93,
  ); // grey (same as cancelled on purpose)

  // ── § 1.4  Metric / trend colours ─────────────────────────────────────────
  /// Direction is not goodness — use MetricModel.higherIsBetter.
  static const trendUp = Color(0xFF30D158); // improved
  static const trendDown = Color(0xFFFF453A); // worsened
  static const trendFlat = Color(0xFF8E8E93); // < 2 % change

  // Sparkline: stroke = accent @ 70%, fill = accent @ 18% → transparent
  static Color sparklineStroke(Color accent) => accent.withValues(alpha: 0.70);
  static Color sparklineFill(Color accent) => accent.withValues(alpha: 0.18);

  // ── § 1.5  Provider brand colours (badges ONLY — nowhere else) ────────────
  // Hosts
  static const vercelBg = Color(
    0xFF000000,
  ); // inverts in light — handled in ProviderBadge
  static const vercelFg = Color(0xFFFFFFFF);
  static const netlifyBg = Color(0xFF00C7B7);
  static const cloudflareBg = Color(0xFFF6821F);

  // ⚠️  Cloudflare #F6821F ≈ Hive Amber → CF badges ALWAYS carry glyph + text label, never bare dot.

  // ── Status colour utilities ────────────────────────────────────────────────
  static Color statusColor(DeployStatusColor s) => switch (s) {
    DeployStatusColor.ready => statusReady,
    DeployStatusColor.building => statusBuilding,
    DeployStatusColor.queued => statusQueued,
    DeployStatusColor.failed => statusFailed,
    DeployStatusColor.cancelled => statusCancelled,
    DeployStatusColor.unknown => statusUnknown,
  };

  /// Background tint for status pills: status @ 15%.
  static Color statusPillBg(DeployStatusColor s) =>
      statusColor(s).withValues(alpha: 0.15);
}

/// Mirrors the DeployStatus model without importing the models layer.
/// Used purely for colour resolution in the theme.
enum DeployStatusColor { ready, building, queued, failed, cancelled, unknown }

// ═══════════════════════════════════════════════════════════════════════════════
// § 1.6  TYPOGRAPHY
// Font: Inter (google_fonts) — closest freely-licensable SF Pro substitute.
// Monospace: JetBrains Mono — for SHAs, DNS values, URLs.
// FontFeature.tabularFigures() on ALL numeric styles — counts must not jitter.
// ═══════════════════════════════════════════════════════════════════════════════

abstract final class HHTextStyles {
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  // ── Scale definition ───────────────────────────────────────────────────────
  /// 22 / w700 / -0.3 — well-proportioned screen title
  static TextStyle largeTitle(Color color) => GoogleFonts.manrope(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: color,
  );

  /// 17 / w600 / -0.2 — collapsed nav title
  static TextStyle navTitle(Color color) => GoogleFonts.manrope(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: color,
  );

  /// 28 / w700 / -0.3 — detail headline
  static TextStyle title1(Color color) => GoogleFonts.manrope(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: color,
  );

  /// 22 / w700 / -0.3 — section headline
  static TextStyle title2(Color color) => GoogleFonts.manrope(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: color,
  );

  /// 28 / w700 / -0.5 — big stat numbers, tabular
  static TextStyle metric(Color color) => GoogleFonts.manrope(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: color,
    fontFeatures: _tabular,
  );

  /// 17 / w600 / -0.2 — row primary text
  static TextStyle headline(Color color) => GoogleFonts.manrope(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: color,
  );

  /// 17 / w400 / -0.2 — body copy
  static TextStyle body(Color color) => GoogleFonts.manrope(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    color: color,
  );

  /// 15 / w400 / -0.1 — row subtitle
  static TextStyle subhead(Color color) => GoogleFonts.manrope(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    color: color,
  );

  /// 13 / w400 / 0 — metadata, timestamps
  static TextStyle footnote(Color color) => GoogleFonts.manrope(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: color,
    fontFeatures: _tabular,
  );

  /// 12 / w500 / 0 — pills, badges
  static TextStyle caption(Color color) => GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: color,
  );

  /// 11 / w600 / +0.3 — UPPERCASE group headers
  static TextStyle caption2(Color color) => GoogleFonts.manrope(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: color,
  );

  /// 13 / w400 / 0 — SHAs, DNS values, URLs — JetBrains Mono
  static TextStyle mono(Color color) => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: color,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// § 1.7  SPACING / RADIUS / MOTION
// ═══════════════════════════════════════════════════════════════════════════════

abstract final class HHSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal gutter on every screen.
  static const double screenPadding = 16;

  /// Minimum tap target — no exceptions.
  static const double rowHeight = 44;
}

abstract final class HHRadius {
  static const double card = 12;
  static const double sheet = 16;
  static const double button = 12;
  static const double pill = 999;
  static const double input = 10;
  static const double badge = 6;
  static const double iconTile = 7;
  static const double providerBadge = 5;

  static BorderRadius cardBr() => BorderRadius.circular(card);
  static BorderRadius sheetBr() =>
      const BorderRadius.vertical(top: Radius.circular(sheet));
  static BorderRadius buttonBr() => BorderRadius.circular(button);
  static BorderRadius pillBr() => BorderRadius.circular(pill);
  static BorderRadius inputBr() => BorderRadius.circular(input);
  static BorderRadius badgeBr() => BorderRadius.circular(badge);
  static BorderRadius iconTileBr() => BorderRadius.circular(iconTile);
}

abstract final class HHMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration sheet = Duration(milliseconds: 350);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve sheetInCurve = Curves.easeOutQuint;
  static const Curve sheetOutCurve = Curves.easeInQuad;

  /// Press-down scale for AppPressable.
  static const double pressScale = 0.97;
  static const double pressOpacity = 0.60;
  static const Duration pressDown = Duration(milliseconds: 100);
}

// ═══════════════════════════════════════════════════════════════════════════════
// THEME BUILDER — dark (default) + light
// ═══════════════════════════════════════════════════════════════════════════════

abstract final class HHTheme {
  // ── Dark ──────────────────────────────────────────────────────────────────
  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    bgBase: HHColors.darkBgBase,
    bgElevated: HHColors.darkBgElevated,
    bgElevated2: HHColors.darkBgElevated2,
    separator: HHColors.darkSeparator,
    fill: HHColors.darkFill,
    textPrimary: HHColors.darkTextPrimary,
    textSecondary: HHColors.darkTextSecondary,
    textTertiary: HHColors.darkTextTertiary,
    accent: HHColors.darkAccent,
    accentPressed: HHColors.darkAccentPressed,
  );

  // ── Light ─────────────────────────────────────────────────────────────────
  static ThemeData light() => _build(
    brightness: Brightness.light,
    bgBase: HHColors.lightBgBase,
    bgElevated: HHColors.lightBgElevated,
    bgElevated2: HHColors.lightBgElevated2,
    separator: HHColors.lightSeparator,
    fill: HHColors.lightFill,
    textPrimary: HHColors.lightTextPrimary,
    textSecondary: HHColors.lightTextSecondary,
    textTertiary: HHColors.lightTextTertiary,
    accent: HHColors.lightAccent,
    accentPressed: HHColors.lightAccentPressed,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color bgBase,
    required Color bgElevated,
    required Color bgElevated2,
    required Color separator,
    required Color fill,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color accent,
    required Color accentPressed,
  }) {
    final isDark = brightness == Brightness.dark;

    // Primary Manrope text theme used by Material widgets.
    final base = GoogleFonts.manropeTextTheme().copyWith(
      bodyLarge: GoogleFonts.manrope(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textTertiary,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textTertiary,
        letterSpacing: 0.3,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.4,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.2,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.1,
      ),
      headlineLarge: GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.3,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.3,
      ),
    );

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,

      // ── Colours ─────────────────────────────────────────────────────────
      scaffoldBackgroundColor: bgBase,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accent,
        onPrimary: const Color(0xFF000000), // amber is light; black on amber
        primaryContainer: accent.withValues(alpha: 0.15),
        onPrimaryContainer: accent,
        secondary: accent,
        onSecondary: const Color(0xFF000000),
        secondaryContainer: bgElevated2,
        onSecondaryContainer: textPrimary,
        surface: bgElevated,
        onSurface: textPrimary,
        surfaceContainerHighest: bgElevated2,
        outline: separator,
        outlineVariant: separator.withValues(alpha: 0.5),
        error: HHColors.statusFailed,
        onError: const Color(0xFFFFFFFF),
        errorContainer: HHColors.statusFailed.withValues(alpha: 0.15),
        onErrorContainer: HHColors.statusFailed,
        shadow: Colors.black,
        scrim: const Color(0x66000000),
        inverseSurface: isDark
            ? HHColors.lightBgElevated
            : HHColors.darkBgElevated,
        onInverseSurface: isDark
            ? HHColors.lightTextPrimary
            : HHColors.darkTextPrimary,
        inversePrimary: isDark ? HHColors.lightAccent : HHColors.darkAccent,
      ),

      // ── Typography ───────────────────────────────────────────────────────
      textTheme: base,

      // ── NO RIPPLE anywhere — all taps go through AppPressable ──────────
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,

      // ── AppBar (we use SliverAppBar, but base settings here) ───────────
      appBarTheme: AppBarTheme(
        backgroundColor: bgBase,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: bgBase,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: bgBase,
              ),
        iconTheme: IconThemeData(color: accent, size: 22),
        actionsIconTheme: IconThemeData(color: accent, size: 22),
        titleTextStyle: HHTextStyles.navTitle(textPrimary),
        centerTitle: true,
        shadowColor: Colors.transparent,
      ),

      // ── Cards ─────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: bgElevated,
        elevation: isDark ? 0 : 1,
        shadowColor: isDark
            ? Colors.transparent
            : Colors.black.withValues(alpha: 0.06),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: HHRadius.cardBr()),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: separator,
        thickness: 0.5,
        space: 0,
      ),

      // ── Input decoration ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgElevated2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HHSpacing.lg,
          vertical: HHSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: HHRadius.inputBr(),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: HHRadius.inputBr(),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: HHRadius.inputBr(),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: HHTextStyles.body(textTertiary),
        labelStyle: HHTextStyles.body(textSecondary),
      ),

      // ── Elevated button (primary) ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return accentPressed;
            if (states.contains(WidgetState.disabled)) {
              return accent.withValues(alpha: 0.30);
            }
            return accent;
          }),
          foregroundColor: WidgetStateProperty.all(const Color(0xFF000000)),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: HHRadius.buttonBr()),
          ),
          elevation: WidgetStateProperty.all(0),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          animationDuration: HHMotion.fast,
        ),
      ),

      // ── Text button ────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(accent),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w400),
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),

      // ── Bottom nav bar ────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: accent,
        unselectedItemColor: textTertiary,
        selectedLabelStyle: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Icon ──────────────────────────────────────────────────────────
      iconTheme: IconThemeData(color: textTertiary, size: 20),

      // ── Switch (Cupertino is used in practice, this is a fallback) ────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const Color(0xFFFFFFFF)
              : textTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accent : fill,
        ),
      ),

      // ── Progress indicator ────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),

      // ── Chip ──────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: bgElevated2,
        selectedColor: accent,
        labelStyle: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: HHRadius.pillBr()),
        side: BorderSide.none,
        elevation: 0,
        pressElevation: 0,
      ),

      // ── Bottom sheet ──────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bgElevated,
        modalBackgroundColor: bgElevated,
        shape: RoundedRectangleBorder(borderRadius: HHRadius.sheetBr()),
        clipBehavior: Clip.antiAlias,
        showDragHandle: false, // custom 36×5 handle in ModalSheet widget
        modalBarrierColor: const Color(0x66000000), // #000 @ 40%
        elevation: 0,
      ),

      // ── Dialog ────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: bgElevated,
        shape: RoundedRectangleBorder(borderRadius: HHRadius.cardBr()),
        titleTextStyle: HHTextStyles.headline(textPrimary),
        contentTextStyle: HHTextStyles.body(textSecondary),
        elevation: 0,
      ),

      // ── List tile ─────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HHSpacing.lg,
          vertical: HHSpacing.xs,
        ),
        minVerticalPadding: 0,
        minLeadingWidth: 0,
        dense: false,
        titleTextStyle: HHTextStyles.headline(textPrimary),
        subtitleTextStyle: HHTextStyles.subhead(textSecondary),
        leadingAndTrailingTextStyle: HHTextStyles.footnote(textTertiary),
      ),

      // ── Page transitions: CupertinoPageTransitionsBuilder ─────────────
      // Swipe-back from the left edge must work everywhere.
      // Its absence is the loudest "this is Android" tell.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// THEME EXTENSION — lets widgets access HH tokens via context
// ═══════════════════════════════════════════════════════════════════════════════

/// Access via: `context.hh`
extension HHThemeContext on BuildContext {
  HHTokens get hh => HHTokens.of(this);
}

/// All resolved token values for the current theme.
/// Obtained once per build, avoids scattered Theme.of(context) calls.
class HHTokens extends ThemeExtension<HHTokens> {
  const HHTokens({
    required this.bgBase,
    required this.bgElevated,
    required this.bgElevated2,
    required this.separator,
    required this.fill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentPressed,
    required this.isDark,
  });

  final Color bgBase;
  final Color bgElevated;
  final Color bgElevated2;
  final Color separator;
  final Color fill;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color accentPressed;
  final bool isDark;

  Color get cardBorder => separator.withValues(alpha: isDark ? 0.6 : 0.8);

  /// Resolved status colours (same both themes).
  Color get statusReady => HHColors.statusReady;
  Color get statusBuilding => HHColors.statusBuilding;
  Color get statusQueued => HHColors.statusQueued;
  Color get statusFailed => HHColors.statusFailed;
  Color get statusCancelled => HHColors.statusCancelled;
  Color get statusUnknown => HHColors.statusUnknown;

  /// Resolve for [DeployStatusColor].
  Color statusColor(DeployStatusColor s) => HHColors.statusColor(s);
  Color statusPillBg(DeployStatusColor s) => HHColors.statusPillBg(s);

  /// Trend colours.
  Color get trendUp => HHColors.trendUp;
  Color get trendDown => HHColors.trendDown;
  Color get trendFlat => HHColors.trendFlat;

  /// Sparkline colours derived from accent.
  Color get sparklineStroke => HHColors.sparklineStroke(accent);
  Color get sparklineFill => HHColors.sparklineFill(accent);

  // ── Text style helpers ─────────────────────────────────────────────────────
  TextStyle largeTitle() => HHTextStyles.largeTitle(textPrimary);
  TextStyle navTitle() => HHTextStyles.navTitle(textPrimary);
  TextStyle title1() => HHTextStyles.title1(textPrimary);
  TextStyle title2() => HHTextStyles.title2(textPrimary);
  TextStyle metric() => HHTextStyles.metric(textPrimary);
  TextStyle headline() => HHTextStyles.headline(textPrimary);
  TextStyle body() => HHTextStyles.body(textPrimary);
  TextStyle bodySecondary() => HHTextStyles.body(textSecondary);
  TextStyle subhead() => HHTextStyles.subhead(textSecondary);
  TextStyle footnote() => HHTextStyles.footnote(textTertiary);
  TextStyle caption() => HHTextStyles.caption(textPrimary);
  TextStyle captionAccent() => HHTextStyles.caption(accent);
  TextStyle caption2() => HHTextStyles.caption2(textTertiary);
  TextStyle mono() => HHTextStyles.mono(textSecondary);
  TextStyle monoTertiary() => HHTextStyles.mono(textTertiary);

  // ── Conveniece light-card shadow ──────────────────────────────────────────
  /// No shadows on dark cards. Light cards get a subtle 1px shadow.
  List<BoxShadow> get cardShadow => isDark
      ? []
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ];

  // ─────────────────────────────────────────────────────────────────────────
  static HHTokens of(BuildContext context) {
    return Theme.of(context).extension<HHTokens>()!;
  }

  @override
  HHTokens copyWith({
    Color? bgBase,
    Color? bgElevated,
    Color? bgElevated2,
    Color? separator,
    Color? fill,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? accentPressed,
    bool? isDark,
  }) => HHTokens(
    bgBase: bgBase ?? this.bgBase,
    bgElevated: bgElevated ?? this.bgElevated,
    bgElevated2: bgElevated2 ?? this.bgElevated2,
    separator: separator ?? this.separator,
    fill: fill ?? this.fill,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    accent: accent ?? this.accent,
    accentPressed: accentPressed ?? this.accentPressed,
    isDark: isDark ?? this.isDark,
  );

  @override
  HHTokens lerp(HHTokens? other, double t) {
    if (other == null) return this;
    return HHTokens(
      bgBase: Color.lerp(bgBase, other.bgBase, t)!,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t)!,
      bgElevated2: Color.lerp(bgElevated2, other.bgElevated2, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentPressed: Color.lerp(accentPressed, other.accentPressed, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

// ── Pre-built HHTokens for injection into ThemeData.extensions ───────────────

const _darkTokens = HHTokens(
  bgBase: HHColors.darkBgBase,
  bgElevated: HHColors.darkBgElevated,
  bgElevated2: HHColors.darkBgElevated2,
  separator: HHColors.darkSeparator,
  fill: HHColors.darkFill,
  textPrimary: HHColors.darkTextPrimary,
  textSecondary: HHColors.darkTextSecondary,
  textTertiary: HHColors.darkTextTertiary,
  accent: HHColors.darkAccent,
  accentPressed: HHColors.darkAccentPressed,
  isDark: true,
);

const _lightTokens = HHTokens(
  bgBase: HHColors.lightBgBase,
  bgElevated: HHColors.lightBgElevated,
  bgElevated2: HHColors.lightBgElevated2,
  separator: HHColors.lightSeparator,
  fill: HHColors.lightFill,
  textPrimary: HHColors.lightTextPrimary,
  textSecondary: HHColors.lightTextSecondary,
  textTertiary: HHColors.lightTextTertiary,
  accent: HHColors.lightAccent,
  accentPressed: HHColors.lightAccentPressed,
  isDark: false,
);

/// Attach extensions after building the theme.
extension HHThemeExtensions on ThemeData {
  ThemeData withHHExtension() {
    final tokens = brightness == Brightness.dark ? _darkTokens : _lightTokens;
    return copyWith(extensions: [...(extensions.values), tokens]);
  }
}
