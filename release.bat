@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo  Workshop Shelf Helper - Release Helper
echo ==========================================
echo.

REM Verifica se git está instalado
where git >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERRO: Git nao encontrado. Instale o Git e tente novamente.
    pause
    exit /b 1
)

REM Verifica se há mudanças não commitadas
git diff --quiet
if %ERRORLEVEL% NEQ 0 (
    echo AVISO: Existem mudancas nao commitadas!
    echo.
    git status --short
    echo.
    set /p CONTINUE="Deseja continuar mesmo assim? (s/N): "
    if /i not "!CONTINUE!"=="s" (
        echo Release cancelado.
        pause
        exit /b 1
    )
)

REM Lê a versão atual do pubspec.yaml
for /f "tokens=2" %%i in ('findstr /r "^version:" pubspec.yaml') do set CURRENT_VERSION=%%i

REM Remove o +buildNumber se existir
for /f "tokens=1 delims=+" %%a in ("%CURRENT_VERSION%") do set CURRENT_VERSION=%%a

echo Versao atual: %CURRENT_VERSION%
echo.

REM Menu de incremento de versão
echo Escolha o tipo de versao:
echo   1. Patch (bug fixes) - exemplo: 1.0.0 -^> 1.0.1
echo   2. Minor (new features) - exemplo: 1.0.0 -^> 1.1.0
echo   3. Major (breaking changes) - exemplo: 1.0.0 -^> 2.0.0
echo   4. Custom (especificar manualmente)
echo.
set /p VERSION_TYPE="Opcao (1-4): "

REM Divide a versão atual
for /f "tokens=1-3 delims=." %%a in ("%CURRENT_VERSION%") do (
    set MAJOR=%%a
    set MINOR=%%b
    set PATCH=%%c
)

REM Calcula a nova versão
if "%VERSION_TYPE%"=="1" (
    set /a PATCH+=1
    set NEW_VERSION=!MAJOR!.!MINOR!.!PATCH!
) else if "%VERSION_TYPE%"=="2" (
    set /a MINOR+=1
    set PATCH=0
    set NEW_VERSION=!MAJOR!.!MINOR!.!PATCH!
) else if "%VERSION_TYPE%"=="3" (
    set /a MAJOR+=1
    set MINOR=0
    set PATCH=0
    set NEW_VERSION=!MAJOR!.!MINOR!.!PATCH!
) else if "%VERSION_TYPE%"=="4" (
    set /p NEW_VERSION="Digite a nova versao (formato: X.Y.Z): "
) else (
    echo Opcao invalida!
    pause
    exit /b 1
)

echo.
echo Nova versao: %NEW_VERSION%
echo.

REM Solicita notas de release detalhadas
echo ==========================================
echo  NOTAS DE RELEASE
echo ==========================================
echo.
echo Digite as mudancas desta versao (uma por linha).
echo Dicas:
echo   - Novas funcionalidades
echo   - Correcoes de bugs
echo   - Melhorias de performance
echo   - Mudancas importantes
echo.
echo Quando terminar, digite "FIM" em uma linha e pressione Enter.
echo Para pular, digite "FIM" direto.
echo.

REM Cria arquivo temporário para notas
set NOTES_FILE=%TEMP%\release_notes_%NEW_VERSION%.txt
if exist "%NOTES_FILE%" del "%NOTES_FILE%"

:input_loop
set /p "INPUT_LINE=- "
if /i "%INPUT_LINE%"=="FIM" goto end_input
if not "%INPUT_LINE%"=="" echo %INPUT_LINE% >> "%NOTES_FILE%"
goto input_loop

:end_input

REM Verifica se há notas
set HAS_NOTES=0
if exist "%NOTES_FILE%" (
    for %%A in ("%NOTES_FILE%") do if %%~zA gtr 0 set HAS_NOTES=1
)

echo.
echo ==========================================
echo  RESUMO
echo ==========================================
echo Versao atual: %CURRENT_VERSION%
echo Nova versao:  %NEW_VERSION%
echo Tag:          v%NEW_VERSION%
if %HAS_NOTES%==1 (
    echo Notas:
    type "%NOTES_FILE%"
) else (
    echo Notas:        ^(nenhuma^)
)
echo ==========================================
echo.
set /p CONFIRM="Confirma a criacao do release? (s/N): "

