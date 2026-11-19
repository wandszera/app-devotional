# Checklist de submissão do teste fechado (alvo 03/12)

Contexto Play: contas pessoais novas exigem teste fechado com testadores optados antes da produção (ver B02 recrutamento).

## Antes do upload
- [ ] D01 nome, D03 responsável, D06 domínio/e-mail decididos; A02 applicationId final aplicado
- [ ] Conta Play Console paga (A01, US$ 25) e identidade verificada
- [ ] Keystore de upload criado e AAB assinado (docs/roteiro-assinatura-aab.md)
- [ ] Backend de produção no ar com HTTPS (P01/P02); `alembic upgrade head` validado em Postgres vazio
- [ ] URL do backend de produção configurada no app release
- [ ] Licença/autorização do texto bíblico resolvida (ou texto só com referência)
- [ ] Política de privacidade publicada em URL pública (docs/privacidade.md → site)
- [ ] Página pública de exclusão de conta publicada (Q02)
- [ ] Exclusão de conta dentro do app testada (Q01)

## No Play Console
- [ ] Ficha da loja (docs/ficha-loja-play.md) + ícone 512, gráfico 1024x500, capturas (docs/plano-capturas-play.md)
- [ ] Classificação de conteúdo, público-alvo, anúncios (não), categoria
- [ ] Formulário Data safety (e-mail, ID de dispositivo/FCM, atividade; criptografia em trânsito; exclusão disponível)
- [ ] Declaração de app de notícias/saúde/governo: não se aplica
- [ ] Faixa de teste fechado: subir AAB, adicionar Grupo Google de testadores, copiar link de adesão

## Após enviar
- [ ] Mínimo de testadores optados e manter 14 dias contínuos (conferir exigência vigente no Console)
- [ ] Roteiro de teste (docs/roteiro-teste-q01-p01.md) distribuído; coletar feedback
- [ ] Corrigir bugs, subir nova versão (versionCode maior) se preciso
- [ ] Solicitar acesso à produção quando o Console liberar
