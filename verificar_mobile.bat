@echo off
REM Roda flutter analyze e flutter test no app e grava tudo em mobile_check.log
set "ROOT=%~dp0"
set "LOG=%ROOT%mobile_check.log"
if exist "%USERPROFILE%\flutter\bin\flutter.bat" set "PATH=%USERPROFILE%\flutter\bin;%PATH%"
cd /d "%ROOT%mobile"
if not exist lib\firebase_options.dart copy lib\firebase_options.dart.example lib\firebase_options.dart >nul
echo === inicio %DATE% %TIME% === > "%LOG%"
call flutter pub get >> "%LOG%" 2>&1
echo === analyze === >> "%LOG%"
call flutter analyze --no-fatal-infos >> "%LOG%" 2>&1
echo === analyze codigo %ERRORLEVEL% === >> "%LOG%"
echo === test === >> "%LOG%"
call flutter test --reporter expanded >> "%LOG%" 2>&1
echo === test codigo %ERRORLEVEL% === >> "%LOG%"
echo === fim === >> "%LOG%"
