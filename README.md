# 📱 App Devocional

> Uma plataforma moderna para desenvolvimento espiritual diário, focada em ajudar o usuário a construir e manter o hábito da leitura diária através de gamificação inteligente e lembretes eficientes.

---

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/FastAPI-0.100.0+-009688?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI" />
  <img src="https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python" />
  <img src="https://img.shields.io/badge/SQLite-3.x-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/Windows-Supported-0078D4?style=for-the-badge&logo=windows&logoColor=white" alt="Windows" />
</p>

---

## 🧭 Sumário

- [🔍 Visão Geral](#-visão-geral)
- [🏗️ Arquitetura do Sistema](#%EF%B8%8F-arquitetura-do-sistema)
- [📁 Estrutura do Repositório](#-estrutura-do-repositório)
- [⚡ Backend (FastAPI)](#-backend-fastapi)
  - [Endpoints da API](#endpoints-da-api)
  - [Como Executar o Backend](#como-executar-o-backend)
  - [Como Rodar Testes](#como-rodar-testes)
- [📱 Mobile (Flutter)](#-mobile-flutter)
  - [Como Executar o Mobile](#como-executar-o-mobile)
- [🎯 Loop de Engajamento & Regra de Streak](#-loop-de-engajamento--regra-de-streak)
- [📈 Roadmap de Desenvolvimento](#-roadmap-de-desenvolvimento)
- [🔗 Documentos Úteis](#-documentos-úteis)

---

## 🔍 Visão Geral

Este repositório contém o código-fonte completo do **App Devocional**, dividido em dois módulos principais:
1. **Backend**: API RESTful de alta performance construída em **FastAPI** e banco de dados relacional **SQLite** com **SQLAlchemy**.
2. **Mobile**: Aplicativo mobile multiplataforma construído com **Flutter**, apresentando onboarding dinâmico, fluxo de lembretes offline, estatísticas e gerenciamento completo.

---

## 🏗️ Arquitetura do Sistema

O fluxo de comunicação e a arquitetura geral do sistema estão estruturados da seguinte forma:

```mermaid
graph TD
    subgraph Cliente [Front-end Mobile (Flutter)]
        App[App Shell]
        Auth[Autenticação & Onboarding]
        DevReader[Leitor de Devocionais]
        ProgTab[Histórico & Streaks]
        AdminPanel[Painel Admin Flutter]
    end

    subgraph Servidor [Back-end API (FastAPI)]
        Router[Router Principal / API]
        AuthSvc[Serviço de Autenticação]
        StreakSvc[Motor de Streaks]
        NotifSvc[Agendador de Notificações]
        AdminSvc[Gerenciador de Conteúdo]
    end

    subgraph Persistencia [Banco de Dados]
        DB[(devotional.db SQLite)]
    end

    App -->|HTTP/REST com JSON| Router
    Router --> AuthSvc
    Router --> StreakSvc
    Router --> NotifSvc
    Router --> AdminSvc
    
    AuthSvc --> DB
    StreakSvc --> DB
    NotifSvc --> DB
    AdminSvc --> DB
```

---

## 📁 Estrutura do Repositório

```text
app_devocional/
├── app/                  # Código-fonte da API Backend (FastAPI)
│   ├── api/              # Configurações de API e middlewares
│   ├── core/             # Configurações de sistema e segurança
│   ├── db/               # Sessão e engine do banco de dados (SQLAlchemy)
│   ├── models/           # Modelos de dados do ORM
│   ├── routes/           # Rotas divididas por módulos (auth, devotional, etc.)
│   └── services/         # Lógica de negócios central (streaks, notificações)
├── docs/                 # Documentação e Roadmap estratégico do produto
├── mobile/               # Projeto do aplicativo multiplataforma (Flutter)
│   ├── lib/              # Código Dart estruturado em features e services
│   └── test/             # Testes de widgets e unitários do Flutter
├── tests/                # Testes de integração e unitários do backend (Pytest)
├── make_admin.py         # Script utilitário para promover usuários para administrador
└── requirements.txt      # Dependências de bibliotecas Python
```

---

## ⚡ Backend (FastAPI)

O backend do projeto gerencia a lógica de autenticação (JWT), regras de negócio de streaks consecutivas, persistência de preferências de notificações de lembrete diário e fornece painéis administrativos.

### Endpoints da API

A tabela abaixo detalha todas as rotas e regras de autorização atuais:

| Método | Endpoint | Autenticação | Acesso Admin | Descrição |
| :--- | :--- | :---: | :---: | :--- |
| `POST` | `/auth/register` | ❌ | ❌ | Cadastra um novo usuário e retorna o token de acesso. |
| `POST` | `/auth/login` | ❌ | ❌ | Autentica o usuário e retorna o token JWT de acesso. |
| `GET` | `/auth/me` | 🔒 Bearer | ❌ | Retorna os detalhes do perfil do usuário autenticado. |
| `GET` | `/devotional/today` | 🔒 Bearer | ❌ | Obtém o devocional disponível para o dia atual. |
| `POST` | `/devotional/complete` | 🔒 Bearer | ❌ | Marca o devocional de hoje como lido e atualiza o streak. |
| `GET` | `/devotional/admin` | 🔒 Bearer |  Admin | Lista todos os devocionais (para fins administrativos). |
| `POST` | `/devotional/admin` | 🔒 Bearer |  Admin | Cria um novo devocional. |
| `PUT` | `/devotional/admin/{id}` | 🔒 Bearer |  Admin | Atualiza um devocional existente pelo ID. |
| `DELETE` | `/devotional/admin/{id}` | 🔒 Bearer |  Admin | Exclui um devocional específico pelo ID. |
| `GET` | `/notifications/settings` | 🔒 Bearer | ❌ | Recupera as preferências de notificação do usuário. |
| `PUT` | `/notifications/settings` | 🔒 Bearer | ❌ | Atualiza as configurações de horário e timezone de notificação. |
| `GET` | `/notifications/admin/due` | 🔒 Bearer |  Admin | Consulta notificações pendentes de envio. |
| `POST` | `/notifications/admin/dispatch` | 🔒 Bearer |  Admin | Dispara o envio em lote das notificações agendadas. |
| `GET` | `/notifications/admin/deliveries` | 🔒 Bearer |  Admin | Exibe o histórico de entregas de notificações. |
| `POST` | `/notifications/admin/{user_id}/mark-sent` | 🔒 Bearer |  Admin | Registra o envio manual de notificação para um usuário específico. |
| `GET` | `/streak` | 🔒 Bearer | ❌ | Retorna o status de streak atual e recorde do usuário. |
| `GET` | `/progress` | 🔒 Bearer | ❌ | Retorna o histórico de leitura mensal e dias concluídos. |
| `GET` | `/health` | ❌ | ❌ | Endpoint simples de monitoramento e integridade do serviço. |

### Como Executar o Backend

1. **Clone o repositório** e entre no diretório raiz.
2. **Crie e ative um ambiente virtual** do Python:
   ```bash
   python -m venv .venv
   # No Windows (PowerShell):
   .venv\Scripts\Activate.ps1
   # No macOS/Linux:
   source .venv/bin/activate
   ```
3. **Instale as dependências**:
   ```bash
   pip install -r requirements.txt
   ```
4. **Execute o servidor de desenvolvimento** via Uvicorn:
   ```bash
   python -m uvicorn app.main:app --reload
   ```
5. **Acesse a documentação interativa**:
   - Swagger UI: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
   - Redoc: [http://127.0.0.1:8000/redoc](http://127.0.0.1:8000/redoc)

### Como Rodar Testes

Nós utilizamos o [pytest](https://pytest.org/) para a cobertura de testes de integração e unitários do backend.
```bash
python -m pytest -q
```

---

## 📱 Mobile (Flutter)

O aplicativo mobile é construído em Flutter e projetado para funcionar perfeitamente de forma responsiva. Ele contém recursos de onboarding interativo, painéis gráficos de conquistas diárias e uma área dedicada a administradores.

> [!NOTE]
> Por padrão, o aplicativo aponta para `http://10.0.2.2:8000` (resolução nativa para o emulador Android apontar para a máquina local). 
> Se você estiver rodando em plataformas desktop, web, ou simulador de iOS, pode definir a variável de ambiente durante a execução ou alterar o arquivo de serviço correspondente.

### Como Executar o Mobile

1. Navegue para a pasta `mobile/`:
   ```bash
   cd mobile
   ```
2. Crie ou atualize as plataformas necessárias:
   ```bash
   flutter create --platforms=windows,web .
   ```
3. Instale os pacotes e dependências do Pubspec:
   ```bash
   flutter pub get
   ```
4. Execute o aplicativo passando o host da API local:
   
   **No Windows**:
   ```bash
   flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:8000
   ```

   **No Navegador (Web)**:
   ```bash
   flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
   ```

   **No Emulador Android**:
   ```bash
   flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8000
   ```

---

## 🎯 Loop de Engajamento & Regra de Streak

O sucesso do aplicativo é mensurado com base no retorno constante do usuário. O loop de engajamento principal consiste em:
1. **Notificação diária**: O usuário recebe o alerta em seu horário preferido.
2. **Leitura**: Abertura do app e leitura do devocional diário.
3. **Conclusão**: O usuário marca o devocional como lido.
4. **Gratificação**: A contagem de streak do usuário incrementa e conquistas visuais são liberadas.

### Algoritmo de Validação do Streak

A lógica de cálculo de consistência diária funciona com base na última atividade realizada:
* Se o usuário conclui o devocional **hoje** e a última atividade foi **ontem**, o streak incrementa em 1 dia.
* Se a última atividade foi **hoje**, o streak permanece inalterado.
* Se a última atividade ocorreu há **mais de 1 dia**, o streak é resetado e recomeça em 1 dia.

---

## 📈 Roadmap de Desenvolvimento

- [x] **Fase 1: MVP Core (Foco em Retenção)**
  - Sistema de login e cadastro.
  - Exibição de devocionais e marcação de leitura diária.
  - Lógica e exibição de streaks consecutivas.
  - Tela de progresso mensal básica e histórico.
- [ ] **Fase 2: Gamificação e Refinamentos**
  - Marcos e badges de conquistas (ex: 7 dias, 30 dias de leitura).
  - Animações e feedbacks sonoros na marcação de dia concluído.
  - Notificações locais agendadas mais robustas.
- [ ] **Fase 3: Monetização e Freemium**
  - Implementação de anúncios controlados.
  - Plano Premium com devocionais exclusivos e histórico expandido.
  - Configuração de assinaturas in-app.
- [ ] **Fase 4: Expansão de Conteúdo**
  - Player de áudio para escutar o devocional diário.
  - Sistema de anotações pessoais ligadas a cada dia de leitura.

---

## 🔗 Documentos Úteis

* [Documentação do Roadmap de Produto](file:///c:/Users/wand/Desktop/projetos_pessoais/app_devocional/docs/product-roadmap.md) - Visão estratégica detalhada, escopo inicial e regras de negócio.
* [Documentação do Módulo Mobile](file:///c:/Users/wand/Desktop/projetos_pessoais/app_devocional/mobile/README.md) - Passo a passo aprofundado, instruções de deploy e troubleshooting específicos do app Flutter.
