import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_devocional_mobile/src/theme/app_palette.dart';
import 'package:app_devocional_mobile/src/theme/app_theme.dart';

// Só a paleta é testada aqui: montar AppTheme dispara o Google Fonts, que
// tenta carregar fontes pela rede e quebra o teste em ambiente sem internet.

void main() {
  test('paleta clara usa os mesmos valores de AppColors', () {
    const p = AppPalette.light;
    expect(p.bg, AppColors.ivory);
    expect(p.surface, AppColors.surface);
    expect(p.surfaceSoft, AppColors.parchment);
    expect(p.border, AppColors.sand);
    expect(p.borderStrong, AppColors.sandDeep);
    expect(p.ink, AppColors.ink);
    expect(p.muted, AppColors.muted);
    expect(p.primary, AppColors.blue);
    expect(p.primaryDeep, AppColors.blueDeep);
    expect(p.primarySoft, AppColors.blueSoft);
    expect(p.gold, AppColors.gold);
    expect(p.goldSoft, AppColors.goldSoft);
    expect(p.goldLight, AppColors.goldLight);
    expect(p.wine, AppColors.wine);
    expect(p.wineSoft, AppColors.wineSoft);
    expect(p.success, AppColors.green);
  });

  test('lerp entre claro e escuro devolve extremos e meio-termo', () {
    expect(AppPalette.light.lerp(AppPalette.dark, 0).bg, AppPalette.light.bg);
    expect(AppPalette.light.lerp(AppPalette.dark, 1).bg, AppPalette.dark.bg);
    final mid = AppPalette.light.lerp(AppPalette.dark, 0.5).bg;
    expect(mid, isNot(AppPalette.light.bg));
    expect(mid, isNot(AppPalette.dark.bg));
  });

  test('copyWith altera só o token pedido', () {
    final p = AppPalette.light.copyWith(ink: const Color(0xFF000000));
    expect(p.ink, const Color(0xFF000000));
    expect(p.primary, AppPalette.light.primary);
  });
}
