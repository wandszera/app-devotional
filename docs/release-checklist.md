# Checklist de prontidão do app

Este arquivo acompanha apenas trabalho confirmado no código ou por uma validação registrada. Atualize o estado ao concluir cada fase.

Legenda: `[x]` concluído · `[-]` em andamento · `[ ]` pendente · `[!]` depende de configuração externa

## Concluído

- [x] Estrutura Flutter e API FastAPI para autenticação, devocional diário, progresso e administração.
- [x] Catálogo local de setembro de 2026 com 30 datas, referências do Evangelho, celebrações e reflexões breves.
- [x] Espaço local para homilia e anotação pessoal no leitor.
- [x] Cache local para conteúdo, progresso e constância.
- [x] Fluxo de leitura concluída offline com tentativa de sincronização posterior.

## Em andamento

- [-] Integrar Calendário Litúrgico e biblioteca de Orações à versão principal.
- [-] Usar o catálogo de setembro como fonte única também para o Calendário.
- [-] Preservar registros de leitura offline até a sincronização, mesmo depois da virada do dia.
- [-] Adicionar testes de integração para calendário, catálogo e sincronização offline.

## Pendente para o produto ficar pronto

- [ ] Revisão editorial das referências, celebrações e reflexões de setembro.
- [ ] Definir fonte licenciada ou autorização para mostrar texto bíblico completo dentro do app.
- [ ] Processo editorial para publicar os meses seguintes.
- [ ] Ajustes de acessibilidade: tamanho de texto, leitura por tela e contraste.
- [ ] Teste completo em Android: instalação limpa, login, leitura, anotação, favorito, conclusão, reinício e modo avião.
- [ ] Recuperação de acesso, exclusão de conta e informações de privacidade.
- [ ] Identidade definitiva do Android, assinatura de produção e versão de lançamento.
- [ ] Publicar e monitorar o backend de produção.

## Depende de configuração externa

- [!] Login Google: concluir a configuração do Firebase, clientes OAuth e credenciais do servidor.
- [!] Lembretes reais no Android/iOS: configurar SDK nativo, permissão, token do dispositivo e serviço de envio.
- [!] Publicação na loja: conta de desenvolvedor, política de privacidade, materiais gráficos e revisão da loja.
