# Rotina automática — Semente (app_devocional)

Controle da tarefa agendada que roda de hora em hora: cada execução faz **uma** etapa da fila,
marca como concluída e deixa a próxima preparada. Branch de trabalho: `rotina/semente`.

## Estado
- Em andamento: C01-L4 — Reflexões do Advento, lote 4 (22/12–28/12), iniciada 2026-11-24 19:51 UTC
- Última execução: 2026-11-24 (UTC) — C01-L3 concluída: `docs/reflexoes-rascunho-advento-lote3.md` com 7 rascunhos (15/12 a 21/12), mesmo formato do lote 2. Só `.md`; nenhum código, CSV ou catálogo mudou. Referências copiadas do CSV (`ref_cnbb_ok`), mas a releitura na Liturgia Diária CNBB falhou nesta rodada (acesso ao site bloqueado por pedido de permissão sem resposta), então ficou pendente.
- Testes: não rodados nesta etapa (sem mudança de código). Última validação de código: T04d (`flutter analyze` sem issues; `flutter test` 71 passou). Backend não tocado.

## Próxima etapa preparada
**C01-L4 — Reflexões do Advento, lote 4 (22/12–28/12):** escrever 7 rascunhos no mesmo formato do lote 3, em `docs/reflexoes-rascunho-advento-lote4.md`. Antes de escrever, copiar as referências das linhas 22/12 a 28/12 de `docs/calendario-editorial-2026-12-a-2027-03.csv` e tentar reconferi-las na Liturgia Diária das Edições CNBB (liturgiadiaria.edicoescnbb.com.br); se o site continuar inacessível, registrar a pendência, sem inventar referência. Só referência bíblica, nunca o texto (D05). Cada texto termina com pergunta e passo prático. CSV, catálogo e código não mudam. Um commit e push para o lote.
Para o Wanderson: (a) revisar o lote 3 (sensibilidade teológica de Mt 21 e Lc 1; tamanho; viabilidade do passo prático); (b) decidir se 20/12 (Lc 1,26-38, mesmo trecho do 08/12) e 21/12 (Lc 1,39-45, parecido com o 12/12) ficam como estão ou se trocamos o foco; (c) conferir as referências de 15/12 a 21/12 na CNBB, já que nesta rodada o site não pôde ser aberto; (d) D04 (revisor) continua pendente antes de colar qualquer reflexão no CSV.

## Regras rápidas
- Uma etapa por execução. Etapa "em andamento" há menos de 50 min = outra execução trabalhando: não fazer nada.
- Nunca decidir D01–D08 pelo Wanderson; etapa bloqueada por decisão vai para "Bloqueadas" e a rotina pega a próxima livre.
- Texto bíblico: só referência (D05). Reflexões são rascunho para revisão humana; não entram no CSV sem aprovação.
- `pytest` e `flutter analyze` + `flutter test` (mobile/) passando antes de cada commit.

## Fila (em ordem)
1. **C01-L5..L6 — Reflexões, lotes 5 e 6** (29/12 a 10/01), um lote por etapa.
2. **S01 — Assinatura do AAB:** aplicar no gradle a leitura de `key.properties` (sem segredo no repo), seguindo `docs/roteiro-assinatura-aab.md`.

## Bloqueadas (esperando decisão do Wanderson)
- A02 applicationId e novo app Firebase — D01 (nome final) e D06 (domínio).
- gen_site real (privacidade/exclusão de conta) — D06.
- Reflexões no CSV — D04 (revisor) e revisão do lote 1.
- Texto bíblico completo — D05.

## Histórico
- **C01-L3 — Reflexões do Advento, lote 3 (15/12–21/12)** — concluída 2026-11-24 (UTC).
  - Arquivos: `docs/reflexoes-rascunho-advento-lote3.md` (novo; 7 textos: 15/12 Mt 21,28-32; 16/12 Lc 7,19-23; 17/12 Mt 1,1-17; 18/12 Mt 1,18-24; 19/12 Lc 1,5-25; 20/12 Lc 1,26-38; 21/12 Lc 1,39-45). Mesmo formato do lote 2; sem texto bíblico; cada texto termina com pergunta e passo prático. CSV, catálogo e código não mudaram.
  - Testes: não rodados (só `.md` novo).
  - Pendências: conferir as 7 referências na Liturgia Diária CNBB (não foi possível abrir o site nesta rodada); revisão humana (D04); decidir sobre a repetição de trechos com o lote 2 (20/12 e 21/12).
