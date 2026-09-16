# ADR: Diagnóstico das Fontes de Conteúdo Litúrgico (CONTENT-001A)

## Status

Proposed / Undecided

## Contexto e problema

O aplicativo mantém conteúdo litúrgico no bundle Flutter, no cache SQLite do cliente, na API e no banco do backend. Há ainda carga inicial por seed, criação persistente de placeholder e operações CRUD administrativas. Este ADR registra o comportamento atual e suas ambiguidades; ele não escolhe, recomenda nem declara uma fonte canônica.

O conflito mais relevante é uma substituição silenciosa no cliente. Para datas presentes no bundle, `_applyBundledGospel` substitui campos editoriais recebidos da API ou recuperados do cache. Assim, uma edição administrativa pode estar correta no banco e ainda não ser exibida no fluxo "hoje" do aplicativo (`mobile/lib/src/services/api_client.dart::ApiClient._applyBundledGospel`; `app/routes/devotional.py::update_devotional`; `app/services/devotional_service.py::DevotionalService.update_devotional`).

## Matriz das fontes atuais

| Fonte/componente | Produtor | Consumidor | Autoridade de escrita observada | Versão | Cobertura observada | Offline | Risco editorial |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Bundle (`gospel_catalogue.json`) | Publicador do build Flutter | Fluxo "hoje" e calendário mobile | Vence os campos editoriais no cliente quando a data está empacotada | O JSON declara `catalogue_version: 1`, mas `_load` não lê essa chave | 30 datas empacotadas de setembro de 2026 | Sim, somente para datas empacotadas | Uma correção exige alterar o asset e republicar um build (`mobile/assets/liturgy/gospel_catalogue.json::catalogue_version/entries`; `mobile/lib/src/services/bundled_gospel_catalogue.dart::BundledGospelCatalogue._load`; `mobile/lib/src/services/api_client.dart::ApiClient._applyBundledGospel`) |
| Cache local (`devotionals`) | `ApiClient`, depois da sobreposição online | Fallback offline do fluxo "hoje" | Não é autoridade editorial: guarda uma cópia derivada e sofre nova aplicação do bundle na leitura | Nenhuma versão de catálogo é armazenada ou comparada | Dinâmica, limitada às datas consultadas com sucesso | Sim | Pode ficar obsoleto; conteúdo concorrente é novamente substituído pelo bundle (`mobile/lib/src/services/api_client.dart::ApiClient.getTodayDevotional`; `mobile/lib/src/services/api_client.dart::ApiClient._getOfflineDevotionalFallback`; `mobile/lib/src/services/local_db_service.dart::LocalDbService.cacheDevotional`; `mobile/lib/src/services/local_db_service.dart::LocalDbService.getCachedDevotional`) |
| API / banco (`DevotionalModel`) | Seed, placeholder e CRUD administrativo | Endpoint `/devotional/today` e endpoints administrativos | Persistência dinâmica do backend, mas os campos editoriais podem perder no cliente para o bundle | Sem versão de catálogo no contrato observado | Dinâmica: pode conter qualquer data persistida, não se limita às sete do seed | Não por si só | Alterações válidas no banco podem não aparecer no mobile para datas empacotadas (`app/routes/devotional.py::get_today_devotional`; `app/services/devotional_service.py::DevotionalService.get_today_devotional`; `app/services/devotional_service.py::DevotionalService.create_devotional`; `app/services/devotional_service.py::DevotionalService.update_devotional`) |
| Seed (`INITIAL_GOSPEL_CATALOGUE`) | Inicialização do backend | Banco de dados | Insere, sem atualizar: para cada uma das sete datas, só grava quando a data ainda não existe | Sem versão explícita | Exatamente 7 entradas, de 1 a 7 de setembro de 2026 | N/A | Pode divergir das outras 23 datas empacotadas e preserva qualquer registro preexistente (`app/db/init_db.py::INITIAL_GOSPEL_CATALOGUE`; `app/db/init_db.py::seed_devotionals`; `app/db/init_db.py::init_db`) |
| Placeholder persistido | Serviço do backend | API e, indiretamente, cache/cliente | É criado e efetivamente persistido quando a data pedida não existe no banco | Sem versão | Dinâmica, uma nova linha por data ausente consultada | Não por si só | Pode parecer conteúdo definitivo no banco; para uma data empacotada, seus campos editoriais não chegam à tela (`app/services/devotional_service.py::DevotionalService._get_or_create_today_devotional`; `app/services/devotional_service.py::DevotionalService.get_today_devotional`) |
| CRUD administrativo | Administrador via cliente/API | Banco e leitura da API | Cria ou atualiza campos persistidos, sujeito à unicidade lógica por data no serviço | Sem versão | Dinâmica | Não | O fluxo Flutter atual envia apenas `title`, `content` e `date`; e, no fluxo "hoje", o bundle pode ocultar silenciosamente a edição (`mobile/lib/src/services/api_client.dart::ApiClient.createAdminDevotional`; `mobile/lib/src/services/api_client.dart::ApiClient.updateAdminDevotional`; `app/routes/devotional.py::create_devotional`; `app/routes/devotional.py::update_devotional`; `app/services/devotional_service.py::DevotionalService.create_devotional`; `app/services/devotional_service.py::DevotionalService.update_devotional`) |

