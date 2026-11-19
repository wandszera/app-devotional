# Plano do modo escuro (migração de cores) — preparado em 19/11/2026

## Por que ainda não foi aplicado
O ambiente da rotina não tem Flutter/Dart (nem `dart analyze`). Migrar ~180 usos de cor em 32 arquivos às cegas arrisca quebrar o build. Este plano deixa a migração mecânica e verificável; executar localmente com `verificar_mobile.bat` ao final de cada lote.

## Inventário (usos de `Colors.white/black`, `Color(0x..)`, `AppColors.*`)
- Lote 1 (tema): `app_theme.dart` (72).
- Lote 2 (Hoje): habit_coach_card 21, habit_status_card 15, hero_card 7, retention_primitives 9, daily_mission_card 3, milestone_banner 4, completion_feedback_dialog 12, metric_card 3.
- Lote 3 (Leitor/Orações/Calendário): devotional_reader_page 12, gospel_reader_page 5, prayer_detail_page 3, prayers_tab 2, liturgical_calendar_tab 5.
- Lote 4 (Progresso/Ajustes/Perfil): progress_insight_card 6, progress_calendar_card 6, progress_badges_widget 4, progress_history_list_item 2, settings_account_card 7, settings_reminder_form 1, push_sdk_info_card 4, profile_page 1, home_form_widgets 1, home_state_widgets 4, home_feedback 2, weekday_label 1.
- Lote 5 (entrada/admin): onboarding_page 9, notification_prompt_page 13, login_page 6, cross_ornament 2, admin_* (3 arquivos, 5).
- Literais mais frequentes a mapear: `0xFF3E6B52` (30, primário), `0xFF5E584E` (18, muted), `0xFF1F3A2C` (16, primário escuro), `0xFFF4EEE2` (15, parchment), `0xFF26211C` (8, ink), `0xFFF9F1DF` (6, creme dourado), `0xFFE6DCC8` (6, sand), `0xFF7A2E3A` (6, vinho). Verdes de sucesso avulsos (`EAF3EC`, `E9F7ED`, `E8F7EC`, `E7F6EA`, `EAF6EC`, `D6EEDB`…) → um único token `successSoft`. `EAF4FF` (azul claro) destoa do verde: trocar por `primarySoft`.

## Estratégia
1. Criar `AppPalette extends ThemeExtension<AppPalette>` com tokens semânticos: `bg, surface, surfaceSoft, border, borderStrong, ink, muted, primary, primaryDeep, primarySoft, onPrimary, gold, goldSoft, goldLight, wine, wineSoft, success, successSoft`. Fábricas `AppPalette.light` (valores atuais de `AppColors`) e `AppPalette.dark`.
2. Extensão `extension PaletteX on BuildContext { AppPalette get palette => Theme.of(this).extension<AppPalette>()!; }`.
3. Migrar tela a tela: `AppColors.x` / literal → `context.palette.x`. Onde havia `const`, remover o `const` do widget pai (o analyzer aponta).
4. Só depois: `AppTheme.dark()` + `themeMode: ThemeMode.system` em `app.dart` (+ opção Claro/Escuro/Sistema em Ajustes).
5. Manter `AppColors` apenas dentro de `app_theme.dart` (fonte dos valores claros).

## Paleta escura proposta (verde-semente noturno)
| token | claro | escuro |
|---|---|---|
| bg | FAF6EE | 141A16 |
| surface | FFFDF8 | 1C241F |
| surfaceSoft | F4EEE2 | 242E28 |
| border | E6DCC8 | 33403A |
| borderStrong | D8C9A8 | 44544B |
| ink | 26211C | EDE8DC |
| muted | 5E584E | A9B0A5 |
| primary | 3E6B52 | 7FB08F |
| primaryDeep (títulos) | 1F3A2C | CFE6D5 |
| primarySoft | E3EEE5 | 27382E |
| onPrimary | FFFFFF | 10231A |
| gold | B8893B | D9AE5F |
| goldSoft | F6EBD0 | 3A3120 |
| wine | 7A2E3A | E08A96 |
| wineSoft | F6E3E4 | 3C2529 |
| successSoft | EAF3EC | 22372A |
Conferir contraste (>= 4.5:1 para texto) antes de fechar; o hero card (gradiente verde + texto dourado) precisa de revisão visual nos dois temas.

## Verificação por lote
`dart analyze lib` + `flutter test` (`verificar_mobile.bat`), depois olhar Hoje, Leitor, Calendário, Orações, Progresso, Ajustes em claro e escuro. Commitar um lote por vez (`feat/ui-dark-mode`).

## Ordem recomendada (menor risco primeiro)
Lote 1+AppPalette → Lote 4 → Lote 2 → Lote 3 → Lote 5 → `dark()`+themeMode → Ajustes.
