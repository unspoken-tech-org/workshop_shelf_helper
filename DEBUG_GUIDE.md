# Guia de Debug e Execução

Este guia explica como executar e debugar o aplicativo Organizador de Oficina no Windows.

## 🎯 Métodos de Execução

### 1. Usando Scripts Batch (Mais Simples)

Criamos scripts `.bat` para facilitar a execução:

#### **run_debug.bat** - Executar em Modo Debug
```bash
# Basta clicar duplo no arquivo ou executar no terminal:
run_debug.bat
```
- ✅ Hot reload habilitado
- ✅ Melhor para desenvolvimento
- ✅ Console com logs detalhados

#### **run_release.bat** - Executar em Modo Release
```bash
run_release.bat
```
- ✅ Otimizado e rápido
- ✅ Performance máxima
- ❌ Sem hot reload

#### **build_release.bat** - Compilar Executável
```bash
build_release.bat
```
- ✅ Gera executável standalone
- ✅ Pode distribuir para outros computadores
- 📁 Executável em: `build\windows\x64\runner\Release\app_organizador_oficina.exe`

### 2. Usando VSCode/Cursor (Recomendado para Debug)

Criamos configurações prontas no arquivo `.vscode/launch.json`.

#### Como usar:

1. **Abrir o painel de Debug:**
   - Pressione `F5` ou
   - Clique no ícone de Debug na barra lateral (ícone de play com bug)

2. **Selecionar a configuração:**
   - **Debug Windows** - Modo debug padrão (recomendado)
   - **Release Windows** - Modo release
   - **Profile Windows** - Modo profile (análise de performance)

3. **Iniciar:**
   - Pressione `F5` ou clique em "Start Debugging"

#### Atalhos úteis no Debug:
- `F5` - Iniciar/Continuar
- `Shift + F5` - Parar
- `Ctrl + Shift + F5` - Reiniciar
- `F10` - Step Over (próxima linha)
- `F11` - Step Into (entrar na função)

#### Breakpoints:
- Clique na margem esquerda do editor (ao lado do número da linha)
- Ou pressione `F9` na linha desejada
- O debug pausará automaticamente nos breakpoints

### 3. Usando Terminal/CMD

#### Modo Debug:
```bash
flutter run -d windows --debug
```

#### Modo Release:
```bash
flutter run -d windows --release
```

#### Compilar:
```bash
flutter build windows --release
```

## 🔧 Tarefas VSCode/Cursor

Criamos tarefas prontas no `.vscode/tasks.json`:

### Como executar tarefas:

1. Pressione `Ctrl + Shift + P`
2. Digite "Tasks: Run Task"
3. Selecione uma das tarefas:
   - **Flutter: Run Debug** - Executar em debug
   - **Flutter: Build Release** - Compilar release
   - **Flutter: Clean** - Limpar build
   - **Flutter: Pub Get** - Atualizar dependências
   - **Flutter: Analyze** - Analisar código

## 🐛 Dicas de Debug

### 1. Hot Reload
No modo debug, após fazer alterações no código:
- Pressione `r` no terminal Flutter
- Ou pressione `Ctrl + F5` no VSCode/Cursor

### 2. Hot Restart
Para reiniciar completamente o app:
- Pressione `R` (maiúsculo) no terminal Flutter
- Ou pressione `Shift + F5` e depois `F5` no VSCode

### 3. Logs e Print
```dart
print('Minha mensagem de debug');
debugPrint('Mensagem mais detalhada');
```

### 4. DevTools
Flutter vem com ferramentas de desenvolvimento:
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### 5. Verificar Dispositivos
Para listar dispositivos disponíveis:
```bash
flutter devices
```

Deve mostrar algo como:
```
Windows (desktop) • windows • windows-x64 • Microsoft Windows [versão]
```

## ⚙️ Configurações Úteis

### settings.json (VSCode/Cursor)
Adicione ao seu `.vscode/settings.json`:

```json
{
    "dart.flutterSdkPath": "caminho/para/flutter",
    "dart.debugExternalPackageLibraries": true,
    "dart.debugSdkLibraries": false,
    "files.exclude": {
        "**/.dart_tool": true,
        "**/.flutter-plugins": true,
        "**/.packages": true
    }
}
```

## 🚨 Solução de Problemas

### Erro: "Flutter not found"
```bash
# Verifique se Flutter está no PATH
flutter --version

# Se não estiver, adicione ao PATH do Windows:
# Painel de Controle → Sistema → Configurações Avançadas → Variáveis de Ambiente
```

### Erro: "No device found"
```bash
# Verifique se o Windows Desktop está habilitado:
flutter config --enable-windows-desktop
```

### Erro de Compilação
```bash
# Limpe o projeto e tente novamente:
flutter clean
flutter pub get
flutter run -d windows
```

### Hot Reload não funciona
- Certifique-se de estar em modo **debug** (não release)
- Reinicie o app com Hot Restart (`R`)
- Verifique se não há erros de compilação

### Performance lenta em Debug
- Normal! O modo debug adiciona verificações extras
- Use modo **release** para testar performance real:
```bash
flutter run -d windows --release
```

## 📊 Análise de Performance

### Profile Mode
```bash
flutter run -d windows --profile
```

### DevTools
```bash
# Com o app rodando, abra DevTools:
flutter pub global run devtools
```

## 🎨 Estrutura de Debug

```
.vscode/
├── launch.json     # Configurações de debug
└── tasks.json      # Tarefas do Flutter

Scripts:
├── run_debug.bat      # Executar debug (duplo clique)
├── run_release.bat    # Executar release (duplo clique)
└── build_release.bat  # Compilar (duplo clique)
```

## 📝 Notas Importantes

1. **Primeira execução**: Pode demorar mais (compilação inicial)
2. **Hot Reload**: Funciona apenas em modo debug
3. **Breakpoints**: Funcionam apenas em modo debug
4. **Performance**: Teste sempre em modo release antes de distribuir
5. **Logs**: Fique atento ao console durante debug

## 🎯 Recomendação

Para **desenvolvimento diário**:
- Use **VSCode/Cursor** com a configuração "Debug Windows"
- Pressione `F5` para iniciar
- Use Hot Reload (`r`) frequentemente

Para **testes finais**:
- Use **run_release.bat** ou compile com **build_release.bat**
- Teste o executável como usuário final

---

**Happy Coding! 🚀**