## Fluxos atuais e precedência

### 1. Fluxo online

1. `getTodayDevotional` solicita `GET /devotional/today` sem enviar versão do catálogo (`mobile/lib/src/services/api_client.dart::ApiClient.getTodayDevotional`).
2. A rota resolve o usuário e chama o serviço (`app/routes/devotional.py::get_today_devotional`).
3. O serviço consulta o registro da data; se ausente, cria e persiste o placeholder. Também calcula `completed`, `is_favorited` e `guidance` por usuário (`app/services/devotional_service.py::DevotionalService.get_today_devotional`; `app/services/devotional_service.py::DevotionalService._get_or_create_today_devotional`).
4. O cliente decodifica a resposta e chama `_applyBundledGospel` (`mobile/lib/src/services/api_client.dart::ApiClient.getTodayDevotional`).
5. Havendo entrada para a data, o bundle vence em `title` (fixado como `Evangelho do dia`), `content`, `liturgicalTitle`, `gospelReference` e `sourceUrl`; a API/banco preserva `id`, `date`, `completed`, `isFavorited` e `guidance` (`mobile/lib/src/services/api_client.dart::ApiClient._applyBundledGospel`).
6. O objeto resultante, já sobreposto, é salvo no cache (`mobile/lib/src/services/api_client.dart::ApiClient.getTodayDevotional`; `mobile/lib/src/services/local_db_service.dart::LocalDbService.cacheDevotional`).

### 2. Fluxo de cache offline

1. Em `SocketException` ou timeout, `getTodayDevotional` delega ao fallback offline (`mobile/lib/src/services/api_client.dart::ApiClient.getTodayDevotional`; `mobile/lib/src/services/api_client.dart::ApiClient._getOfflineDevotionalFallback`).
2. O fallback consulta o cache pela chave composta de proprietário e data (`mobile/lib/src/services/local_db_service.dart::LocalDbService.getCachedDevotional`).
3. Se houver cache, o cliente chama `_applyBundledGospel` novamente, portanto o cache não é autoridade editorial (`mobile/lib/src/services/api_client.dart::ApiClient._getOfflineDevotionalFallback`).
4. Para data empacotada, o bundle volta a vencer `title`, `content`, `liturgicalTitle`, `gospelReference` e `sourceUrl`; o objeto em cache preserva `id`, `date`, `completed`, `isFavorited` e `guidance` (`mobile/lib/src/services/api_client.dart::ApiClient._applyBundledGospel`).

### 3. Fluxo de bundle offline sem cache

1. Sem registro no cache, o fallback procura a data diretamente no catálogo empacotado (`mobile/lib/src/services/api_client.dart::ApiClient._getOfflineDevotionalFallback`; `mobile/lib/src/services/bundled_gospel_catalogue.dart::BundledGospelCatalogue.findByDate`).
2. Se a data estiver empacotada, o bundle fornece `date`, `content`, `liturgicalTitle`, `gospelReference` e `sourceUrl`; o cliente cria `title` como `Evangelho do dia`, `id` como `0`, `completed` e `isFavorited` como `false` e uma `guidance` offline local (`mobile/lib/src/services/api_client.dart::ApiClient._getOfflineDevotionalFallback`).
3. Se a data não estiver no cache nem no bundle, o fluxo termina em erro; não há vencedor de campos (`mobile/lib/src/services/api_client.dart::ApiClient._getOfflineDevotionalFallback`).

