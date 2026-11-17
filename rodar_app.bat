@echo off
REM Sobe o backend (porta 8000) e o app Flutter no Chrome (porta 5000).
set "ROOT=%~dp0"
set "PATH=%PATH%;%USERPROFILE%\flutter\bin"

start "Backend app_devocional" cmd /k "cd /d %ROOT% && .env\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000"

cd /d "%ROOT%mobile"
call flutter pub get
call flutter run -d chrome --web-port 5000 --dart-define=API_BASE_URL=http://localhost:8000
pause
