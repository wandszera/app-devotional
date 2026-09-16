# Central de operacao multiagente

Esta pasta e o protocolo compartilhado entre o GPT/Codex (orquestrador) e o Google Antigravity (executor). A operacao foi ativada em 16/09/2026 apos autorizacao explicita do usuario.

## Fluxo

1. O orquestrador transforma um objetivo aprovado em tarefas JSON pequenas.
2. Tarefas nascem em `tasks/backlog/` e so chegam a `tasks/ready/` depois de terem dependencias, escopo, criterios de aceite, worktree e verificacoes definidos.
3. `scripts/agentops.ps1 dispatch` seleciona o agente e o nivel do Antigravity conforme `complexity`.
4. O executor trabalha no worktree informado, executa verificacoes e cria `handoffs/<task-id>.md`.
5. O orquestrador revisa o diff e move a tarefa para `done`, `blocked` ou novamente para `ready`.

Quando todos os gates declarados passam, o executor cria commit e envia a branch dedicada para `origin`. A integracao em `main` continua sendo uma decisao separada do orquestrador/usuario.

## Estado atual

- `.agentops/config.json`: `executionEnabled` esta `true`.
- `.agentops/state.json`: `status` esta `running`.
- O checkpoint aprovado e `039b3eb` na branch `codex/baseline-20260916`.
- O Antigravity CLI 1.2.4 esta instalado em `%LOCALAPPDATA%/agy/bin/agy.exe`.
- O heartbeat `App Devocional — Orquestrador` (`app-devocional-orquestrador`) esta `ACTIVE`.

## Ativacao futura

Quando o usuario autorizar o inicio:

1. Revisar o estado local e criar um checkpoint recuperavel das mudancas existentes.
2. Instalar/autenticar o Antigravity CLI e confirmar `agy models` e `agy agents`.
3. Ajustar os slugs em `config.json` se a conta expuser nomes diferentes.
4. Criar worktrees das primeiras tarefas.
5. Alterar `executionEnabled` para `true` e `status` para `running`.
6. Ativar o heartbeat somente depois das travas anteriores.
7. Validar com `powershell -File scripts/agentops.ps1 validate`.
8. Despachar uma unica tarefa piloto antes de aumentar `maxParallelExecutors`.

O despachante usa o modo headless do Antigravity, com sandbox e saida JSON. Ele nao usa `--dangerously-skip-permissions`.

## Estados

- `backlog`: ideia ainda nao pronta.
- `ready`: contrato completo e liberado pelo orquestrador.
- `running`: executor em atividade.
- `review`: implementacao aguardando revisao.
- `blocked`: depende de decisao, credencial ou estado externo.
- `done`: criterios aceitos e integracao registrada.

Arquivos em `runtime/` sao locais e ignorados pelo Git. Handoffs sao versionados porque formam a memoria duravel da operacao.
