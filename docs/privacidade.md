# Política de Privacidade — RASCUNHO (Q01/Q02/P03/P04)

> Rascunho técnico, **não é aconselhamento jurídico**. Revisar à luz da LGPD antes de publicar.
> Placeholders pendentes: `[NOME DO APP]` (D01), `[DOMÍNIO]` e `[EMAIL DE SUPORTE]` (D06), `[RESPONSÁVEL]` (nome/razão social, D03).
> Publicar em URL pública (ex.: `https://[DOMÍNIO]/privacidade`) e informar a URL no Play Console.

Última atualização: [DATA]

## 1. Quem somos
O `[NOME DO APP]` é um aplicativo de devocional diário católico mantido por `[RESPONSÁVEL]`. Contato para
privacidade: `[EMAIL DE SUPORTE]`.

## 2. Dados que coletamos
| Dado | Para quê | Quando |
|---|---|---|
| E-mail | Criar e acessar a conta | Cadastro / login |
| Senha (guardada só como hash, nunca em texto) | Autenticação | Cadastro por e-mail |
| Nome e bio (opcionais) | Perfil | Se você preencher |
| Identificador Google/Firebase (uid) | Login com Google | Login com Google |
| Progresso de leitura, sequência (streak) e favoritos | Funcionalidades do app | Uso do app |
| Fuso horário e horário do lembrete | Enviar o lembrete na hora certa | Ao configurar lembretes |
| Token de notificação (FCM) | Enviar notificações push | Ao ativar lembretes |
| Histórico de envio de lembretes | Evitar duplicidade e diagnosticar falhas | Automático |

Não coletamos localização, contatos, fotos, nem dados de pagamento no app. Não vendemos nem compartilhamos dados
pessoais para publicidade.

## 3. Com quem compartilhamos
- **Google Firebase** (login com Google e notificações push — Firebase Cloud Messaging), como operador.
- **Provedor de hospedagem** do servidor/banco de dados (`[PROVEDOR — D02]`), como operador.
Não há anúncios nem SDKs de rastreamento de terceiros. [Confirmar após definir D07/analytics.]

## 4. Base legal e finalidade (LGPD)
Execução do serviço contratado (conta, progresso, lembretes) e consentimento para notificações push, que
pode ser retirado a qualquer momento nas configurações do app ou do sistema.

## 5. Segurança
Comunicação por HTTPS; senhas com hash; tokens de sessão com expiração e rotação.

## 6. Retenção e exclusão
Mantemos os dados enquanto a conta existir. Você pode **excluir a conta e todos os dados associados**:
- No app: Perfil → Excluir conta (confirma com a senha ou novo login Google).
- Pela web: `https://[DOMÍNIO]/excluir-conta` ou e-mail para `[EMAIL DE SUPORTE]`.
A exclusão remove e-mail, perfil, progresso, favoritos, lembretes, token de notificação e sessões, de forma
imediata no banco principal. Cópias de segurança são descartadas em até `[N]` dias. [Definir com D02.]

## 7. Seus direitos (LGPD, art. 18)
Confirmação e acesso, correção, anonimização/eliminação, portabilidade, informação sobre compartilhamento e
revogação de consentimento: peça por `[EMAIL DE SUPORTE]`.

## 8. Crianças
O app não é direcionado a menores de 13 anos. [Ajustar conforme classificação etária no Play Console.]

## 9. Alterações
Mudanças relevantes serão avisadas no app. A data acima indica a versão vigente.

---

# Página web de exclusão de conta (rascunho)
Título: "Excluir minha conta — `[NOME DO APP]`"
1. Abra o app → Perfil → Excluir conta, e confirme; ou
2. Envie e-mail a `[EMAIL DE SUPORTE]` a partir do e-mail cadastrado com o assunto "Excluir conta". Respondemos em
   até 15 dias; a exclusão remove: e-mail, perfil, progresso, favoritos, lembretes, token de notificação, sessões.

# Data safety (Play Console) — respostas sugeridas
- Coleta: E-mail; IDs de usuário (uid Firebase/ID interno); IDs de dispositivo (token FCM); atividade no app (progresso/favoritos).
- Compartilhamento com terceiros: nenhum para fins de publicidade; Firebase/hospedagem como operadores (processamento em nome do app).
- Criptografia em trânsito: sim (HTTPS — depende de P02). Exclusão de dados: o usuário pode solicitar (in-app + URL web).
