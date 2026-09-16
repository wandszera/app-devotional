# Panorama do App Devocional — 16/09/2026

Este documento consolida a leitura do repositorio e o baseline de qualidade usado para planejar a proxima etapa. Nenhuma das tarefas descritas aqui foi iniciada.

## Produto e arquitetura

O projeto e um monorepo com API FastAPI/SQLAlchemy/Alembic/SQLite e cliente Flutter. A proposta central e formar habito espiritual diario por meio de devocional, conclusao do dia, streak, progresso e lembretes. O produto ja cresceu alem do MVP original e inclui login por senha/Google, favoritos, administracao de conteudo, cache offline, calendario liturgico, catalogo de evangelhos, biblioteca de oracoes, compartilhamento e analytics.

O backend separa rotas, servicos, modelos e persistencia. O Flutter separa telas, controllers, modelos e services, embora alguns fluxos ainda misturem fonte remota, catalogo empacotado e persistencia local. Firebase participa de autenticacao, analytics e messaging, mas parte da configuracao externa ainda esta incompleta.

## Estado verificavel

- Git: `main` em `db84034`, alinhada com `origin/main`, com dezenas de arquivos modificados e nao rastreados. O conjunto local representa varias frentes de trabalho ainda sem checkpoint.
- Backend: 23 testes coletados; 22 passaram e 1 falhou. A falha ocorre em timezone no Windows porque `tzdata` nao esta declarado/instalado. O ambiente Python 3.14 emitiu 97 avisos de APIs depreciadas em FastAPI/Starlette.
- Flutter analyze: falha de compilacao em `gospel_store.dart`; `BundledGospelCatalogue.loadAll()` e chamado, mas nao existe.
- Flutter test: 32 testes chegaram a passar, mas 4 arquivos de teste nao compilaram pela mesma ausencia de `loadAll`; o comando terminou com falha.
- CI/CD: nao ha pipeline versionado, deploy automatizado, container ou gates remotos.
- Antigravity CLI: `agy` nao esta disponivel no `PATH`; portanto o executor externo ainda nao pode ser despachado.

## Capacidades ja presentes

- Cadastro/login por senha, JWT local e troca de token Google/Firebase.
- Devocional diario, conclusao, streak, progresso mensal e favoritos.
- CRUD administrativo de devocionais e endpoints administrativos de notificacao.
- Preferencias de lembrete, token push e historico de entregas.
- Cache local de conteudo/progresso, tentativa de sincronizacao e funcionamento parcial offline.
- Catalogo liturgico empacotado para setembro de 2026, leitor do Evangelho e anotacoes.
- Biblioteca local de oracoes, compartilhamento de reflexao e eventos de analytics.
- Migracoes Alembic e testes backend/widget/unitarios relevantes.

## Riscos priorizados

### P0 — impedir evolucao segura

1. O baseline local nao esta consolidado; agentes concorrentes poderiam sobrescrever trabalho ou partir de estados diferentes.
2. O cliente Flutter nao compila por contrato incompleto do catalogo.
3. O gate backend nao fica verde em Windows pela dependencia de timezone ausente.

### P1 — integridade e produto

1. A conclusao offline guarda apenas uma data; a virada do dia pode apagar uma pendencia sem sincronizar.
2. Ha fontes concorrentes de conteudo: seed/backend, placeholder sob demanda e catalogo empacotado no app. Alteracoes administrativas podem nao aparecer no cliente.
3. Favoritos/preferencias de Evangelho e oracoes nao estao integralmente isolados por usuario local.
4. Streak persistido pode continuar apresentado como atual apos dias sem atividade; backfill historico exige regra explicita.
5. Notificacoes dependem de endpoint administrativo, sem scheduler, lock ou idempotencia robusta.
6. O startup da API cria/altera/semeia banco durante import, concorrendo conceitualmente com Alembic e workers.

### P1/P2 — seguranca e lancamento

1. Android ainda usa identificador de exemplo, assinatura debug em release e precisa confirmar permissao de internet no manifest principal.
2. Token mobile esta em SharedPreferences; JWT nao possui refresh/revogacao/issuer/audience e faltam rate limiting e fluxos de recuperacao/exclusao.
3. Nao ha politica de privacidade, fluxo de exclusao, monitoramento de producao ou operacao de backend definida.
4. Conteudo biblico completo depende de licenca/autorizacao e revisao editorial humana.
5. Acessibilidade e teste end-to-end em aparelho Android ainda nao foram fechados.

## Direcao recomendada

A sequencia segura e: congelar o baseline atual; restaurar build/testes verdes; corrigir integridade offline e fonte de conteudo; isolar dados locais por usuario; tornar notificacoes idempotentes; separar startup/migracao; endurecer autenticacao e preparar Android/producao. Monetizacao deve permanecer depois da estabilizacao de retencao, confiabilidade e privacidade.

O plano operacional detalhado esta em `.agentops/plan.md`; os contratos iniciais ficam em `.agentops/tasks/backlog/` e permanecem desarmados.

