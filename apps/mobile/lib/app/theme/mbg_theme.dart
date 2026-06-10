import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MBGColors {
  MBGColors._();

  static const primary = Color(0xFF2A9D5C);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFD8F3E3);
  static const onPrimaryContainer = Color(0xFF0F3A21);

  static const primaryLight = Color(0xFF4BB87E);
  static const primaryDark = Color(0xFF196339);

  static const secondary = Color(0xFFF59E0B);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFEF3C7);
  static const onSecondaryContainer = Color(0xFF451A03);

  static const tertiary = Color(0xFF3B82F6);
  static const tertiaryContainer = Color(0xFFDBEAFE);

  static const surface = Color(0xFFFAFAF8);
  static const onSurface = Color(0xFF1C1B1A);
  static const surfaceVariant = Color(0xFFF0EFEA);
  static const onSurfaceVariant = Color(0xFF494842);

  static const outline = Color(0xFFC4C2BB);
  static const outlineVariant = Color(0xFFE0DFD8);

  static const error = Color(0xFFDC362E);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFCE4E4);

  static const neutral50 = Color(0xFFFAFAF8);
  static const neutral100 = Color(0xFFF5F4F0);
  static const neutral200 = Color(0xFFE9E7E0);
  static const neutral300 = Color(0xFFD4D1C7);
  static const neutral400 = Color(0xFFB5B2A5);
  static const neutral500 = Color(0xFF8F8C82);
  static const neutral600 = Color(0xFF6B6860);
  static const neutral700 = Color(0xFF524F48);
  static const neutral800 = Color(0xFF3D3B35);
  static const neutral900 = Color(0xFF27251F);

  static const danger = Color(0xFFDC2626);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF2A9D5C);
}

final mbgLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: MBGColors.primary,
    onPrimary: MBGColors.onPrimary,
    primaryContainer: MBGColors.primaryContainer,
    onPrimaryContainer: MBGColors.onPrimaryContainer,
    secondary: MBGColors.secondary,
    onSecondary: MBGColors.onSecondary,
    secondaryContainer: MBGColors.secondaryContainer,
    onSecondaryContainer: MBGColors.onSecondaryContainer,
    tertiary: MBGColors.tertiary,
    tertiaryContainer: MBGColors.tertiaryContainer,
    surface: MBGColors.surface,
    onSurface: MBGColors.onSurface,
    surfaceContainerHighest: MBGColors.surfaceVariant,
    onSurfaceVariant: MBGColors.onSurfaceVariant,
    outline: MBGColors.outline,
    outlineVariant: MBGColors.outlineVariant,
    error: MBGColors.error,
    onError: MBGColors.onError,
    errorContainer: MBGColors.errorContainer,
  ),
  scaffoldBackgroundColor: MBGColors.surface,
  textTheme: GoogleFonts.plusJakartaSansTextTheme(
    ThemeData.light().textTheme,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: MBGColors.surface,
    foregroundColor: MBGColors.onSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: false,
    titleTextStyle: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: MBGColors.onSurface,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: MBGColors.outlineVariant),
    ),
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: MBGColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: MBGColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: MBGColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: MBGColors.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: TextStyle(color: MBGColors.neutral500.withValues(alpha: 0.7)),
    labelStyle: const TextStyle(color: MBGColors.neutral500),
    floatingLabelStyle: const TextStyle(color: MBGColors.primary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: MBGColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      elevation: 0,
      shadowColor: MBGColors.primary.withValues(alpha: 0.3),
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: MBGColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      side: const BorderSide(color: MBGColors.outline),
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: MBGColors.outlineVariant,
    thickness: 0.5,
    space: 0,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    contentTextStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
  ),
  navigationBarTheme: NavigationBarThemeData(
    elevation: 2,
    indicatorColor: MBGColors.primaryContainer,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: MBGColors.primary,
        );
      }
      return GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: MBGColors.neutral500,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(size: 22, color: MBGColors.primary);
      }
      return const IconThemeData(size: 22, color: MBGColors.neutral500);
    }),
  ),
  chipTheme: ChipThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    side: const BorderSide(color: MBGColors.outlineVariant),
    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
    backgroundColor: Colors.white,
    selectedColor: MBGColors.primaryContainer,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),
  segmentedButtonTheme: SegmentedButtonThemeData(
    style: SegmentedButton.styleFrom(
      backgroundColor: Colors.white,
      selectedBackgroundColor: MBGColors.primaryContainer,
      selectedForegroundColor: MBGColors.onPrimaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return MBGColors.primary;
      return MBGColors.neutral400;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return MBGColors.primary.withValues(alpha: 0.3);
      }
      return MBGColors.neutral200;
    }),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: MBGColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
  ),
);

final mbgDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: MBGColors.primaryLight,
    onPrimary: Color(0xFF003316),
    primaryContainer: Color(0xFF1E7D47),
    onPrimaryContainer: Color(0xFFD8F3E3),
    secondary: MBGColors.secondary,
    onSecondary: Color(0xFF331D00),
    secondaryContainer: Color(0xFF4A2A00),
    onSecondaryContainer: Color(0xFFFDE68A),
    tertiary: Color(0xFF93C5FD),
    tertiaryContainer: Color(0xFF1E3A5F),
    surface: Color(0xFF141312),
    onSurface: Color(0xFFE4E2DD),
    surfaceContainerHighest: Color(0xFF2B2926),
    onSurfaceVariant: Color(0xFFC4C2BB),
    outline: Color(0xFF6B6860),
    outlineVariant: Color(0xFF3D3B35),
    error: Color(0xFFFF8A80),
    onError: Color(0xFF601410),
    errorContainer: Color(0xFF8C1D18),
  ),
  scaffoldBackgroundColor: const Color(0xFF141312),
  textTheme: GoogleFonts.plusJakartaSansTextTheme(
    ThemeData.dark().textTheme,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF141312),
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: false,
    titleTextStyle: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: MBGColors.neutral200.withValues(alpha: 0.12)),
    ),
    color: const Color(0xFF1E1D1B),
    surfaceTintColor: Colors.transparent,
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2B2926),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: MBGColors.neutral200.withValues(alpha: 0.12)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: MBGColors.neutral200.withValues(alpha: 0.12)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: MBGColors.primaryLight, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: TextStyle(color: MBGColors.neutral500.withValues(alpha: 0.7)),
    labelStyle: const TextStyle(color: MBGColors.neutral500),
    floatingLabelStyle: const TextStyle(color: MBGColors.primaryLight),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: MBGColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      elevation: 0,
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: MBGColors.primaryLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      side: BorderSide(color: MBGColors.neutral200.withValues(alpha: 0.2)),
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: MBGColors.neutral200.withValues(alpha: 0.12),
    thickness: 0.5,
    space: 0,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    contentTextStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
  ),
  navigationBarTheme: NavigationBarThemeData(
    elevation: 2,
    indicatorColor: MBGColors.primary.withValues(alpha: 0.2),
    backgroundColor: const Color(0xFF1E1D1B),
    surfaceTintColor: Colors.transparent,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: MBGColors.primaryLight,
        );
      }
      return GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: MBGColors.neutral500,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(size: 22, color: MBGColors.primaryLight);
      }
      return const IconThemeData(size: 22, color: MBGColors.neutral500);
    }),
  ),
  chipTheme: ChipThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    side: BorderSide(color: MBGColors.neutral200.withValues(alpha: 0.12)),
    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
    backgroundColor: const Color(0xFF2B2926),
    selectedColor: MBGColors.primary.withValues(alpha: 0.2),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return MBGColors.primaryLight;
      return MBGColors.neutral500;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return MBGColors.primaryLight.withValues(alpha: 0.3);
      }
      return MBGColors.neutral700;
    }),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: const Color(0xFF141312),
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
  ),
);
