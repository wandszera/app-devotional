Leia também ../AGENTS.md (papéis dos agentes, regras globais e fluxo padrão).

# AGENTS.md — app_devocional

> Substitui o AGENTS.md anterior (orquestração Codex/Antigravity com `.agentops/`), movido para `_to_delete/AGENTS_antigo_codex.md`.
> A pasta `.agentops/` e as `.worktrees/` são de outra ferramenta: não usar, não editar.

## Projeto
- O que é: app para criar hábito espiritual diário (devocional do dia, leitura concluída, streak, progresso, favoritos,
  calendário litúrgico, orações, notificações). **Retenção vem antes de monetização.**
- Fase: ativo / portfólio. GitHub `wandszera/app-devotional`, CI em `.github/workflows/ci.yml`.
- Fontes de verdade: `README.md`, `docs/product-roadmap.md`, `docs/release-checklist.md`.

## Stack
- Backend: Python, FastAPI 0.115, SQLAlchemy 2.0, Alembic, SQLite (`devotional.db`), firebase-admin (push).
- Cliente: Flutter (`mobile/`) para Android, Windows e web, com painel admin.

## Comandos
- Backend: `pip install -r requirements.txt` · `python -m uvicorn app.main:app --reload` · `python -m pytest -q`
- Mobile: `cd mobile; flutter pub get; flutter test; flutter analyze`
- Admin: `make_admin.py` só com pedido.

## Estrutura
- `app/` (API), `alembic/`, `tests/` (pytest), `mobile/` (Flutter, testes em `mobile/test/`), `scripts/`, `docs/`.
- Logs `backend_web.*.log`, `flutter_web.*.log`: não versionados.

## Sensíveis
`.env`, `devotional.db`, `serviceAccountKey.json`, `mobile/android/app/google-services.json`,
`mobile/ios/Runner/GoogleService-Info.plist`, `mobile/lib/firebase_options.dart`.

## Regras específicas
- Tarefa complexa (modelo pesado + Revisão): atravessa backend e Flutter, altera esquema/migração, autenticação,
  sincronização offline, notificações, segurança ou dados editoriais; ou critério de aceite ambíguo.
- Contrato da API: mudança em endpoint usado pelo Flutter exige ajustar os dois lados e os testes dos dois lados.
- Conteúdo religioso (textos devocionais, orações, calendário litúrgico): não gerar nem alterar conteúdo editorial sem pedido;
  fonte sempre indicada.
- `secret_key` precisa ser validada em produção (tarefa 5.3); não enfraquecer.

## Pendências / [INFORMAR]
- Publicação nas lojas e ambiente de produção: `[INFORMAR]`.