- **T04d — Modo escuro, lote 5 (entrada/admin)** — concluída 2026-11-24 (UTC), commit `b89c6c5`.
  - Arquivos (4): `onboarding_page.dart` e `login_page.dart` (`AppColors.ivory` do gradiente → `context.palette.bg`; import de `app_theme.dart` removido, sem uso restante); `widgets/cross_ornament.dart` (`CrossMark.color` agora opcional, padrão `context.palette.gold`; `OrnamentDivider` usa `context.palette.goldLight`); `admin_due_notification_list_item.dart` (ícone → `palette.primary`, texto → `palette.muted`; `const` removido só nesses dois pontos).
  - Visual: os valores trocados são exatamente os de `AppPalette.light`, então o tema claro não muda.
  - Não migrado de propósito (decisão pendente, item (i) acima): `Colors.white` de cartões do admin e de `notification_prompt_page`; `Colors.red`/`Colors.green` do status do admin e de `login_page`/`notification_prompt_page`; `Colors.white` de `login_page` (168); `F9F1DF` de `notification_prompt_page` (160).
  - Testes: `flutter analyze` sem issues (Flutter 3.41.9, mesmo do CI; antes havia 2 `unused_import` e 2 `prefer_const_constructors`, corrigidos); `flutter test` 71 passou. Backend não tocado; pytest não rodado.
  - Pendências: captura visual de login, onboarding e admin em claro e escuro (não feita).
- **T04c — Modo escuro, lote 3 (Leitor/Orações/Calendário)** — concluída 2026-11-24 (UTC), sem mudança de código.
  - Auditoria: `devotional_reader_page`, `gospel_reader_page`, `prayer_detail_page`, `prayers_tab` e `liturgical_calendar_tab` já usam `Theme.of(context).colorScheme` desde a T02, e `AppTheme.dark()` já define esses roles. Não há `AppColors.x` nem literal com token exato em `AppPalette` nesses arquivos.
  - Literais que sobraram e não foram tocados (sem token exato; trocar mudaria o tema claro ou exige decisão): `devotional_reader_page` `F9F1DF` (linha 44), `Colors.white` nos cartões (262) e no botão flutuante (215), `Colors.black87`/`black` nos ícones; `gospel_reader_page`, `prayer_detail_page`, `prayers_tab` e `liturgical_calendar_tab` com `Colors.redAccent` nos favoritos; `liturgical_calendar_tab` `Colors.white` no dia com Evangelho (225). Entram na lista de decisões da T04d.
  - Testes: não rodados nesta etapa, porque nenhum arquivo de código mudou. Última validação: T04b (`flutter analyze` sem issues; `flutter test` 71 passou).
  - Pendências: captura visual do Leitor e do Calendário em claro e escuro (não feita); decisão sobre `Colors.white` de cartões e favoritos.
- **T04b — Modo escuro, lote 2 (Hoje)** — concluída 2026-11-24 (UTC).
  - Arquivos (4): `hero_card.dart` (`AppColors.gold`/`goldLight` → `context.palette.gold`/`goldLight`; import de `app_theme` trocado por `app_palette`; `const TextStyle` virou `TextStyle`); `habit_coach_card.dart` e `habit_status_card.dart` (`_paletteForTone` recebe `AppPalette`; `0xFFF6EBD0` → `goldSoft`, `0xFFEAF3EC` → `successSoft`); `completion_feedback_dialog.dart` (`_palette` recebe `AppPalette`; `0xFFEAF3EC` → `successSoft`).
  - Não migrado (sem token em `AppPalette`; trocar por um valor aproximado mudaria o tema claro): `retention_primitives` (`EAF4FF`, `F9F1DF`, `E8F7EC`, `2D6C45`), `milestone_banner` (`F9F1DF`), `daily_mission_card` (`E9F7ED`, `Colors.green`), `habit_coach_card` (`E7F6EA`, `D6EEDB`, `2E6B45`, `254C36`, `E6F0E8`, `D3E4D8`), `habit_status_card` (`EAF6EC`, `2E6B45`, `355640`, `F9F1DF`), `completion_feedback_dialog` (`F9F1DF`). `metric_card` já usava só `ColorScheme`: sem mudança.
  - Visual: claro idêntico (os valores trocados são exatamente os de `AppPalette.light`). Captura visual não feita.
  - Testes: `flutter analyze` sem issues; `flutter test` 71 passou (Flutter 3.41.9). Backend não tocado; pytest não rodado.
  - Pendências: decidir tokens para os pastéis não migrados (ver "Para o Wanderson" acima); a etapa original previa migrar os 8 arquivos inteiros, mas só os valores com token exato foram trocados, para não alterar o tema claro.
