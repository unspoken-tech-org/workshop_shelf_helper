# Instalador Windows - Inno Setup

Este diretório contém o script de configuração do Inno Setup para gerar o instalador do Workshop Shelf Helper.

## Arquivo

- **setup.iss**: Script principal do Inno Setup

## Compilação Local

Para compilar o instalador localmente:

1. Certifique-se de que o app foi compilado:
   ```bash
   flutter build windows --release
   ```

2. Instale o Inno Setup: https://jrsoftware.org/isdl.php

3. Execute:
   ```cmd
   "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" setup.iss
   ```

4. O instalador será gerado em: `../output/`

## Compilação Automática

O GitHub Actions compila automaticamente quando você cria uma tag:

```bash
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```

## Configurações Principais

- **Privilégios de Admin**: Sim (necessário para instalar em diretórios do sistema)
- **Diretório Padrão**: `C:\Program Files\Workshop Shelf Helper\`
- **Preserva Banco**: Sim (arquivos `.db` nunca são deletados em atualizações)
- **Atalhos**: Desktop (opcional) e Menu Iniciar
- **Desinstalação Anterior**: Automática ao atualizar

Para mais detalhes, consulte `INSTALADOR_WINDOWS.md` na raiz do projeto.

