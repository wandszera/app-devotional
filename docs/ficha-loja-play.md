# Ficha da loja (Google Play) — checklist A02 — RASCUNHO

Nome provisório (D01): **Semente – Catequese Diária**. Trocar tudo abaixo se D01 mudar.
Não é aconselhamento jurídico; conferir com as políticas vigentes do Play Console no dia do envio.

## 1. Textos (limites do Play)
| Campo | Limite | Rascunho |
|---|---|---|
| Nome do app | 30 | Semente – Catequese Diária (26) |
| Descrição curta | 80 | Evangelho do dia, reflexão curta e lembrete diário para criar o hábito de rezar. (80) |
| Descrição completa | 4000 | ver modelo abaixo |

### Descrição completa (modelo)
Semente é um companheiro diário de catequese: todos os dias, a referência do Evangelho, uma reflexão breve e
um espaço para suas anotações.

- Evangelho do dia e celebração litúrgica
- Reflexão curta para ler em poucos minutos
- Anotações pessoais e favoritos
- Sequência de dias (constância) para criar o hábito
- Lembrete diário no horário que você escolher
- Funciona offline depois de carregado
- Você pode excluir sua conta e seus dados a qualquer momento

Cuidados de texto: não afirmar "oficial" CNBB/Vaticano nem usar imagens/marcas de terceiros; só prometer
"texto bíblico completo" se a licença estiver resolvida (pendência no release-checklist).

## 2. Materiais gráficos
| Item | Especificação |
|---|---|
| Ícone | 512x512 PNG, até 1 MB, sem cantos arredondados (o Play arredonda) |
| Imagem de destaque | 1024x500 PNG/JPG |
| Capturas de celular | mín. 2, máx. 8; lado menor ≥ 320 px, proporção até 2:1 (sugestão 1080x1920) |
| Telas sugeridas | 1 Devocional do dia · 2 Leitor + anotação · 3 Calendário litúrgico · 4 Orações · 5 Sequência/progresso · 6 Lembretes |
Gerar as capturas com conteúdo real (não dados de teste) e sem e-mails reais visíveis.

## 3. Classificação de conteúdo (questionário IARC)
Respostas esperadas: sem violência, sem conteúdo sexual, sem linguagem imprópria, sem drogas, sem jogos de azar,
sem compras no app, sem conteúdo gerado por usuário visível a outros, sem compartilhamento de localização.
Categoria: referência/estilo de vida. Mencionar conteúdo religioso quando perguntado. Resultado esperado: Livre/Todos.
Público-alvo: 13+ ou adultos (consistente com `docs/privacidade.md` §8). Não marcar "voltado a crianças".

## 4. Segurança dos dados (Data safety) — a partir de `docs/privacidade.md`
| Tipo | Coletado | Compartilhado | Finalidade | Opcional |
|---|---|---|---|---|
| E-mail | Sim | Não (só operadores) | Conta/autenticação | Não |
| Nome / bio | Sim | Não | Perfil | Sim |
| IDs (uid Firebase, token FCM) | Sim | Não | Login Google, notificações | Parcial |
| Atividade no app (progresso, favoritos, streak) | Sim | Não | Funcionalidade | Não |
| Localização, contatos, fotos, pagamentos | Não | — | — | — |
Declarações: dados criptografados em trânsito (HTTPS) = Sim · usuário pode pedir exclusão = Sim (no app e URL web) ·
sem anúncios · sem venda de dados.

## 5. Campos de política e contato
- URL da política de privacidade (D06) · URL de exclusão de conta (D06) · e-mail de suporte (D06).
- Declaração de acesso ao app: se houver login, fornecer conta de teste para o revisor.
- Declaração de anúncios: Não. Categoria: Estilo de vida (ou Livros e referências). País/idioma padrão: pt-BR.
- Permissões: notificações (Android 13+), internet. Justificar no formulário.

## 6. Pendências que bloqueiam o envio
D01 nome · D03 responsável · D06 domínio/e-mail · A02 applicationId · licença do texto bíblico · assinatura de produção (keystore).

## Próxima etapa preparada (a partir de 24/11)
Se D01/D03/D06 forem decididos: rodar `scripts/gen_site.py`, trocar placeholders e fechar esta ficha. Sem decisão: preparar o
plano de capturas (roteiro de telas e dados de demonstração) e o texto da mensagem de recrutamento (B02).
