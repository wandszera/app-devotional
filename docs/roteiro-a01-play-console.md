# Roteiro A01 — Conta Google Play Console (01/12/2026) — RASCUNHO

Não é aconselhamento jurídico/fiscal. Conferir telas e exigências no dia: o Play Console muda com frequência.
Depende de: D03 (conta pessoal x organização). Nome do app (D01) e applicationId (A02) só são necessários no passo 6.

## Antes de começar (separar)
- Conta Google que será dona do app (se D03 = pessoal, usar a conta pessoal definitiva; não dá para transferir facilmente depois).
- Cartão com pagamento internacional (taxa única de US$ 25).
- Documento oficial com foto e comprovante de endereço compatível com o cadastro.
- Celular Android com a conta (a verificação pode pedir app do Play Console / confirmação no aparelho).
- Telefone e e-mail de contato (o e-mail de contato pode ser exibido na loja — usar o de suporte de D06).
- Se D03 = organização: número D-U-N-S, CNPJ e site da organização (processo mais longo; não recomendado para o beta).

## Passo a passo
1. Acessar play.google.com/console e entrar com a conta definida.
2. Escolher o tipo de conta: **Pessoal** ou **Organização** (D03). Não dá para trocar depois.
3. Preencher nome do desenvolvedor (aparece na loja), endereço, telefone e e-mail de contato. Verificar o e-mail e o telefone por código.
4. Aceitar o Contrato de Distribuição para Desenvolvedores e pagar a taxa única de US$ 25.
5. Enviar a verificação de identidade (documento + endereço). Pode levar dias; o app só pode ser publicado após aprovação. Acompanhar o e-mail e a página inicial do Console.
6. Quando a conta for aprovada **e** D01 + A02 estiverem fechados: "Criar app" → nome, idioma padrão pt-BR, app (não jogo), gratuito, aceitar declarações.
7. Completar "Configurar o app": acesso ao app (conta de teste p/ revisor), anúncios (não), classificação de conteúdo, público-alvo (13+/adultos), segurança dos dados, categoria, contatos e URL de privacidade/exclusão — usar `docs/ficha-loja-play.md`.
8. Se conta pessoal nova: o Play exige teste fechado com **12 testadores por 14 dias seguidos** antes de pedir produção. Plano: 05–19/01 (B02, ver `docs/recrutamento-b02.md`).
9. Criar faixa de teste fechado, subir o AAB assinado (keystore de produção), adicionar o Grupo do Google dos testadores e copiar o link de adesão.

## Armadilhas
- applicationId não muda após publicar: só criar o app no Console depois de A02.
- Guardar o keystore e as senhas em local seguro com cópia; perder a chave de upload complica atualizações.
- Usar o mesmo e-mail de contato em D06, na ficha e na política de privacidade.
- Testadores precisam aceitar o convite e manter o app instalado os 14 dias.

## Checklist de 01/12
- [ ] D03 definido · [ ] conta criada · [ ] taxa paga · [ ] verificação enviada · [ ] data prevista de aprovação anotada
- [ ] B02: mensagens enviadas (`recrutamento-b02.md`) · [ ] P01/P02 em andamento
