# Plano operacional multiagente

Status: **PAUSADO**. Este plano organiza a execucao futura; nao autoriza implementacao.

## Objetivo operacional

Usar GPT-5.6 Sol como orquestrador e Google Antigravity como executor, com memoria duravel em arquivos, isolamento por worktree, verificacao independente e retomada apos interrupcoes.

## Fases

### Fase 0 — baseline recuperavel

1. Revisar as mudancas locais atuais e separar arquivos alheios ao produto.
2. Criar um checkpoint recuperavel em branch/commit definido pelo usuario.
3. Registrar SHA, inventario de arquivos e resultados dos gates.
4. Instalar e autenticar `agy`; conferir modelos e agentes descobertos.

Saida: base limpa e reproduzivel. Sem isso, nenhuma tarefa vira `ready`.

### Fase 1 — restaurar gates

1. Corrigir o contrato `loadAll` do catalogo Flutter.
2. Declarar/suportar timezone IANA no backend Windows.
3. Rodar `pytest`, `flutter analyze` e `flutter test` ate obter baseline verde.
4. Criar CI minima reproduzindo os mesmos gates.

Saida: toda nova tarefa parte de uma base verificavel.

### Fase 2 — integridade offline e conteudo

1. Modelar fila duravel de conclusoes offline, com multiplas datas, usuario, timezone, idempotencia e retries.
2. Definir uma fonte canonica de conteudo liturgico e a precedencia entre API/cache/bundle.
3. Isolar notas, favoritos e preferencias locais por usuario.
4. Fechar a regra semantica de streak atual e backfill.

Saida: troca de conta, virada do dia, modo aviao e sincronizacao nao perdem nem misturam dados.

### Fase 3 — notificacoes e lifecycle backend

1. Tornar dispatch idempotente e concorrente-seguro.
2. Escolher scheduler/worker e politica de retry/observabilidade.
3. Remover mutacoes de schema do import e separar migrations, seed e startup.
4. Preparar banco/servico para ambiente de producao.

### Fase 4 — seguranca, privacidade e release

1. Endurecer sessao/token e armazenamento seguro no dispositivo.
2. Implementar recuperacao e exclusao de conta/dados.
3. Concluir identidade, assinatura e configuracao Android/Firebase.
4. Fazer auditoria de acessibilidade, licenca editorial e teste em aparelho.

## Roteamento

| Tipo | Planejamento | Execucao | Revisao |
|---|---|---|---|
| Inventario, docs, ajuste local <=3 arquivos | Sol low | Antigravity Flash/low | Sol low |
| Contrato, multiplas camadas, dados, auth, migracao, offline | Sol high | Antigravity Pro/high | Pro/high independente |
| Alteracao externa, release, segredo, deploy | Sol high | Bloqueada ate gate humano | Humano + revisor high |

Promova uma tarefa de leve para alta se surgir mudanca de contrato, mais de tres arquivos relevantes, dependencia nova, ambiguidade material, falha repetida ou qualquer impacto em dados/seguranca.

## Concorrencia

- Na primeira rodada: um executor por vez.
- Depois de tres tarefas integradas sem incidente: no maximo dois executores, apenas com caminhos e contratos independentes.
- Merge e revisao permanecem seriais.
- Cada tarefa usa branch e worktree proprios e banco de teste descartavel.

## Retomada e falhas

O funcionamento ininterrupto significa ser retomavel. Cada tarefa tem estado persistido, handoff, branch, commit e evidencias. Se um processo cair, o orquestrador compara task, worktree, diff e handoff antes de retomar. Nao ha loop infinito: duas falhas de validacao promovem a tarefa para alta; nova falha move para `blocked` e exige diagnostico.

Quando a operacao for habilitada, um heartbeat pode consultar a fila em intervalos regulares. Enquanto pausada, nenhum heartbeat ativo e nenhum worker devem existir.

## Gates humanos

Exigem decisao explicita: checkpoint inicial; push/merge na principal; deploy; migracao de producao; Firebase/segredos; assinatura/loja; exclusao de dados; monetizacao; licenca ou publicacao de conteudo biblico/editorial.

## Primeira rodada proposta

1. `OPS-001` — checkpoint do baseline (gate humano).
2. `MOB-001` — restaurar compilacao do catalogo.
3. `BE-001` — suporte timezone no Windows.
4. `OPS-002` — CI minima.

Somente depois dos quatro itens: `SYNC-001` e `CONTENT-001`.