### 4. Fluxo do calendário litúrgico

1. `GospelLibraryStore.loadMonth` inicializa o banco local e solicita o catálogo à fonte configurada, que por padrão é `BundledGospelCatalogSource` (`mobile/lib/src/services/gospel_store.dart::GospelLibraryStore.loadMonth`; `mobile/lib/src/services/gospel_store.dart::GospelLibraryStore`).
2. `BundledGospelCatalogSource.load` converte todas as entradas de `BundledGospelCatalogue` e atribui a versão literal `'1'`; ela não obtém esse valor de `catalogue_version` (`mobile/lib/src/services/gospel_store.dart::BundledGospelCatalogSource.load`; `mobile/lib/src/services/bundled_gospel_catalogue.dart::BundledGospelCatalogue.loadAll`).
3. O store filtra as entradas pelo prefixo do mês e combina somente estado pessoal local (`isFavorite` e `note`). Para os campos editoriais `date`, `title`, `reference`, `text` e `sourceUrl`, o bundle é o único vencedor; API, banco, seed, placeholder e cache devocional não participam (`mobile/lib/src/services/gospel_store.dart::GospelLibraryStore.loadMonth`).

### 5. Fluxo de seed

1. `init_db` cria tabelas, trata colunas legadas e chama `seed_devotionals` (`app/db/init_db.py::init_db`).
2. `seed_devotionals` percorre exatamente as sete entradas de `INITIAL_GOSPEL_CATALOGUE` (`app/db/init_db.py::INITIAL_GOSPEL_CATALOGUE`; `app/db/init_db.py::seed_devotionals`).
3. Para cada data, um registro existente vence integralmente e nada é alterado; somente uma data ausente recebe `title`, `content`, `date`, `liturgical_title`, `gospel_reference` e `source_url` do seed (`app/db/init_db.py::seed_devotionals`).
4. A cobertura do banco continua dinâmica: CRUD e placeholders podem adicionar outras datas, portanto "sete" descreve apenas a carga inicial, não um limite da API/banco (`app/services/devotional_service.py::DevotionalService.create_devotional`; `app/services/devotional_service.py::DevotionalService._get_or_create_today_devotional`).

### 6. Fluxo CRUD administrativo

1. O cliente administrativo cria ou atualiza enviando `title`, `content` e `date` (`mobile/lib/src/services/api_client.dart::ApiClient.createAdminDevotional`; `mobile/lib/src/services/api_client.dart::ApiClient.updateAdminDevotional`).
2. As rotas protegidas delegam a criação ou atualização ao serviço; o contrato backend também admite `liturgical_title`, `gospel_reference` e `source_url` (`app/routes/devotional.py::create_devotional`; `app/routes/devotional.py::update_devotional`).
3. O serviço persiste os campos recebidos; em criação ou mudança de data, um registro já existente para a data impede a operação (`app/services/devotional_service.py::DevotionalService.create_devotional`; `app/services/devotional_service.py::DevotionalService.update_devotional`).
4. Na leitura administrativa e no banco, os valores persistidos pelo CRUD vencem. Já no fluxo "hoje" para uma data empacotada, o bundle vence `title`, `content`, `liturgicalTitle`, `gospelReference` e `sourceUrl`, enquanto API/banco preservam `id`, `date`, `completed`, `isFavorited` e `guidance` (`app/routes/devotional.py::list_devotionals`; `mobile/lib/src/services/api_client.dart::ApiClient._applyBundledGospel`).

## Constatações transversais

