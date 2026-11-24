import 'package:flutter/material.dart';

/// Tokens semânticos de cor usados pelas telas (ver docs/plano-modo-escuro.md).
///
/// A versão clara usa exatamente os valores de `AppColors`. A versão escura
/// ainda é uma proposta (verde-semente noturno) e só é aplicada quando
/// `AppTheme.dark()` for usado; por enquanto o app continua no tema claro.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.bg,
    required this.surface,
    required this.surfaceSoft,
    required this.border,
    required this.borderStrong,
    required this.ink,
    required this.muted,
    required this.primary,
    required this.primaryDeep,
    required this.primarySoft,
    required this.onPrimary,
    required this.gold,
    required this.goldSoft,
    required this.goldLight,
    required this.wine,
    required this.wineSoft,
    required this.success,
    required this.successSoft,
  });

  final Color bg;
  final Color surface;
  final Color surfaceSoft;
  final Color border;
  final Color borderStrong;
  final Color ink;
  final Color muted;
  final Color primary;
  final Color primaryDeep;
  final Color primarySoft;
  final Color onPrimary;
  final Color gold;
  final Color goldSoft;
  final Color goldLight;
  final Color wine;
  final Color wineSoft;
  final Color success;
  final Color successSoft;

  /// Valores claros: mesmos de `AppColors`.
  static const light = AppPalette(
    bg: Color(0xFFFAF6EE),
    surface: Color(0xFFFFFDF8),
    surfaceSoft: Color(0xFFF4EEE2),
    border: Color(0xFFE6DCC8),
    borderStrong: Color(0xFFD8C9A8),
    ink: Color(0xFF26211C),
    muted: Color(0xFF5E584E),
    primary: Color(0xFF3E6B52),
    primaryDeep: Color(0xFF1F3A2C),
    primarySoft: Color(0xFFE3EEE5),
    onPrimary: Color(0xFFFFFFFF),
    gold: Color(0xFFB8893B),
    goldSoft: Color(0xFFF6EBD0),
    goldLight: Color(0xFFE7D3A3),
    wine: Color(0xFF7A2E3A),
    wineSoft: Color(0xFFF6E3E4),
    success: Color(0xFF2F6B4A),
    successSoft: Color(0xFFEAF3EC),
  );

  /// Proposta escura (verde-semente noturno). Ainda não aprovada pelo Wanderson.
  /// Tokens `goldLight`, `success` e `successSoft` foram escolhidos aqui por
  /// analogia; conferir contraste antes de ativar.
  static const dark = AppPalette(
    bg: Color(0xFF141A16),
    surface: Color(0xFF1C241F),
    surfaceSoft: Color(0xFF242E28),
    border: Color(0xFF33403A),
    borderStrong: Color(0xFF44544B),
    ink: Color(0xFFEDE8DC),
    muted: Color(0xFFA9B0A5),
    primary: Color(0xFF7FB08F),
    primaryDeep: Color(0xFFCFE6D5),
    primarySoft: Color(0xFF27382E),
    onPrimary: Color(0xFF10231A),
    gold: Color(0xFFD9AE5F),
    goldSoft: Color(0xFF3A3120),
    goldLight: Color(0xFF6B5530),
    wine: Color(0xFFE08A96),
    wineSoft: Color(0xFF3C2529),
    success: Color(0xFF8CC9A3),
    successSoft: Color(0xFF22372A),
  );

  @override
  AppPalette copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceSoft,
    Color? border,
    Color? borderStrong,
    Color? ink,
    Color? muted,
    Color? primary,
    Color? primaryDeep,
    Color? primarySoft,
    Color? onPrimary,
    Color? gold,
    Color? goldSoft,
    Color? goldLight,
    Color? wine,
    Color? wineSoft,
    Color? success,
    Color? successSoft,
  }) {
    return AppPalette(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      primary: primary ?? this.primary,
      primaryDeep: primaryDeep ?? this.primaryDeep,
      primarySoft: primarySoft ?? this.primarySoft,
      onPrimary: onPrimary ?? this.onPrimary,
      gold: gold ?? this.gold,
      goldSoft: goldSoft ?? this.goldSoft,
      goldLight: goldLight ?? this.goldLight,
      wine: wine ?? this.wine,
      wineSoft: wineSoft ?? this.wineSoft,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDeep: Color.lerp(primaryDeep, other.primaryDeep, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldSoft: Color.lerp(goldSoft, other.goldSoft, t)!,
      goldLight: Color.lerp(goldLight, other.goldLight, t)!,
      wine: Color.lerp(wine, other.wine, t)!,
      wineSoft: Color.lerp(wineSoft, other.wineSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
    );
  }
}

extension PaletteX on BuildContext {
  /// Paleta do tema atual. Exige que o tema tenha `AppPalette` (ver `AppTheme`).
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