- **T04a — Modo escuro, lote 4 (Progresso/Ajustes/Perfil)** — concluída 2026-11-24 (UTC). A T04 original foi dividida em T04a (lote 4, feito), T04b, T04c e T04d.
  - Arquivos: `progress_insight_card.dart` (`Colors.white` 0.84 → `palette.surface` 0.84), `progress_calendar_card.dart` (dia concluído → `palette.onPrimary`), `progress_badges_widget.dart` (selo bloqueado: `grey.shade200/400/500` → `surfaceSoft`/`borderStrong`/`muted`; branco → `onPrimary`; sombra preta mantida), `progress_history_list_item.dart` (`tileColor` → `palette.surface`), `settings_account_card.dart` (inicial do avatar → `onPrimary`; bio `black 0.6` → `muted`), `profile_page.dart` (spinner do botão → `onPrimary`), `mobile/lib/src/theme/app_palette.dart` (`context.palette` agora cai para `AppPalette.light` quando o tema não tem a extensão; antes lançava null-check e quebrava 3 testes de `app_shell_test.dart` que montam `ThemeData` cru).
  - Visual: claro quase idêntico. Diferenças pequenas: cinzas dos selos bloqueados ficam quentes e mais escuros; bio do perfil e pílula do insight usam tons da paleta.
  - Mantidos de propósito (sem token ainda): vermelhos de logout e erro (`redAccent`, `red.shade700`, `Colors.red`), verde do snackbar `4D7C4A` (`home_feedback`), default `Colors.white` de `home_form_widgets`. Ficam para a T04d.
  - Testes: `flutter analyze` sem issues; `flutter test` 71 passou (Flutter 3.41.9, mesmo do CI). Backend não tocado; pytest não rodado nesta etapa.
  - Pendências: captura visual não feita (Progresso e Ajustes em claro e escuro); não foi adicionado teste específico para o fallback de `context.palette`.
- **T03 — Modo escuro, parte 1 (AppPalette, sem ativar)** — concluída 2026-11-24 (2026-11-24 UTC).
  - Arquivos: `mobile/lib/src/theme/app_palette.dart` (novo: `AppPalette extends ThemeExtension` com os 18 tokens do plano, fábricas `light` (valores de `AppColors`) e `dark` (proposta da tabela), `copyWith`, `lerp`, e `context.palette`); `mobile/lib/src/theme/app_theme.dart` (`light()` e `dark()` agora usam um `_build` comum que lê a paleta; `AppPalette` entra em `extensions`; `AppColors` continua ali); `mobile/test/app_theme_test.dart` (novo, 3 testes da paleta).
  - Visual: `AppTheme.light()` mantém os mesmos valores (a `AppPalette.light` é cópia de `AppColors`); `themeMode` continua claro em `app.dart`, que não foi alterado. `AppTheme.dark()` existe mas não é usado.
  - Testes: `flutter analyze` sem issues; `flutter test` 71 passou (Flutter 3.41.9). Backend não alterado; pytest não rodado nesta etapa.
  - Pendências: captura visual não feita. Os testes não montam `AppTheme` porque o Google Fonts tenta baixar fontes pela rede e quebra o teste sem internet; a montagem do tema foi validada só pelo analyze, então confirmar no app (T04 mexe nisso de novo). Tokens escuros `goldLight`, `success` e `successSoft` são palpites por analogia e pedem aprovação.
