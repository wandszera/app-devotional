# ADR: Diagnóstico das Fontes de Conteúdo Litúrgico (CONTENT-001A)

## Status
Proposed / Undecided

## Contexto e Problema
Atualmente, o aplicativo Devocional gerencia conteúdo litúrgico (título litúrgico, referência do evangelho e reflexão) em diferentes camadas da aplicação. Há um fluxo de dados complexo que envolve o bundle no cliente (Flutter), cache local (SQLite no mobile), a API (backend FastAPI), o banco de dados principal (SQLite no backend), e um script de seed, bem como operações CRUD administrativas. 

Foi diagnosticado que a aplicação possui uma substituição silenciosa, onde o bundle local no aplicativo mobile ignora as alterações feitas via CRUD no backend e impõe seu próprio conteúdo editorial, limitando a capacidade de atualização dinâmica. O backend não tem ciência da versão do catálogo que o cliente possui, impedindo uma sincronização eficaz. 

O escopo desta ADR é registrar esse comportamento, inventariar as fontes existentes e propor alternativas de arquitetura sem tomar a decisão da fonte canônica, a qual dependerá de validações editoriais e de licença.

## Matriz de Fontes de Verdade

| Componente | Produtor | Consumidor | Autoridade de Escrita | Versão | Cobertura | Offline | Risco Editorial |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Bundle** (`gospel_catalogue.json`) | Publicador | Mobile App | Alta (sobrescreve API) | v1 (interna) | 30 entradas | Sim | Baixo (estático) |
| **Cache Local** (`LocalDbService`) | Mobile App | Mobile App | Média | N/A | Dinâmica | Sim | Baixo |
| **API / Banco** (`DevotionalModel`) | CRUD / Seed| API Client | Baixa (sobrescrita local) | N/A | 7 entradas ou Placeholder | Não | Alto (CRUD exposto) |
| **Seed** (`init_db.py`) | Desenvolvedor | Banco de Dados | Baixa | N/A | 7 entradas | N/A | Baixo |
| **Placeholder** (`DevotionalService`) | Backend | API / Cache | Nula (apenas aviso) | N/A | Dinâmica | Não | Baixo |
| **CRUD** (`AdminDevotional`) | Administrador| Banco de Dados | Média (limitada no cliente)| N/A | Dinâmica | Não | Alto |

## Diagnóstico do Fluxo Atual e Precedência

As constatações abaixo foram verificadas no código-fonte e detalham o comportamento de precedência dos dados:

1. **Substituição silenciosa do CRUD pelo bundle**: O backend envia um devocional da API através da classe `ApiClient` (`mobile/lib/src/services/api_client.dart`). Porém, antes de retornar o devocional, a função `_applyBundledGospel` consulta o `BundledGospelCatalogue`. Se a data existir no arquivo `assets/liturgy/gospel_catalogue.json`, os campos `content` (reflexão), `liturgicalTitle`, `gospelReference` e `sourceUrl` vindos da API são descartados e substituídos pelos dados do bundle.
2. **Cobertura de 30 contra 7 entradas**: O arquivo `mobile/assets/liturgy/gospel_catalogue.json` contém 30 entradas para o mês de setembro de 2026. Em contrapartida, o seed de inicialização `INITIAL_GOSPEL_CATALOGUE` na base de dados (em `app/db/init_db.py`) abrange apenas as 7 primeiras entradas.
3. **Versão do catálogo que não atravessa o fluxo**: O `gospel_catalogue.json` possui uma chave `"catalogue_version": 1`. Essa informação de versionamento existe unicamente no bundle do Flutter e nunca é transmitida ao backend, impossibilitando negociação de versão ou sincronização de cache na API.
4. **Fluxos Online e Precedência**: Quando online, `ApiClient.getTodayDevotional` chama a API (`/devotional/today`). O banco provê o devocional. Se o devocional não existe no banco, `DevotionalService._get_or_create_today_devotional` em `app/services/devotional_service.py` injeta um placeholder avisando "A referência do Evangelho ainda não foi adicionada...". Contudo, se a data constar no bundle local, ele será o vencedor final devido ao `_applyBundledGospel`.
5. **Cache Offline**: Após recuperar (e sobrepor) os dados, eles são salvos em cache via `LocalDbService().cacheDevotional`. Se o app for aberto offline (`SocketException`), ele tenta buscar do cache. Se não houver cache, lê diretamente do `BundledGospelCatalogue.instance.findByDate`.
6. **Calendário Litúrgico**: O calendário é listado no Flutter pela `GospelLibraryStore.loadMonth` (`mobile/lib/src/services/gospel_store.dart`), a qual lê toda a lista fornecida pelo `BundledGospelCatalogSource` (o bundle estático).
7. **Edição Administrativa (CRUD)**: Administradores podem atualizar títulos e reflexões usando a API (funções na camada de serviço), que afetam a base de dados. No entanto, clientes móveis ignoram silenciosamente esse texto se houver concorrência de data com o bundle.

