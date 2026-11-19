# Plano de capturas de tela (Google Play) — A02 — RASCUNHO

Nome provisório (D01): **Semente – Catequese Diária**. Não depende de decisões pendentes, exceto o nome exibido.

## 1. Preparação do ambiente
- Usar emulador/aparelho Android 1080x1920 (ou 1080x2400; proporção máx. 2:1), tema claro, idioma pt-BR, relógio 09:41, bateria cheia, sem notificações na barra.
- Conta de demonstração dedicada (ex.: `demo@<dominio D06>`), nome "Maria" — nenhum e-mail ou dado real visível.
- Conteúdo: usar devocionais reais do catálogo versionado (não "teste"). Texto bíblico só se a licença estiver resolvida; senão, mostrar apenas referência + reflexão própria.
- Dados de demonstração: sequência de 12 dias, 2 favoritos, 1 anotação curta ("Pedir paciência hoje."), lembrete às 07:00.
- Fonte/ícone: sem marcas de terceiros (CNBB, Vaticano, Canção Nova etc.).

## 2. Roteiro de telas (ordem na loja)
| # | Tela (aba) | O que mostrar | Legenda sugerida (≤ 6 palavras) |
|---|---|---|---|
| 1 | Hoje | Cartão do dia com referência do Evangelho + reflexão + botão de concluir | Evangelho do dia, todo dia |
| 2 | Leitor + anotação | Reflexão aberta com campo de anotação preenchido | Reflexão curta e suas anotações |
| 3 | Calendário | Mês com celebração litúrgica do dia destacada | Acompanhe o calendário litúrgico |
| 4 | Orações | Lista de orações + detalhe de uma (ex.: Pai-Nosso) | Orações para qualquer hora |
| 5 | Progresso | Sequência de 12 dias, calendário marcado, selo | Crie o hábito de rezar |
| 6 | Ajustes | Lembrete diário 07:00 ligado | Lembrete no seu horário |
Mínimo exigido: 2; usar as 6. Evitar abas Admin/Dispatch (só aparecem para administrador — usar conta não-admin).

## 3. Como capturar
1. `flutter run` em release/profile no emulador; ocultar banner de debug.
2. Capturar com `adb exec-out screencap -p > cap_N.png` (ou botão do emulador).
3. Nomear `01-hoje.png` … `06-ajustes.png` em `docs/site/assets/capturas/` (ou pasta fora do repo se pesada).
4. Opcional: moldura/legenda em ferramenta de design; manter a captura legível e sem texto enganoso.

## 4. Outros materiais (ver `ficha-loja-play.md`)
- Ícone 512x512 PNG · Imagem de destaque 1024x500 (fundo liso + nome + frase "Evangelho do dia e hábito de rezar").
- Capturas de tablet 7"/10" são opcionais.

## 5. Checklist final
- [ ] Sem e-mails/nomes reais · [ ] Sem aba Admin · [ ] Texto bíblico conforme licença · [ ] Nome igual ao fechado em D01
- [ ] Mesmas capturas conferidas após A02 (applicationId) e build de produção
