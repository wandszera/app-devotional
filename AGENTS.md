# Operacao multiagente do App Devocional

Este arquivo vale para todo o repositorio e deve ser lido por Codex/GPT, Antigravity e qualquer subagente antes de atuar.

## Contexto do produto

- Backend: FastAPI, SQLAlchemy, Alembic e SQLite.
- Cliente: Flutter para Android, Windows e web.
- Objetivo do produto: criar habito espiritual diario; retencao vem antes de monetizacao.
- Fluxos centrais: autenticacao, devocional do dia, leitura concluida, streak, progresso, favoritos, calendario liturgico, oracoes e notificacoes.
- Fontes de verdade: `README.md`, `docs/product-roadmap.md` e `docs/release-checklist.md`.

## Papeis

- GPT/Codex e o orquestrador. Ele entende o pedido, inspeciona o estado, define tarefas pequenas, resolve dependencias, escolhe o nivel de raciocinio, revisa resultados e decide o proximo passo.
- Antigravity e o executor. Ele so implementa uma tarefa formal em `.agentops/tasks/ready/`, respeita o escopo e devolve um handoff verificavel.
- O revisor nao implementa. Ele compara diff, criterios de aceite, testes e riscos.

O orquestrador nao deve delegar uma meta ampla. Cada tarefa precisa ter escopo, caminhos permitidos, criterios de aceite, verificacoes e proibicoes explicitas.

## Trava de inicio

Antes de alterar codigo, leia `.agentops/config.json` e `.agentops/state.json`.

- Se `executionEnabled` for `false`, ou se `status` nao for `running`, nao implemente, nao despache e nao mova tarefas. Auditoria e atualizacao da documentacao operacional continuam permitidas quando pedidas pelo usuario.
- O executor so pode trabalhar em uma tarefa cujo arquivo esteja em `.agentops/tasks/ready/` e cujo campo `status` seja `ready`.
- O repositorio esta inicialmente pausado. Somente uma instrucao explicita do usuario pode habilitar a execucao.

## Roteamento de modelos

- Planejamento complexo: `gpt-5.6-sol` com raciocinio `high`.
- Planejamento simples, triagem e acompanhamento: `gpt-5.6-sol` com raciocinio `low`.
- Execucao complexa no Antigravity: agente `antigravity-executor-high`, modelo Pro, esforco alto.
- Execucao simples no Antigravity: agente `antigravity-executor-light`, modelo Flash, esforco baixo.
- Revisao de mudanca de alto risco: agente `antigravity-reviewer`, modelo Pro.

Considere complexa uma tarefa que atravesse backend e Flutter, altere esquema/migracao, autenticacao, sincronizacao offline, notificacoes, seguranca, dados editoriais ou tenha criterio de aceite ambiguo. Alteracoes locais, mecanicas, bem delimitadas e reversiveis podem usar o nivel leve.

## Isolamento e Git

- Preserve todo trabalho existente do usuario. Nunca descarte, reverta ou sobrescreva alteracoes alheias.
- Nao execute uma tarefa em uma arvore de trabalho suja. Use um worktree e branch dedicados por tarefa, criados a partir do checkpoint aprovado pelo orquestrador.
- Prefixos recomendados: `codex/<task-id>` para trabalho do orquestrador e `antigravity/<task-id>` para execucao.
- Um executor por worktree. Tarefas paralelas nao podem editar os mesmos arquivos.
- Quando todas as verificacoes declaradas na tarefa passarem, o executor deve criar um commit na branch dedicada e fazer push dessa branch para `origin`.
- Quando todas as verificacoes declaradas passarem e a revisao nao tiver achados bloqueantes, o orquestrador deve fazer merge automatico da branch dedicada na `baseBranch` registrada em `.agentops/state.json` e fazer push dessa baseline.
- Nunca faca push direto ou merge em `main` ou outra branch protegida. Force-push, release, deploy, publicacao em loja e alteracoes de servicos externos continuam exigindo autorizacao explicita do usuario.

## Contrato de execucao

1. Leia a tarefa e repita internamente objetivo, escopo e criterios de aceite.
2. Inspecione apenas o contexto necessario.
3. Implemente a menor mudanca coerente que satisfaca a tarefa.
4. Rode as verificacoes indicadas. Nao esconda falhas preexistentes.
5. Se todas as verificacoes passarem, crie um commit descritivo e faca push da branch da tarefa para `origin`. Se qualquer verificacao falhar, nao faca commit nem push.
6. Gere um handoff em `.agentops/handoffs/<task-id>.md` com resumo, arquivos, comandos, resultados, branch remota, riscos e pendencias.
7. Pare. O orquestrador revisa e, se todos os gates estiverem verdes e nao houver achado bloqueante, integra automaticamente na baseline; caso contrario, solicita retrabalho.

## Qualidade minima

- Backend: `python -m pytest -q` e, quando houver migracao, `python -m alembic upgrade head` em banco descartavel.
- Flutter: `flutter analyze` e `flutter test` dentro de `mobile/`.
- Mudancas de contrato API exigem teste do backend e ajuste/teste do cliente afetado.
- Nunca use o banco `devotional.db` como banco de teste destrutivo.
- Credenciais Firebase, chaves e tokens nunca entram no repositorio nem em logs de handoff.

## Limites de produto

- Nao copie texto biblico protegido sem licenca ou autorizacao documentada.
- Mudancas editoriais devem indicar fonte e revisao humana necessaria.
- Priorize funcionamento offline seguro, acessibilidade e preservacao do historico do usuario.
