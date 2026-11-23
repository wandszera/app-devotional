# Rotina automática — Semente (app_devocional)

Controle da tarefa agendada que roda de hora em hora: cada execução faz **uma** etapa da fila,
marca como concluída e deixa a próxima preparada. Branch de trabalho: `rotina/semente`.

## Estado
- Em andamento: (nenhuma)
- Última execução: 2026-11-23 ~12:20–12:40 UTC — C01-L2 concluída (rascunho das reflexões do Advento, 08–14/12).
- CI esperado: verde (nesta etapa só mudou documentação; último `flutter test` 68 passou, `pytest` 43 passou, na U02).

## Próxima etapa preparada
**T01 — Cores para o ColorScheme (parte 1):** migrar cores fixas (`Colors.white`, hex literais, `AppColors.*` const) para `Theme.of(context).colorScheme` nas telas da aba Hoje. Exige Flutter 3.41.9 no ambiente (instalar conforme CLAUDE.md/AGENTS.md) e `flutter analyze` + `flutter test` passando antes do commit. Sem mudança de API.
Para o Wanderson: revisar as reflexões dos lotes 1 e 2 (`docs/reflexoes-rascunho-advento-lote1.md` e `docs/reflexoes-rascunho-advento-lote2.md`) e decidir D04 (quem revisa) para que os textos possam entrar no CSV. Revisar a tradução própria do Suscipe (`mobile/lib/src/services/prayer_store.dart`, fonte: Exercícios Espirituais de Santo Inácio, n. 234) antes da loja. Confirmar o nome final "Semente – Catequese Diária" (D01). Conferir no aparelho o card Hoje (data "19 de novembro", título litúrgico e "Evangelho: …").

## Regras rápidas
- Uma etapa por execução. Etapa "em andamento" há menos de 50 min = outra execução trabalhando: não fazer nada.
- Nunca decidir D01–D08 pelo Wanderson; etapa bloqueada por decisão vai para "Bloqueadas" e a rotina pega a próxima livre.
- Texto bíblico: só referência (D05). Reflexões são rascunho para revisão humana; não entram no CSV sem aprovação.
- `pytest` e `flutter analyze` + `flutter test` (mobile/) passando antes de cada commit.

## Fila (em ordem)
1. **T01 — Cores para o ColorScheme (parte 1):** migrar cores fixas (`Colors.white`, hex literais, `AppColors.*` const) para `Theme.of(context).colorScheme` nas telas da aba Hoje.
2. **T02 — ColorScheme (parte 2):** demais telas (Calendário, Progresso, Orações, Ajustes, Leitor, onboarding, login).
3. **T03 — Modo escuro:** `AppTheme.dark()` + `themeMode: ThemeMode.system`; conferir contraste (ver `docs/plano-modo-escuro.md`).
4. **C01-L3..L6 — Reflexões, lotes 3 a 6** (15/12–10/01), um lote por etapa.
5. **S01 — Assinatura do AAB:** aplicar no gradle a leitura de `key.properties` (sem segredo no repo), seguindo `docs/roteiro-assinatura-aab.md`.

## Bloqueadas (esperando decisão do Wanderson)
- A02 applicationId e novo app Firebase — D01 (nome final) e D06 (domínio).
- gen_site real (privacidade/exclusão de conta) — D06.
- Reflexões no CSV — D04 (revisor) e revisão do lote 1.
- Texto bíblico completo — D05.

## Histórico
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