- **T02 — ColorScheme (parte 2)** — concluída 2026-11-24 (UTC).
  - Arquivos (17): em `features/home/`: `devotional_reader_page`, `retention_primitives`, `settings_account_card`, `progress_insight_card`, `progress_calendar_card`, `progress_badges_widget`, `liturgical_calendar_tab`, `gospel_reader_page`, `push_sdk_info_card`, `prayer_detail_page`, `prayers_tab`, `progress_history_list_item`, `weekday_label`, `settings_reminder_form`; `features/auth/login_page.dart`; `features/onboarding/onboarding_page.dart` e `notification_prompt_page.dart`. Mesmo critério da T01: só valores que batem exatamente com `AppTheme.light()` viraram role do ColorScheme (`0xFF3E6B52`→`primary`, `0xFF1F3A2C`→`onPrimaryContainer`, `0xFF26211C`→`onSurface`, `0xFF5E584E`→`onSurfaceVariant`, `0xFFB8893B`/`AppColors.gold`→`secondary`, `0xFFF4EEE2`→`surfaceContainerHighest`, `0xFFE6DCC8`/`AppColors.sand`→`outlineVariant`, `AppColors.sandDeep`→`outline`, `0xFFF6EBD0`→`secondaryContainer`, `0xFFF6E3E4`→`tertiaryContainer`, `AppColors.surface`/`0xFFFFFDF8`→`surface`). Onde havia `const`, o `const` do pai foi removido. `_tonePalette` (retention_primitives) passou a receber o ColorScheme. Quatro imports de `app_theme.dart` ficaram sem uso e foram removidos.
  - Sem mudança visual pretendida: os valores são os mesmos da paleta; nenhuma API, widget ou tela mudou de comportamento.
  - Não migrado (sem role equivalente ou fica para a parte de modo escuro): pastéis `0xFFEAF4FF`, `0xFFF9F1DF`, `0xFFE8F7EC`, `0xFF2D6C45`, `AppColors.goldLight`, cor de erro `0xFF9C3040`; `Colors.white` (cartões, texto sobre gradiente, card de insight com alpha), `Colors.redAccent`/`Colors.red`/`Colors.grey`. Fora do escopo: `admin_*`, `profile_page`, `cross_ornament`, `home_form_widgets`.
  - Testes: `flutter analyze` sem issues; `flutter test` 68 passou (Flutter 3.41.9, mesmo do CI). Backend não alterado; pytest não rodado nesta etapa.
  - Pendências: captura visual não feita (Leitor, Calendário, Orações, Progresso, Ajustes e login conferidos só por análise de código e testes).
- **T01 — Cores para o ColorScheme (parte 1)** — concluída 2026-11-24 (UTC).
  - Arquivos (só `mobile/lib/src/features/home/`): `hero_card.dart`, `daily_mission_card.dart`, `habit_status_card.dart`, `habit_coach_card.dart`, `milestone_banner.dart`, `metric_card.dart`, `home_state_widgets.dart`, `home_feedback.dart` (erro usa `colorScheme.tertiary`), `completion_feedback_dialog.dart`. Nas paletas por tom, as funções `_paletteForTone`/`_palette` recebem `ColorScheme`. Mapeamento: `0xFF3E6B52`→`primary`, `0xFF1F3A2C`→`onPrimaryContainer`, `0xFF7A2E3A`→`tertiary`, `0xFFF4EEE2`→`surfaceContainerHighest`, `0xFFB8893B`→`secondary`, `0xFFE6DCC8`→`outlineVariant`; `Colors.white`→`onPrimary` (texto sobre gradiente) ou `surface` (cartões); `AppColors.surface/sand`→`surface/outlineVariant`. Imports `app_theme.dart` não usados removidos.
  - Mudança visual intencional e pequena: cartão "Missão do dia" e pílula do coach deixam de ser branco puro e viram o creme `surface` do tema.
  - Não migrado (sem role equivalente, fica para T03): tons pastel das paletas por tom, `0xFFF9F1DF`, `0xFFE9F7ED`, `0xFF4D7C4A` (snackbar de sucesso), `AppColors.gold/goldLight` do hero.
  - Testes: `flutter analyze` sem issues; `flutter test` 68 passou (Flutter 3.41.9). Backend não alterado; pytest não rodado nesta etapa.
  - Pendências: conferência visual do card Hoje (não fiz captura com Playwright nesta rodada).
- **C01-L2 — Reflexões do Advento, lote 2 (08–14/12)** — concluída 2026-11-23 (UTC).
  - Arquivos: `docs/reflexoes-rascunho-advento-lote2.md` (novo; 7 textos, 08/12 Imaculada Conceição e 13/12 Gaudete incluídos). Mesmo formato do lote 1: rascunho, sem texto bíblico, cada texto termina com pergunta e passo prático. Referências copiadas do `docs/calendario-editorial-2026-12-a-2027-03.csv` (já conferidas na Liturgia Diária das Edições CNBB no C01). CSV, catálogo e código não mudaram.
  - Testes: não rodados nesta etapa, pois só um arquivo `.md` novo foi criado (nenhum código, API ou teste tocado).
  - Pendências: revisão humana (D04) de sensibilidade teológica e tamanho; confirmar as referências do 08/12 e do 13/12 contra a página da CNBB antes de colar no CSV.