## Alternativas de Arquitetura (Pendentes de Decisão)

1. **Backend como Fonte Canônica Absoluta (API First)**
   - *Produtor*: CRUD / Seed.
   - *Consumidor*: Mobile (via sincronização).
   - *Cobertura e Risco*: Maior risco editorial, requer forte restrição de CRUD e controle sobre licença de uso do texto bíblico. O aplicativo deve ser capaz de fazer cache e pre-fetch do calendário inteiro.
   - *Decisão*: Undecided.

2. **Bundle Estático como Fonte Canônica (Offline First)**
   - *Produtor*: Pipeline de Build Flutter.
   - *Consumidor*: Mobile.
   - *Cobertura e Risco*: Risco baixíssimo de alterações inadvertidas. No entanto, para publicar novos meses, exigiria lançar uma nova versão do app nas lojas, o que prejudica a experiência e escalabilidade.
   - *Decisão*: Undecided.

3. **Backend via Versionamento de Catálogo (Sincronização Híbrida)**
   - *Produtor*: CMS / API com catálogo versionado.
   - *Consumidor*: Mobile App (fazendo download de bundles em runtime, não hardcoded).
   - *Cobertura e Risco*: Combina a segurança de conteúdo curado (bundle) com a flexibilidade da nuvem. Requer uma nova mecânica de versionamento e migração.
   - *Decisão*: Undecided.

## Gates Humanos Bloqueantes

A aprovação da fonte canônica esbarra nestes impedimentos, exigindo deliberação humana:
- **Licença de texto bíblico**: Nenhuma fonte atual usa texto bíblico integral protegido. Se adotarmos uma fonte externa ou salvarmos passagens completas, será preciso atestar a licença do texto.
- **Revisão editorial**: O conteúdo não deve ser modificado automaticamente por agentes. O processo de revisão editorial é necessário.
- **Novos meses**: O bundle possui apenas dados até setembro de 2026. A adição de meses futuros precisa ser coordenada (seja no app ou na API).
- **Aprovação da fonte canônica**: A decisão final de qual serviço será autoridade e como o conflito atual será sanado.

## Tarefas Posteriores Propostas

Para solucionar este diagnóstico, o trabalho deve ser quebrado nestas etapas de forma independente:
1. **Decisão Arquitetural**: Decidir qual alternativa listada adotaremos como fonte canônica. 
2. **Contrato/versionamento**: Definir a API de troca de versão entre Flutter e Backend (informando `catalogue_version` no header ou query params).
3. **Sincronização/migração**: Eliminar a substituição silenciosa no app, criar rotinas de migração para o banco de dados e garantir que dados editoriais possuam versionamento compatível.
4. **Testes**: Adicionar testes robustos no cliente e no backend demonstrando o comportamento correto offline e online para a fonte canônica escolhida.
