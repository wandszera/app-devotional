# App Flutter

Base inicial do app mobile em Flutter para consumir a API do projeto.

## Estrutura inicial

- autenticacao com login e cadastro
- autenticacao com validacao de formulario e controle de senha visivel
- onboarding inicial para apresentar habito, streak e lembretes
- etapa guiada pos-onboarding para configurar o lembrete diario
- sugestoes rapidas de horario no setup inicial de lembretes
- home com devocional do dia
- home com saudacao contextual e missao diaria
- tela dedicada de leitura do devocional
- streak atual e melhor streak
- feedback visual de milestones de streak
- progresso com grade mensal e historico detalhado
- ajustes de notificacao
- area admin para CRUD de devocionais
- area admin para dispatch e historico de notificacoes
- seletores visuais de data e horario nos formularios principais

## API

Por padrao, o app aponta para `http://10.0.2.2:8000`, que funciona no emulador Android apontando para o backend local.

Se voce for usar dispositivo fisico ou iOS Simulator, ajuste `baseUrl` em [api_client.dart](/C:/Users/wand/Desktop/projetos_pessoais/app_devocional/mobile/lib/src/services/api_client.dart).

Voce tambem pode definir a URL na execucao:

`flutter run --dart-define=API_BASE_URL=http://SEU_IP:8000`

## Lembretes sem SDK

Nesta etapa o app ficou sem integracao de SDK nativo para push.

Hoje o comportamento fica assim:

- o app salva `enabled`, `reminder_time` e `timezone` no backend
- a interface deixa claro que ainda nao existe permissao/token nativo no dispositivo
- `android`, `ios`, `web` e `windows` seguem funcionando sem Firebase

Isso deixa o fluxo principal do produto validavel agora, sem depender de `firebase_messaging`, `flutterfire configure` ou arquivos nativos extras.

## Como rodar localmente

No ambiente desta conversa, os comandos do Flutter ficaram presos mais de uma vez. O fluxo abaixo e o caminho mais seguro para rodar na sua maquina.

### 1. Feche processos presos do Flutter antes de comecar

No PowerShell:

```powershell
Get-Process | Where-Object { $_.ProcessName -match 'flutter|dart' } | Stop-Process -Force
```

### 2. Entre na pasta mobile

```powershell
cd C:\Users\wand\Desktop\projetos_pessoais\app_devocional\mobile
```

### 3. Gere a estrutura nativa do Flutter

Se o `flutter` estiver no `PATH`:

```powershell
flutter create --platforms=windows,web .
```

Se nao estiver no `PATH`, use o caminho direto:

```powershell
C:\flutter\bin\flutter.bat create --platforms=windows,web .
```

Se esse comando passar de 10 a 15 minutos sem saida nova, interrompa com `Ctrl + C`, finalize processos presos novamente e tente mais uma vez.

### 4. Baixe as dependencias

```powershell
flutter pub get
```

Ou:

```powershell
C:\flutter\bin\flutter.bat pub get
```

### 5. Analise o projeto

```powershell
flutter analyze
```

### 6. Rode no Windows

```powershell
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

### 7. Rode no Chrome

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

### 8. Para emulador Android

Quando o Android SDK estiver configurado:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## Troubleshooting rapido

### `flutter` nao reconhecido

Use diretamente:

```powershell
C:\flutter\bin\flutter.bat
```

### `create` demora demais

- finalize processos `flutter` e `dart`
- tente rodar `flutter doctor -v`
- depois rode `flutter create ...` sozinho
- nao rode `create` e `pub get` ao mesmo tempo

### Android nao configurado

Hoje isso nao bloqueia `windows` nem `chrome`. Voce pode continuar validando o app nessas plataformas.

### Backend local

Suba a API antes de rodar o app:

```powershell
cd C:\Users\wand\Desktop\projetos_pessoais\app_devocional
python -m uvicorn app.main:app --reload
```

## Observacoes sobre a base atual

- o app ja tem login e cadastro
- o app ja consome devocional do dia, streak, progresso e notificacoes
- o app ja possui aba admin para CRUD de devocionais quando o usuario autenticado for admin
- a URL da API pode ser trocada com `--dart-define=API_BASE_URL=...`