- **U02 — Card "Hoje"** — concluída 2026-11-22 (UTC).
  - Arquivos: `mobile/lib/src/features/home/today_support.dart` (novo `TodaySupport.formatDayPtBr`: "2026-11-19" → "19 de novembro"; devolve o texto original se não for ISO); `hero_card.dart` (campos opcionais `liturgicalTitle` e `gospelReference`, exibidos só quando preenchidos: título litúrgico em itálico dourado e "Evangelho: <referência>" entre o ornamento e o corpo); `today_devotional_preview.dart` (passa a data formatada e os dois campos); `mobile/test/today_devotional_preview_test.dart` (novo, 4 testes).
  - Backend e contrato da API não mudaram (o endpoint já devolvia `liturgical_title` e `gospel_reference`).
  - Testes: `flutter analyze` sem issues; `flutter test` 68 passou (64 antigos + 4 novos); `pytest` 43 passou. Não fiz captura visual (build web + Playwright) nesta etapa.
  - Pendências: conferência visual no aparelho/web (layout do card com título litúrgico longo); demais telas que mostram data ISO (ex.: histórico de progresso) continuam como estão, fora do escopo da U02.
- **U01 — Acentos nas telas** — concluída 2026-11-21 (UTC).
  - Arquivos: 26 arquivos em `mobile/lib` (telas home, onboarding, auth, `models/retention_models.dart`, `models/devotional_models.dart`, `services/push_sdk_bridge.dart`), só nos textos de UI; identificadores, chaves e valores de API ficaram iguais. Mojibake `â€¢` corrigido em `admin_delivery_list_item.dart` e `admin_due_notification_list_item.dart`. `mobile/test/app_shell_test.dart`: 3 expectativas de texto atualizadas ("Próximo marco 3", "Status do hábito", "4 dias na última semana").
  - Testes: `flutter analyze` sem issues; `flutter test` 64 passou (Flutter 3.41.9); `pytest` 43 passou (backend não alterado).
  - Pendências: fixtures de dados simulados em `app_shell_test.dart` continuam sem acento (não afetam o resultado); textos fora de `mobile/lib` (`mobile/web/`, `AndroidManifest.xml`) não foram revisados nesta etapa; comentário de documentação em `push_token_sync.dart` ficou sem acento (não é texto de UI).
- **N01 — Nome e oração** — concluída 2026-11-20 (UTC).
  - Arquivos: `mobile/lib/src/features/home/home_page.dart` (AppBar "Semente"), `mobile/lib/src/app.dart` (title "Semente – Catequese Diária"), `mobile/web/index.html` (title, apple-mobile-web-app-title "Semente", description), `mobile/web/manifest.json` (name, short_name "Semente", description), `mobile/android/app/src/main/AndroidManifest.xml` (android:label "Semente"), `mobile/lib/src/services/prayer_store.dart` (Suscipe, id `suscipe-santo-inacio`, categoria "Entrega", fonte "Exercícios, n. 234", tradução própria do latim), `mobile/test/prayer_library_test.dart` (3 itens).
  - Testes: `flutter analyze` sem issues; `flutter test` 64 passou (Flutter 3.41.9). Backend não alterado; pytest não rodado nesta etapa.
  - Pendências: revisar a tradução do Suscipe; confirmar o nome final (D01). Nada de `firebase_options.dart` foi commitado (a cópia do `.example` ficou local e ignorada).
- **F00 — Teste quebrado** — concluída 2026-11-19 (UTC).
  - Com o Flutter 3.41.9 do CI o teste de `app_shell_test.dart` já passava; o que quebrava o CI era o `flutter analyze` (info `unnecessary_import`: o import de `cupertino.dart` adicionado em 0892351 é redundante nessa versão, e o analyze sai com código 1 em infos).
  - Arquivos: `mobile/lib/src/theme/app_theme.dart` (remove import redundante); `admin_due_notification_list_item.dart`, `admin_delivery_list_item.dart`, `admin_devotional_list_item.dart`, `progress_history_list_item.dart` (ListTile com `tileColor` envolvido em `Material(type: MaterialType.transparency)`, que evita a asserção "ListTile background color… may be invisible" vista localmente).
  - Testes: pytest 43 passou; `flutter analyze` sem issues; `flutter test` 64 passou.
  - Pendências: se o Flutter local do Wanderson for mais antigo que 3.41.9 e reclamar de `CupertinoPageTransitionsBuilder`, atualizar o Flutter local (o CI é a referência). Mojibake `â€¢` no subtítulo da fila admin fica para a U01.
