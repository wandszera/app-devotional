# Panorama do App Devocional — 11/11/2026

Substitui o panorama de 16/09/2026. Baseado na leitura do repositório (`main` em `6d55db0`); os testes backend e Flutter não foram executados nesta análise.

## Produto e arquitetura

Monorepo com API FastAPI + SQLAlchemy + Alembic + SQLite (~2.300 linhas, 23 testes) e cliente Flutter para Android, Windows e web (~8.900 linhas, 44 testes). Objetivo: hábito espiritual diário (Evangelho do dia, conclusão, streak, progresso, favoritos, calendário litúrgico, orações, lembretes e painel admin). Retenção vem antes de monetização.

## Bloqueadores da beta (P0)

1. **Sem conteúdo após setembro/2026.** O catálogo empacotado cobre 01–30/09 e o seed do backend, 7 dias; as demais datas caem no placeholder.
2. **Fonte de conteúdo indefinida.** O bundle sobrescreve campos editados pelo admin (`_applyBundledGospel`); o ADR CONTENT-001A segue "Undecided".
3. **Flutter não compila em checkout limpo.** `firebase_options.dart` e `google-services.json` foram removidos do Git (commit `80f1a08`) e `main.dart` importa o primeiro.
4. **CI sem gate mobile.** O job Flutter foi removido no mesmo commit.
5. **Release Android inviável.** `applicationId` `com.example…`, assinatura debug, sem `INTERNET` no manifest principal, URL padrão `http://10.0.2.2:8000`.
6. **Sessão de 60 min sem refresh.** Qualquer 401 desloga e apaga as flags de onboarding.
7. **Sem produção.** Sem Dockerfile/deploy; CORS só localhost; `init_db()` cria, altera e semeia o banco no import, concorrendo com o Alembic.

## Integridade e retenção (P1)

- Conclusão offline é descartada na virada do dia (`syncPendingCompletions`), embora o backend aceite `completed_date`.
- Fuso padrão UTC e campo de texto livre no cliente; depois das 21h de Brasília o servidor já serve o dia seguinte.
- `GET /streak` devolve o streak persistido mesmo após dias sem atividade.
- Lembretes dependem de um admin chamar `/notifications/admin/dispatch`; sem agendador, sem `onTokenRefresh`, handler de background comentado.
- `last_sent_at` volta do SQLite sem fuso e é convertido como hora local do servidor.
- Faltam recuperação de senha, exclusão de conta e política de privacidade.
- Sem rate limit em login/registro; token em `SharedPreferences`; PBKDF2 com 100 mil iterações.

## Otimizações (P2)

- Acessibilidade (uma única ocorrência de `Semantics`/escala de texto no `lib/`).
- Editor admin Flutter não envia campos litúrgicos.
- Dependências sem versão fixa (`firebase-admin`, `tzdata`); `pytest` junto das dependências de produção.
- `GET /devotional/today` grava placeholder; `/progress` sem paginação.
- Higiene: `.agentops/`, `.worktrees/`, branches `antigravity/*` integradas, logs na raiz, links `file:///c:` no README.

## Ordem recomendada

1. Voltar ao verde: Firebase local reproduzível, gate Flutter no CI, checkpoint do que está pendente.
2. Conteúdo: fechar o ADR e publicar o catálogo do período da beta.
3. Confiabilidade do hábito: sessão longa/refresh, fila offline com data, fuso do aparelho, streak calculado na leitura.
4. Lembretes reais: agendador para o dispatch e ciclo de vida do token FCM.
5. Produção: deploy com HTTPS, migrações só via Alembic, CORS e segredos.
6. Android beta: identidade e assinatura definitivas, permissão de internet, teste em aparelho, trilha de teste interno.
7. Conta e privacidade: exclusão, recuperação de senha, política.

## Decisões pendentes (humanas)

- Fonte canônica do conteúdo (recomendação: API como fonte, bundle só como fallback offline).
- Quem produz o conteúdo editorial dos próximos meses (nenhum conteúdo foi gerado aqui).
- Hospedagem (SQLite + volume persistente basta para a beta; Postgres só com mais de uma instância).
