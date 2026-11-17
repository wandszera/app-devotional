import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta inspirada na tradição visual católica: azul mariano, ouro litúrgico,
/// vinho (vermelho dos mártires) sobre marfim de pergaminho.
abstract final class AppColors {
  static const ivory = Color(0xFFFAF6EE); // fundo
  static const surface = Color(0xFFFFFDF8); // cartões
  static const sand = Color(0xFFE6DCC8); // bordas e divisores
  static const sandDeep = Color(0xFFD8C9A8);
  static const parchment = Color(0xFFF4EEE2); // superfícies suaves

  static const blue = Color(0xFF2B4C7E); // azul mariano
  static const blueDeep = Color(0xFF1A2F52);
  static const blueSoft = Color(0xFFE4ECF7);

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

    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.ivory,
    );

    final body = GoogleFonts.interTextTheme(base.textTheme);
    final textTheme = body.copyWith(
      displaySmall: GoogleFonts.cormorantGaramond(
        textStyle: body.displaySmall,
        fontWeight: FontWeight.w700,
        color: AppColors.blueDeep,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        textStyle: body.headlineMedium,
        fontWeight: FontWeight.w700,
        color: AppColors.blueDeep,
      ),
      headlineSmall: GoogleFonts.cormorantGaramond(
        textStyle: body.headlineSmall,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.15,
        color: AppColors.blueDeep,
      ),
      titleLarge: GoogleFonts.cormorantGaramond(
        textStyle: body.titleLarge,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.blueDeep,
      ),
      titleMedium: GoogleFonts.cormorantGaramond(
        textStyle: body.titleMedium,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.blueDeep,
      ),
      // Texto de leitura (evangelho, devocional, orações) em serifa.
      bodyLarge: GoogleFonts.lora(
        textStyle: body.bodyLarge,
        fontSize: 17,
        height: 1.6,
        color: AppColors.ink,
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
        foregroundColor: AppColors.blueDeep,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: AppColors.blueDeep,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.sand),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.sand,
        thickness: 1,
        space: 24,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.blueSoft,
        indicatorShape: const StadiumBorder(),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.blue : AppColors.muted,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.blue : AppColors.muted,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue,
          minimumSize: const Size(64, 52),
          side: const BorderSide(color: AppColors.sandDeep),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.blue),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.sandDeep),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.sand),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.parchment,
        selectedColor: AppColors.blueSoft,
        side: const BorderSide(color: AppColors.sand),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.blueDeep,
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.blue
              : AppColors.sandDeep,
        ),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
      ),
    );
  }
}
