# Rotina automática — Semente (app_devocional)

Controle da tarefa agendada que roda de hora em hora: cada execução faz **uma** etapa da fila,
marca como concluída e deixa a próxima preparada. Branch de trabalho: `rotina/semente`.

## Estado
- Em andamento: (nenhuma)
- Última execução: 2026-11-26 (UTC) — C01-L9 concluída: `docs/reflexoes-rascunho-tempo-comum-lote9.md` com 7 rascunhos (25/01 a 31/01; 25/01 é a Festa da Conversão de São Paulo; 31/01 é o 4º Domingo, Ano B), mesmo formato dos lotes 2 a 8. Só `.md`; nenhum código, CSV ou catálogo mudou. Referências copiadas do CSV (`ref_cnbb_ok`). A conferência na Liturgia Diária CNBB continua pendente, porque o site carrega o conteúdo por JavaScript.
- Testes: não rodados nesta etapa (só `.md` novo). Última validação de código: T04d (`flutter analyze` sem issues; `flutter test` 71 passou). Backend não tocado.

## Próxima etapa preparada
**C01-L10 — Reflexões do Tempo Comum, lote 10 (01/02/2027 a 07/02/2027):** escrever 7 rascunhos no mesmo formato, em `docs/reflexoes-rascunho-tempo-comum-lote10.md`. Copiar as referências do CSV (01/02 a 07/02: Mc 5,1-20; Lc 2,22-40; Mc 6,1-6; Mc 6,7-13; Mc 6,14-29; Mc 6,30-34; 07/02 domingo, 5º do Tempo Comum, Ano B, Mc 1,29-39). Atenções: 02/02 é a Apresentação do Senhor (festa) e repete Lc 2,22-40, já usado em 27/12 (lote 5); 07/02 repete Mc 1,29-39, já usado em 13/01 (lote 7): registrar a repetição como pendência; 05/02 (Mc 6,14-29, morte de João Batista) tem violência explícita, então o texto trata do cuidado com a verdade e não descreve a cena; 01/02 (Mc 5,1-20) tem a cura do endemoninhado de Gerasa, texto longo: a reflexão trata do convite a pedir a Jesus que nos liberte, sem detalhes. Não reabrir a CNBB por fetch simples (página é JavaScript). Só referência bíblica, nunca o texto (D05). Cada texto termina com pergunta e passo prático. CSV, catálogo e código não mudam. Um commit e push para o lote.
Para o Wanderson: (a) revisar o lote 9 (D04): 25/01 é festa, e Mc 16,9-20 (final longo de Marcos) aparece na referência do CSV: decidir se o revisor quer nota sobre isso; 26/01 usa "outros discípulos" em vez de "setenta e dois", porque há variação nos manuscritos; 27/01 fala só do convite da parábola; 31/01 repete Mc 1,21-28 de 12/01 (lote 7): decidir se 31/01 ganha outro foco ou se a repetição fica; (b) revisar o tom de 30/01 ("por que ainda não confiavam"); (c) conferir na CNBB as referências de 25/01 a 31/01 e as dos lotes 3 a 8, porque o site não pode ser lido por aqui; (d) decidir sobre as repetições de 02/02 (lote 5) e 07/02 (lote 7) antes de escrever o lote 10, se quiser outro foco.

## Regras rápidas
- Uma etapa por execução. Etapa "em andamento" há menos de 50 min = outra execução trabalhando: não fazer nada.
- Nunca decidir D01–D08 pelo Wanderson; etapa bloqueada por decisão vai para "Bloqueadas" e a rotina pega a próxima livre.
- Texto bíblico: só referência (D05). Reflexões são rascunho para revisão humana; não entram no CSV sem aprovação.
- `pytest` e `flutter analyze` + `flutter test` (mobile/) passando antes de cada commit.

## Fila (em ordem)
1. **C01-L11 em diante — Reflexões do Tempo Comum, lotes seguintes até o fim do calendário (março de 2027):** um lote por etapa, a partir de 08/02/2027 (ler o CSV e fazer 7 textos).
2. **S01 — Assinatura do AAB:** aplicar no gradle a leitura de `key.properties` (sem segredo no repo), seguindo `docs/roteiro-assinatura-aab.md`.

## Bloqueadas (esperando decisão do Wanderson)
- A02 applicationId e novo app Firebase — D01 (nome final) e D06 (domínio).
- gen_site real (privacidade/exclusão de conta) — D06.
- Reflexões no CSV — D04 (revisor) e revisão do lote 1.
- Texto bíblico completo — D05.

## Histórico
- **C01-L9 — Reflexões do Tempo Comum, lote 9 (25/01/2027–31/01/2027)** — concluída 2026-11-26 (UTC).
  - Arquivos: `docs/reflexoes-rascunho-tempo-comum-lote9.md` (novo; 7 textos de 84 a 105 palavras: 25/01 Mc 16,15-18 · Festa da Conversão de São Paulo; 26/01 Lc 10,1-9; 27/01 Mc 4,1-20; 28/01 Mc 4,21-25; 29/01 Mc 4,26-34; 30/01 Mc 4,35-41; 31/01 Mc 1,21-28 · 4º Domingo do Tempo Comum, Ano B). Mesmo formato dos lotes 2 a 8; sem texto bíblico; cada texto termina com pergunta e passo prático. Referências copiadas do CSV. CSV, catálogo e código não mudaram.
  - Testes: não rodados (só `.md` novo).
  - Pendências: conferência CNBB não feita (site carrega por JavaScript); Mc 16,9-20 (final longo de Marcos) em 25/01; "setenta e dois" x "setenta" em 26/01; 27/01 trata do convite, não da parábola inteira; 31/01 repete Mc 1,21-28 de 12/01 (lote 7); revisão humana (D04).