if /i not "%CONFIRM%"=="s" (
    echo Release cancelado.
    pause
    exit /b 1
)

echo.
echo Atualizando pubspec.yaml...

REM Atualiza a versão no pubspec.yaml
powershell -Command "(Get-Content pubspec.yaml) -replace 'version: %CURRENT_VERSION%.*', 'version: %NEW_VERSION%+1' | Set-Content pubspec.yaml"

echo Criando commit...
git add pubspec.yaml
git commit -m "chore: bump version to %NEW_VERSION%"

echo Criando tag v%NEW_VERSION%...
REM Cria mensagem da tag com formato estruturado
set TAG_MSG_FILE=%TEMP%\tag_message_%NEW_VERSION%.txt
echo Release %NEW_VERSION% > "%TAG_MSG_FILE%"
echo. >> "%TAG_MSG_FILE%"

if %HAS_NOTES%==1 (
    echo ### Novidades >> "%TAG_MSG_FILE%"
    echo. >> "%TAG_MSG_FILE%"
    type "%NOTES_FILE%" >> "%TAG_MSG_FILE%"
) else (
    echo Versao %NEW_VERSION% >> "%TAG_MSG_FILE%"
)

git tag -a v%NEW_VERSION% -F "%TAG_MSG_FILE%"

REM Limpa arquivos temporários
if exist "%NOTES_FILE%" del "%NOTES_FILE%"
if exist "%TAG_MSG_FILE%" del "%TAG_MSG_FILE%"

REM Detecta a branch atual
for /f "tokens=*" %%b in ('git rev-parse --abbrev-ref HEAD') do set CURRENT_BRANCH=%%b

echo.
echo ==========================================
echo  Pronto para publicar!
echo ==========================================
echo.
echo Os seguintes comandos serao executados:
echo   git push origin %CURRENT_BRANCH%
echo   git push origin v%NEW_VERSION%
echo.
echo Isso ira:
echo 1. Enviar o commit de versao para o repositorio
echo 2. Enviar a tag para o repositorio
echo 3. Triggerar o GitHub Actions para criar o release automaticamente
echo.
set /p PUSH="Deseja executar o push agora? (s/N): "

if /i "%PUSH%"=="s" (
    echo.
    echo Fazendo push do commit para branch %CURRENT_BRANCH%...
    git push origin %CURRENT_BRANCH%
    if %ERRORLEVEL% NEQ 0 (
        echo ERRO: Falha ao fazer push do commit.
        echo Desfazendo mudancas...
        git reset --hard HEAD~1
        git tag -d v%NEW_VERSION%
        pause
        exit /b 1
    )
    
    echo Fazendo push da tag...
    git push origin v%NEW_VERSION%
    if %ERRORLEVEL% NEQ 0 (
        echo ERRO: Falha ao fazer push da tag.
        pause
        exit /b 1
    )
    
    REM Tenta extrair a URL do repositório remoto
    for /f "tokens=*" %%u in ('git config --get remote.origin.url') do set REPO_URL=%%u
    set REPO_URL=%REPO_URL:.git=%
    set REPO_URL=%REPO_URL:git@github.com:=https://github.com/%
    
    echo.
    echo ==========================================
    echo  SUCESSO!
    echo ==========================================
    echo.
    echo Release v%NEW_VERSION% criado com sucesso!
    echo.
    echo O GitHub Actions esta processando o build...
    if not "%REPO_URL%"=="" (
        echo Acompanhe em: %REPO_URL%/actions
    ) else (
        echo Acompanhe no GitHub Actions do seu repositorio.
    )
    echo.
) else (
    echo.
    echo Push cancelado. Para fazer o push manualmente, execute:
    echo   git push origin %CURRENT_BRANCH%
    echo   git push origin v%NEW_VERSION%
    echo.
    echo Para desfazer as mudancas, execute:
    echo   git reset --hard HEAD~1
    echo   git tag -d v%NEW_VERSION%
    echo.
)

pause

