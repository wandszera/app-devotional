# Rotina automática — Semente (app_devocional)

Controle da tarefa agendada que roda de hora em hora: cada execução faz **uma** etapa da fila,
marca como concluída e deixa a próxima preparada. Branch de trabalho: `rotina/semente`.

## Estado
- Em andamento: (nenhuma)
- Última execução: 2026-11-20 ~12:50 UTC — N01 concluída (nome "Semente" no app, web e Android; Suscipe no catálogo de orações).
- CI esperado: verde (`flutter analyze` sem issues, `flutter test` 64 passou com Flutter 3.41.9; backend sem mudanças nesta etapa).

## Próxima etapa preparada
**U01 — Acentos nas telas.** A próxima execução corrige o mojibake `â€¢` em `admin_due_notification_list_item.dart` e as strings fixas sem acento em `mobile/lib` ("nao", "habito", "Missao do dia", "constancia", "Proximo", "concluido", "diario", "Voce", "ja", "esta", "so" etc.), ajustando os testes que comparam texto.
Para o Wanderson: revisar a tradução própria do Suscipe (`mobile/lib/src/services/prayer_store.dart`, fonte: Exercícios Espirituais de Santo Inácio, n. 234) antes de ele ir para a loja. E confirmar o nome final "Semente – Catequese Diária" (D01); se mudar, é só trocar as strings de `app.dart`, `home_page.dart`, `web/index.html`, `web/manifest.json` e `AndroidManifest.xml`.

## Regras rápidas
- Uma etapa por execução. Etapa "em andamento" há menos de 50 min = outra execução trabalhando: não fazer nada.
- Nunca decidir D01–D08 pelo Wanderson; etapa bloqueada por decisão vai para "Bloqueadas" e a rotina pega a próxima livre.
- Texto bíblico: só referência (D05). Reflexões são rascunho para revisão humana; não entram no CSV sem aprovação.
- `pytest` e `flutter analyze` + `flutter test` (mobile/) passando antes de cada commit.

## Fila (em ordem)
1. **U01 — Acentos nas telas:** corrigir mojibake (`â€¢` em `admin_due_notification_list_item.dart`) e strings fixas sem acento ("nao", "habito", "Missao do dia", "constancia", "Proximo", "consistencia", "concluido", "diario", "Voce", "ja", "esta", "so", "e" verbo etc.) em `mobile/lib`. Ajustar testes que comparam texto.
2. **U02 — Card "Hoje":** mostrar a referência do Evangelho (`gospel_reference`) e o título litúrgico no card da tela Hoje; data em pt-BR ("19 de novembro") no lugar de `2026-11-19`.
3. **C01-L2 — Reflexões do Advento, lote 2 (08–14/12; 08/12 Imaculada Conceição)** em `docs/reflexoes-rascunho-advento-lote2.md`, mesmo formato do lote 1, referências conferidas na Liturgia Diária das Edições CNBB.
4. **T01 — Cores para o ColorScheme (parte 1):** migrar cores fixas (`Colors.white`, hex literais, `AppColors.*` const) para `Theme.of(context).colorScheme` nas telas da aba Hoje.
5. **T02 — ColorScheme (parte 2):** demais telas (Calendário, Progresso, Orações, Ajustes, Leitor, onboarding, login).
6. **T03 — Modo escuro:** `AppTheme.dark()` + `themeMode: ThemeMode.system`; conferir contraste (ver `docs/plano-modo-escuro.md`).
7. **C01-L3..L6 — Reflexões, lotes 3 a 6** (15/12–10/01), um lote por etapa.
8. **S01 — Assinatura do AAB:** aplicar no gradle a leitura de `key.properties` (sem segredo no repo), seguindo `docs/roteiro-assinatura-aab.md`.

## Bloqueadas (esperando decisão do Wanderson)
- A02 applicationId e novo app Firebase — D01 (nome final) e D06 (domínio).
- gen_site real (privacidade/exclusão de conta) — D06.
- Reflexões no CSV — D04 (revisor) e revisão do lote 1.
- Texto bíblico completo — D05.

## Histórico
- **N01 — Nome e oração** — concluída 2026-11-20 (UTC).
  - Arquivos: `mobile/lib/src/features/home/home_page.dart` (AppBar "Semente"), `mobile/lib/src/app.dart` (title "Semente – Catequese Diária"), `mobile/web/index.html` (title, apple-mobile-web-app-title "Semente", description), `mobile/web/manifest.json` (name, short_name "Semente", description), `mobile/android/app/src/main/AndroidManifest.xml` (android:label "Semente"), `mobile/lib/src/services/prayer_store.dart` (Suscipe, id `suscipe-santo-inacio`, categoria "Entrega", fonte "Exercícios, n. 234", tradução própria do latim), `mobile/test/prayer_library_test.dart` (3 itens).
  - Testes: `flutter analyze` sem issues; `flutter test` 64 passou (Flutter 3.41.9). Backend não alterado; pytest não rodado nesta etapa.
  - Pendências: revisar a tradução do Suscipe; confirmar o nome final (D01). Nada de `firebase_options.dart` foi commitado (a cópia do `.example` ficou local e ignorada).
- **F00 — Teste quebrado** — concluída 2026-11-19 (UTC).
  - Com o Flutter 3.41.9 do CI o teste de `app_shell_test.dart` já passava; o que quebrava o CI era o `flutter analyze` (info `unnecessary_import`: o import de `cupertino.dart` adicionado em 0892351 é redundante nessa versão, e o analyze sai com código 1 em infos).
  - Arquivos: `mobile/lib/src/theme/app_theme.dart` (remove import redundante); `admin_due_notification_list_item.dart`, `admin_delivery_list_item.dart`, `admin_devotional_list_item.dart`, `progress_history_list_item.dart` (ListTile com `tileColor` envolvido em `Material(type: MaterialType.transparency)`, que evita a asserção "ListTile background color… may be invisible" vista localmente).
  - Testes: pytest 43 passou; `flutter analyze` sem issues; `flutter test` 64 passou.
  - Pendências: se o Flutter local do Wanderson for mais antigo que 3.41.9 e reclamar de `CupertinoPageTransitionsBuilder`, atualizar o Flutter local (o CI é a referência). Mojibake `â€¢` no subtítulo da fila admin fica para a U01.
