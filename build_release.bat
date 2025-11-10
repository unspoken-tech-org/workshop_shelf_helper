@echo off
echo ==========================================
echo  Organizador de Oficina - Build Release
echo ==========================================
echo.

echo Verificando dependencias...
call flutter pub get

echo.
echo Compilando aplicativo para Windows (Release)...
echo.

call flutter build windows --release

echo.
echo ==========================================
echo  Build concluido com sucesso!
echo ==========================================
echo.
echo O executavel esta em:
echo build\windows\x64\runner\Release\app_organizador_oficina.exe
echo.

pause

