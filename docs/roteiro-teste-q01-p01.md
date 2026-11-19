# Roteiro de teste manual — Excluir conta (Q01) + Postgres (P01)

> Preparado pela rotina em 18/11/2026. Nada aqui foi executado: a rotina não tem Flutter, Docker nem Postgres.

## 0. Pré-checagem local (5 min)
```
pytest -q                                   # esperado: 39+ passed
cd mobile && flutter pub get && flutter analyze && flutter test
python scripts/gen_site.py                   # regenera docs/site/*.html
```
Se `flutter analyze` acusar `use_build_context_synchronously` em `profile_page.dart`, é ajuste pequeno (checar `mounted` após `await`).

## 1. Validar migrações em Postgres vazio (P01)
```
docker run --name pg-test -e POSTGRES_PASSWORD=pw -e POSTGRES_DB=semente -p 5433:5432 -d postgres:16
set DATABASE_URL=postgresql://postgres:pw@localhost:5433/semente     (PowerShell: $env:DATABASE_URL=...)
pip install -r requirements.txt
alembic upgrade head          # esperado: 4 migrações aplicadas sem erro
alembic current               # esperado: 20261112_04 (head)
pytest -q                     # com DATABASE_URL apontando p/ Postgres, se os testes aceitarem
```
Anotar qualquer erro de tipo/sintaxe (ex.: booleans, defaults, índices) — são ajustes em `alembic/versions`.

## 2. Excluir conta — conta local
1. Subir backend (`rodar_app.bat`) e app (emulador/Chrome).
2. Criar conta nova por e-mail; ler 1 devocional, favoritar, ativar lembrete.
3. Perfil → Editar perfil → Excluir conta → senha **errada**. Esperado: mensagem de erro, continua logado.
4. Repetir com senha **correta**. Esperado: volta ao login; fila offline e cache local limpos.
5. Tentar logar com a mesma conta. Esperado: falha (conta inexistente).
6. Conferir no banco: usuário, refresh tokens, favoritos, progresso e dispositivos FCM desse usuário = 0 linhas.

## 3. Excluir conta — Google
1. Entrar com Google (requer Firebase configurado no dispositivo).
2. Excluir conta → "Confirmar com Google". Esperado: novo login Google e conta apagada.
3. Entrar de novo com a mesma conta Google: deve criar conta **nova**, sem histórico.

## 4. Páginas web
- Abrir `docs/site/privacidade.html` e `excluir-conta.html` no navegador (desktop e celular): links entre as páginas funcionam, nenhum texto cortado.
- Campos amarelos = pendências D02/D03/D06.

## 5. Registrar resultado
Marcar na planilha: Q01 (app + backend), Q02 (política + exclusão web), P01 (Postgres validado). Itens com falha → abrir ajuste antes de 01/12.