- O bundle contém 30 entradas, enquanto `INITIAL_GOSPEL_CATALOGUE` contém 7; essa comparação não implica que a API/banco tenha cobertura fixa, pois o banco aceita datas criadas por CRUD e persiste placeholders (`mobile/assets/liturgy/gospel_catalogue.json::entries`; `app/db/init_db.py::INITIAL_GOSPEL_CATALOGUE`; `app/services/devotional_service.py::DevotionalService.create_devotional`; `app/services/devotional_service.py::DevotionalService._get_or_create_today_devotional`).
- `BundledGospelCatalogue._load` lê `source` e `entries`, mas não lê `catalogue_version` (`mobile/lib/src/services/bundled_gospel_catalogue.dart::BundledGospelCatalogue._load`; `mobile/assets/liturgy/gospel_catalogue.json::catalogue_version`).
- `BundledGospelCatalogSource.load` publica a versão literal `'1'`, sem derivá-la do JSON (`mobile/lib/src/services/gospel_store.dart::BundledGospelCatalogSource.load`).
- `getTodayDevotional` não envia versão em header, query ou corpo, de modo que a versão não atravessa o fluxo até o backend (`mobile/lib/src/services/api_client.dart::ApiClient.getTodayDevotional`; `app/routes/devotional.py::get_today_devotional`).
- Não há negociação de versão nem invalidação editorial do cache nos símbolos examinados; o cache guarda o resultado do fluxo online e o bundle é reaplicado no fallback (`mobile/lib/src/services/api_client.dart::ApiClient.getTodayDevotional`; `mobile/lib/src/services/api_client.dart::ApiClient._getOfflineDevotionalFallback`; `mobile/lib/src/services/local_db_service.dart::LocalDbService.cacheDevotional`; `mobile/lib/src/services/local_db_service.dart::LocalDbService.getCachedDevotional`).

## Alternativas de arquitetura pendentes de decisão

As três alternativas permanecem Undecided. A tabela usa os mesmos sete critérios para todas e não expressa aceitação ou recomendação.

| Critério | Backend (API first) | Bundle estático (offline first) | Sincronização híbrida com catálogo versionado |
| --- | --- | --- | --- |
| Offline | Exige prefetch/cache suficiente para as datas necessárias | Disponível apenas para as datas empacotadas no build instalado | Usa o último catálogo baixado e validado |
| Atualização editorial | Pode ser disponibilizada pela API sem novo build | Exige alterar o asset e publicar novo build | Exige publicar e baixar uma nova versão de catálogo |
| Consistência | Depende de contrato e política de invalidação do cache | Determinística dentro de um mesmo build, mas builds distintos podem divergir | Depende de aplicação atômica e identificação de versão |
| Rollback | Requer restaurar dados/versão no backend e tratar caches | Requer republicação de um build com o catálogo anterior ou corrigido | Requer manter e reapontar uma versão anterior compatível |
| Compatibilidade com CRUD | Direta, se o backend for a leitura efetiva | CRUD não altera o catálogo empacotado | CRUD precisa alimentar um processo explícito de publicação de catálogo |
| Licenciamento | Validação antes de persistir e servir conteúdo | Validação antes de empacotar e publicar o build | Validação antes de publicar cada versão de catálogo |
| Complexidade operacional | Operação da API, disponibilidade, cache e auditoria editorial | Pipeline de asset/build/lojas e suporte a versões antigas | Versionamento, download, validação, migração, rollback e observabilidade |

Decisão: Undecided. Nenhuma alternativa está aprovada ou recomendada.

## Gates humanos bloqueantes

- **Licença de texto bíblico:** qualquer inclusão de texto protegido exige comprovação de licença; o comentário do loader declara que o bundle atual contém citações e reflexão, não o texto bíblico oficial (`mobile/lib/src/services/bundled_gospel_catalogue.dart::BundledGospelCatalogue`).
- **Revisão editorial:** a revisão editorial humana de referências, reflexões, títulos e fontes é obrigatória antes de publicação; nenhum mecanismo técnico observado substitui essa aprovação (`mobile/assets/liturgy/gospel_catalogue.json::entries`; `app/db/init_db.py::INITIAL_GOSPEL_CATALOGUE`).
- **Novos meses:** a cobertura atual empacotada se limita a setembro de 2026; o processo e a responsabilidade por adicionar meses ainda precisam de decisão humana (`mobile/assets/liturgy/gospel_catalogue.json::entries`).
- **Aprovação da fonte canônica:** a escolha entre as alternativas e as regras de conflito dependem de decisão humana; este ADR permanece Proposed / Undecided.

## Tarefas posteriores propostas

1. **Decisão:** escolher formalmente a fonte canônica, a autoridade editorial e a precedência de campos.
2. **Contrato e versionamento:** definir como uma versão real de catálogo é produzida, transmitida, validada e observada pelo Flutter e pelo backend.
3. **Sincronização e migração:** planejar cache, invalidação, dados existentes, placeholders, rollback e remoção da substituição silenciosa conforme a decisão.
4. **Testes:** cobrir separadamente online, cache offline, bundle offline, calendário, seed, placeholder e CRUD, incluindo conflitos por campo e por versão.
