import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

/// Paleta inspirada na tradição visual católica: verde-semente, ouro litúrgico,
/// vinho (vermelho dos mártires) sobre marfim de pergaminho.
abstract final class AppColors {
  static const ivory = Color(0xFFFAF6EE); // fundo
  static const surface = Color(0xFFFFFDF8); // cartões
  static const sand = Color(0xFFE6DCC8); // bordas e divisores
  static const sandDeep = Color(0xFFD8C9A8);
  static const parchment = Color(0xFFF4EEE2); // superfícies suaves

  static const blue = Color(0xFF3E6B52); // verde-semente
  static const blueDeep = Color(0xFF1F3A2C);
  static const blueSoft = Color(0xFFE3EEE5);

  static const gold = Color(0xFFB8893B); // ouro litúrgico
  static const goldLight = Color(0xFFE7D3A3);
  static const goldSoft = Color(0xFFF6EBD0);

  static const wine = Color(0xFF7A2E3A); // vermelho litúrgico
  static const wineSoft = Color(0xFFF6E3E4);

  static const green = Color(0xFF2F6B4A); // tempo comum / sucesso
  static const ink = Color(0xFF26211C);
  static const muted = Color(0xFF5E584E);
}

abstract final class AppTheme {
  /// Tema claro, em uso pelo app.
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.blue,
      onPrimary: Colors.white,
      primaryContainer: AppColors.blueSoft,
      onPrimaryContainer: AppColors.blueDeep,
      secondary: AppColors.gold,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.goldSoft,
      onSecondaryContainer: Color(0xFF5A3F12),
      tertiary: AppColors.wine,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.wineSoft,
      onTertiaryContainer: AppColors.wine,
      error: Color(0xFF9C3040),
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.muted,
      outline: AppColors.sandDeep,
      outlineVariant: AppColors.sand,
      surfaceContainerHighest: AppColors.parchment,
    );

    return _build(scheme, AppPalette.light);
  }

  /// Tema escuro: definido, mas ainda não usado (`themeMode` continua claro).
  /// Ativar só depois de aprovar a paleta escura e conferir o contraste.
  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF7FB08F),
      onPrimary: Color(0xFF10231A),
      primaryContainer: Color(0xFF27382E),
      onPrimaryContainer: Color(0xFFCFE6D5),
      secondary: Color(0xFFD9AE5F),
      onSecondary: Color(0xFF2A2110),
      secondaryContainer: Color(0xFF3A3120),
      onSecondaryContainer: Color(0xFFF6EBD0),
      tertiary: Color(0xFFE08A96),
      onTertiary: Color(0xFF3A1A20),
      tertiaryContainer: Color(0xFF3C2529),
      onTertiaryContainer: Color(0xFFE08A96),
      error: Color(0xFFF2B8BF),
      onError: Color(0xFF3A0F15),
      surface: Color(0xFF1C241F),
      onSurface: Color(0xFFEDE8DC),
      onSurfaceVariant: Color(0xFFA9B0A5),
      outline: Color(0xFF44544B),
      outlineVariant: Color(0xFF33403A),
      surfaceContainerHighest: Color(0xFF242E28),
    );

    return _build(scheme, AppPalette.dark);
  }

  static ThemeData _build(ColorScheme scheme, AppPalette p) {
    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: p.bg,
      extensions: [p],
    );

    final body = GoogleFonts.interTextTheme(base.textTheme);
    final textTheme = body.copyWith(
      displaySmall: GoogleFonts.cormorantGaramond(
        textStyle: body.displaySmall,
        fontWeight: FontWeight.w700,
        color: p.primaryDeep,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        textStyle: body.headlineMedium,
        fontWeight: FontWeight.w700,
        color: p.primaryDeep,
      ),
      headlineSmall: GoogleFonts.cormorantGaramond(
        textStyle: body.headlineSmall,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.15,
        color: p.primaryDeep,
      ),
      titleLarge: GoogleFonts.cormorantGaramond(
        textStyle: body.titleLarge,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: p.primaryDeep,
      ),
      titleMedium: GoogleFonts.cormorantGaramond(
        textStyle: body.titleMedium,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: p.primaryDeep,
      ),
      // Texto de leitura (evangelho, devocional, orações) em serifa.
      bodyLarge: GoogleFonts.lora(
        textStyle: body.bodyLarge,
        fontSize: 17,
        height: 1.6,
        color: p.ink,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: p.primaryDeep,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: p.primaryDeep,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: p.border.withValues(alpha: 0.8)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(
        color: p.border,
        thickness: 1,
        space: 24,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: p.primarySoft,
        indicatorShape: const StadiumBorder(),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? p.primary : p.muted,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? p.primary : p.muted,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          minimumSize: const Size(64, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          minimumSize: const Size(64, 52),
          side: BorderSide(color: p.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.primary, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceSoft,
        selectedColor: p.primarySoft,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: p.ink),
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.primaryDeep,
        contentTextStyle: GoogleFonts.inter(color: p.onPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.primary : p.borderStrong,
        ),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
      ),
    );
  }
}
