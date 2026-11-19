# Rotina automática — Semente (app_devocional)

Controle da tarefa agendada que roda de hora em hora: cada execução faz **uma** etapa da fila,
marca como concluída e deixa a próxima preparada. Branch de trabalho: `rotina/semente`.

## Estado
- Em andamento: (nenhuma)
- Última execução: 2026-11-19 ~22:35 UTC — F00 concluída. Branch `rotina/semente` criada a partir de `chore/F06-limpar-repo` (já contém o `main`).
- CI esperado: verde (pytest 43, `flutter analyze` sem issues, `flutter test` 64 com Flutter 3.41.9).

## Próxima etapa preparada
**N01 — Nome e oração.** A próxima execução troca "App Devocional" por "Semente" / "Semente – Catequese Diária" (AppBar, MaterialApp, web/index.html, manifest, android:label) e acrescenta o Suscipe com tradução própria do latim, ajustando `prayer_library_test.dart`. Para o Wanderson: o nome segue o da sessão de 19/11; se D01 (nome final) mudar, é só trocar as strings. Revisar a tradução do Suscipe quando sair.

## Regras rápidas
- Uma etapa por execução. Etapa "em andamento" há menos de 50 min = outra execução trabalhando: não fazer nada.
- Nunca decidir D01–D08 pelo Wanderson; etapa bloqueada por decisão vai para "Bloqueadas" e a rotina pega a próxima livre.
- Texto bíblico: só referência (D05). Reflexões são rascunho para revisão humana; não entram no CSV sem aprovação.
- `pytest` e `flutter analyze` + `flutter test` (mobile/) passando antes de cada commit.

## Fila (em ordem)
1. **N01 — Nome e oração (sessão de 19/11):** trocar "App Devocional" por "Semente" no AppBar (`home_page.dart`) e por "Semente – Catequese Diária" no `title` do MaterialApp (`app.dart`), `web/index.html` (title, apple-mobile-web-app-title "Semente", description), `web/manifest.json` (name, short_name "Semente") e `android:label="Semente"`. Adicionar ao fim do catálogo de `prayer_store.dart` o Suscipe de Santo Inácio (id `suscipe-santo-inacio`, título "Tomai, Senhor, e recebei (Suscipe)", autor "Santo Inácio de Loyola (Exercícios, n. 234)", categoria "Entrega"; tradução própria do latim) e ajustar `test/prayer_library_test.dart` para 3 itens.
2. **U01 — Acentos nas telas:** corrigir mojibake (`â€¢` em `admin_due_notification_list_item.dart`) e strings fixas sem acento ("nao", "habito", "Missao do dia", "constancia", "Proximo", "consistencia", "concluido", "diario", "Voce", "ja", "esta", "so", "e" verbo etc.) em `mobile/lib`. Ajustar testes que comparam texto.
3. **U02 — Card "Hoje":** mostrar a referência do Evangelho (`gospel_reference`) e o título litúrgico no card da tela Hoje; data em pt-BR ("19 de novembro") no lugar de `2026-11-19`.
4. **C01-L2 — Reflexões do Advento, lote 2 (08–14/12; 08/12 Imaculada Conceição)** em `docs/reflexoes-rascunho-advento-lote2.md`, mesmo formato do lote 1, referências conferidas na Liturgia Diária das Edições CNBB.
5. **T01 — Cores para o ColorScheme (parte 1):** migrar cores fixas (`Colors.white`, hex literais, `AppColors.*` const) para `Theme.of(context).colorScheme` nas telas da aba Hoje.
6. **T02 — ColorScheme (parte 2):** demais telas (Calendário, Progresso, Orações, Ajustes, Leitor, onboarding, login).
7. **T03 — Modo escuro:** `AppTheme.dark()` + `themeMode: ThemeMode.system`; conferir contraste (ver `docs/plano-modo-escuro.md`).
8. **C01-L3..L6 — Reflexões, lotes 3 a 6** (15/12–10/01), um lote por etapa.
9. **S01 — Assinatura do AAB:** aplicar no gradle a leitura de `key.properties` (sem segredo no repo), seguindo `docs/roteiro-assinatura-aab.md`.

## Bloqueadas (esperando decisão do Wanderson)
- A02 applicationId e novo app Firebase — D01 (nome final) e D06 (domínio).
- gen_site real (privacidade/exclusão de conta) — D06.
- Reflexões no CSV — D04 (revisor) e revisão do lote 1.
- Texto bíblico completo — D05.

## Histórico
- **F00 — Teste quebrado** — concluída 2026-11-19 (UTC).
  - Com o Flutter 3.41.9 do CI o teste de `app_shell_test.dart` já passava; o que quebrava o CI era o `flutter analyze` (info `unnecessary_import`: o import de `cupertino.dart` adicionado em 0892351 é redundante nessa versão, e o analyze sai com código 1 em infos).
  - Arquivos: `mobile/lib/src/theme/app_theme.dart` (remove import redundante); `admin_due_notification_list_item.dart`, `admin_delivery_list_item.dart`, `admin_devotional_list_item.dart`, `progress_history_list_item.dart` (ListTile com `tileColor` envolvido em `Material(type: MaterialType.transparency)`, que evita a asserção "ListTile background color… may be invisible" vista localmente).
  - Testes: pytest 43 passou; `flutter analyze` sem issues; `flutter test` 64 passou.
  - Pendências: se o Flutter local do Wanderson for mais antigo que 3.41.9 e reclamar de `CupertinoPageTransitionsBuilder`, atualizar o Flutter local (o CI é a referência). Mojibake `â€¢` no subtítulo da fila admin fica para a U01.