- **C01-L8 — Reflexões do Tempo Comum, lote 8 (18/01/2027–24/01/2027)** — concluída 2026-11-25 (UTC).
  - Arquivos: `docs/reflexoes-rascunho-tempo-comum-lote8.md` (novo; 7 textos: 18/01 Mc 2,18-22; 19/01 Mc 2,23-28; 20/01 Mc 3,1-6; 21/01 Mc 3,7-12; 22/01 Mc 3,13-19; 23/01 Mc 3,20-21; 24/01 Mc 1,14-20 · 3º Domingo do Tempo Comum, Ano B). Mesmo formato dos lotes 2 a 7; sem texto bíblico; cada texto termina com pergunta e passo prático. Referências copiadas do CSV. CSV, catálogo e código não mudaram.
  - Testes: não rodados (só `.md` novo).
  - Pendências: conferência CNBB das referências não feita (site carrega por JavaScript); 24/01 repete Mc 1,14-20 de 11/01; tom sobre fariseus e sábado (18/01 a 20/01); tradução de "fora de si" em 23/01; tamanho ~105 palavras por texto; revisão humana (D04).
- **C01-L7 — Reflexões do Tempo Comum, lote 7 (11/01/2027–17/01/2027)** — concluída 2026-11-24 (UTC).
  - Arquivos: `docs/reflexoes-rascunho-advento-lote7.md` (novo; 7 textos: 11/01 Mc 1,14-20; 12/01 Mc 1,21b-28; 13/01 Mc 1,29-39; 14/01 Mc 1,40-45; 15/01 Mc 2,1-12; 16/01 Mc 2,13-17; 17/01 Jo 1,35-42 · 2º Domingo do Tempo Comum, Ano B). Mesmo formato dos lotes 2 a 6; sem texto bíblico; cada texto termina com pergunta e passo prático. Referências copiadas do CSV. CSV, catálogo e código não mudaram.
  - Testes: não rodados (só `.md` novo).
  - Pendências: conferência CNBB das referências não feita (site carrega por JavaScript); 14/01 repete o episódio do leproso de 08/01 (lote 6, Lc 5,12-16); ano litúrgico de 17/01 (Ano B) a conferir; sensibilidade de 12/01 e 15/01; tamanho ~80 palavras por texto; revisão humana (D04).
- **C01-L6 — Reflexões do Advento/Natal, lote 6 (05/01/2027–10/01/2027)** — concluída 2026-11-24 (UTC).
  - Arquivos: `docs/reflexoes-rascunho-advento-lote6.md` (novo; 6 textos: 05/01 Mc 6,34-44; 06/01 Mc 6,45-52; 07/01 Lc 4,14-22a; 08/01 Lc 5,12-16; 09/01 Jo 3,22-30; 10/01 Mc 1,7-11 · Batismo do Senhor). Mesmo formato dos lotes 2 a 5; sem texto bíblico; cada texto termina com pergunta e passo prático. Referências copiadas do CSV. CSV, catálogo e código não mudaram.
  - Testes: não rodados (só `.md` novo).
  - Pendências: conferência CNBB das referências não feita (site carrega por JavaScript); 10/01 é festa e domingo, conferir a referência; revisão humana (D04); tamanho ~90 palavras por texto.
- **C01-L5 — Reflexões do Advento/Natal, lote 5 (29/12/2026–04/01/2027)** — concluída 2026-11-24 (UTC).
  - Arquivos: `docs/reflexoes-rascunho-advento-lote5.md` (novo; 7 textos: 29/12 Lc 2,22-35; 30/12 Lc 2,36-40; 31/12 Jo 1,1-18; 01/01 Lc 2,16-21 (Santa Maria, Mãe de Deus); 02/01 Jo 1,19-28; 03/01 Mt 2,1-12 (Epifania); 04/01 Mt 4,12-17.23-25). Mesmo formato dos lotes 2 a 4; sem texto bíblico; cada texto termina com pergunta e passo prático. Referências copiadas do CSV. CSV, catálogo e código não mudaram.
  - Testes: não rodados (só `.md` novo).
  - Pendências: conferência CNBB das referências não feita (site carrega por JavaScript); sobreposição com o lote 4 (31/12 e 01/01); transferência da Epifania para o domingo (03/01); tamanho ~90 palavras por texto; revisão humana (D04).
- **C01-L4 — Reflexões do Advento/Natal, lote 4 (22/12–28/12)** — concluída 2026-11-24 (UTC).
  - Arquivos: `docs/reflexoes-rascunho-advento-lote4.md` (novo; 7 textos: 22/12 Lc 1,46-56; 23/12 Lc 1,57-66; 24/12 Lc 1,67-79 e Lc 2,1-14; 25/12 Jo 1,1-18 e Lc 2,15-20; 26/12 Mt 10,17-22; 27/12 Lc 2,22-40; 28/12 Mt 2,13-18). Mesmo formato dos lotes 2 e 3; sem texto bíblico; cada texto termina com pergunta e passo prático. CSV, catálogo e código não mudaram.
  - Testes: não rodados (só `.md` novo).
  - Pendências: conferência CNBB das referências não feita (a página inicial responde HTTP 200, mas o conteúdo é carregado por JavaScript); título de 26/12 no CSV ("Tempo do Natal") pode precisar ser "Santo Estêvão"; revisão humana (D04); sensibilidade de Mt 2,13-18 e Mt 10.
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
