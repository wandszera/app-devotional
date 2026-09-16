# Central de operacao multiagente

Esta pasta e o protocolo compartilhado entre o GPT/Codex (orquestrador) e o Google Antigravity (executor). A operacao foi preparada, mas permanece pausada.

## Fluxo

1. O orquestrador transforma um objetivo aprovado em tarefas JSON pequenas.
2. Tarefas nascem em `tasks/backlog/` e so chegam a `tasks/ready/` depois de terem dependencias, escopo, criterios de aceite, worktree e verificacoes definidos.
3. `scripts/agentops.ps1 dispatch` seleciona o agente e o nivel do Antigravity conforme `complexity`.
4. O executor trabalha no worktree informado, executa verificacoes e cria `handoffs/<task-id>.md`.
5. O orquestrador revisa o diff e move a tarefa para `done`, `blocked` ou novamente para `ready`.

## Travas atuais

- `.agentops/config.json`: `executionEnabled` esta `false`.
- `.agentops/state.json`: `status` esta `paused`.
- Nao ha tarefa em `tasks/ready/`.
- O executavel `agy` nao estava instalado ou disponivel no `PATH` durante a preparacao.
- A branch `main` contem um conjunto grande de mudancas locais ainda sem checkpoint; elas nao devem ser usadas como base concorrente ate serem revisadas e registradas.
- O heartbeat `App Devocional — Orquestrador` (`app-devocional-orquestrador`) existe, mas esta `PAUSED` e nao executa tarefas.

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
