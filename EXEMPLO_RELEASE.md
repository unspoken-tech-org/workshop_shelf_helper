# 📝 Exemplo: Como Criar um Release

Este documento mostra **passo a passo** como funciona o novo sistema de release com notas personalizadas.

## 🚀 Executando o Script

```cmd
> release.bat

==========================================
 Workshop Shelf Helper - Release Helper
==========================================

Versao atual: 1.0.0

Escolha o tipo de versao:
1. Patch (bug fixes) - exemplo: 1.0.0 -> 1.0.1
2. Minor (new features) - exemplo: 1.0.0 -> 1.1.0
3. Major (breaking changes) - exemplo: 1.0.0 -> 2.0.0
4. Custom (especificar manualmente)

Opcao (1-4): 2

Nova versao: 1.1.0

==========================================
 NOTAS DE RELEASE
==========================================

Digite as mudancas desta versao (uma por linha).
Dicas:
  - Novas funcionalidades
  - Correcoes de bugs
  - Melhorias de performance
  - Mudancas importantes

Quando terminar, digite "FIM" em uma linha e pressione Enter.
Para pular, digite "FIM" direto.

- Novo sistema de atualizacao automatica
- Verificacao de atualizacoes ao iniciar o app
- Botao manual para buscar atualizacoes no menu
- Melhorias na interface de instalacao
- Correcao de bug no salvamento de componentes
- FIM

==========================================
 RESUMO
==========================================
Versao atual: 1.0.0
Nova versao:  1.1.0
Tag:          v1.1.0
Notas:
- Novo sistema de atualizacao automatica
- Verificacao de atualizacoes ao iniciar o app
- Botao manual para buscar atualizacoes no menu
- Melhorias na interface de instalacao
- Correcao de bug no salvamento de componentes
==========================================

Confirma a criacao do release? (s/N): s

Atualizando pubspec.yaml...
Criando commit...
Criando tag v1.1.0...

==========================================
 Pronto para publicar!
==========================================

Os seguintes comandos serao executados:
  git push origin master
  git push origin v1.1.0

Isso ira:
1. Enviar o commit de versao para o repositorio
2. Enviar a tag para o repositorio
3. Triggerar o GitHub Actions para criar o release automaticamente

Deseja executar o push agora? (s/N): s

Fazendo push do commit...
Fazendo push da tag...

==========================================
 SUCESSO!
==========================================

Release v1.1.0 criado com sucesso!

O GitHub Actions esta processando o build...
Acompanhe em: https://github.com/seu-usuario/app-organizador-oficina/actions
```

## 📦 O que o GitHub Actions Faz Automaticamente

1. **Detecta** a nova tag `v1.1.0`
2. **Compila** o app Flutter para Windows
3. **Extrai** as notas de release da tag
4. **Cria** o instalador com Inno Setup
5. **Publica** a release no GitHub com descrição completa
6. **Anexa** o instalador `.exe` à release

## 🌐 Como Fica no GitHub Releases

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Release 1.1.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Workshop Shelf Helper v1.1.0

### ✨ Novidades

- Novo sistema de atualizacao automatica
- Verificacao de atualizacoes ao iniciar o app
- Botao manual para buscar atualizacoes no menu
- Melhorias na interface de instalacao
- Correcao de bug no salvamento de componentes

---

### 📦 Como Instalar

1. **Baixe o instalador** abaixo (`WorkshopShelfHelper-Setup-1.1.0.exe`)
2. **Execute o arquivo** (será solicitado privilégios de administrador)
3. **Siga o assistente** de instalação
4. **Escolha o diretório** de instalação (padrão: `C:\Program Files\Workshop Shelf Helper`)

### 🔄 Atualizando de Versão Anterior

Se você já tem uma versão instalada:
- ✅ O instalador **detectará automaticamente** a versão anterior
- ✅ Seu **banco de dados será preservado** (sem perda de dados)
- ✅ A atualização será feita **automaticamente**
- ✅ Todas as suas **configurações e componentes** permanecerão intactos

### 📋 Requisitos

- Windows 10 ou superior (64-bit)
- Privilégios de administrador para instalação
- ~100 MB de espaço em disco

### 🆘 Suporte

Em caso de problemas, consulte a documentação no repositório ou abra uma issue.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Assets
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📎 WorkshopShelfHelper-Setup-1.1.0.exe (85.2 MB)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 🎯 Benefícios do Novo Sistema

### Para Você (Desenvolvedor)

✅ **Fácil de usar** - apenas execute `release.bat`  
✅ **Guiado** - script pergunta tudo que precisa  
✅ **Seguro** - mostra resumo antes de confirmar  
✅ **Automático** - GitHub Actions faz todo o resto  

### Para os Usuários

✅ **Informativo** - sabem exatamente o que mudou  
✅ **Profissional** - página de release bem formatada  
✅ **Claro** - instruções detalhadas de instalação  
✅ **Confiável** - informações sobre preservação de dados  

## 📝 Dicas de Uso

### Boas Notas de Release

**✅ BOM:**
```
- Novo sistema de atualizacao automatica
- Correcao de bug que causava travamento ao importar CSV
- Melhorias de performance no carregamento do dashboard
- Adicionado suporte para exportacao em Excel
```

**❌ RUIM:**
```
- Atualizacoes
- Bugs corrigidos
- Melhorias
```

### Se Não Tiver Notas

Apenas digite `FIM` quando solicitado. O release será criado com a mensagem:
```
Nenhuma nota de release fornecida.
```

## 🔄 Fluxo Completo

```
┌─────────────────┐
│  release.bat    │
│  (você executa) │
└────────┬────────┘
         │
         ├─ Escolhe tipo de versão
         ├─ Digite notas de release
         ├─ Confirma
         ├─ Atualiza pubspec.yaml
         ├─ Cria commit
         ├─ Cria tag com notas
         └─ Push para GitHub
                 │
                 ▼
         ┌───────────────────┐
         │  GitHub Actions   │
         │  (automatico)     │
         └────────┬──────────┘
                  │
                  ├─ Build Flutter
                  ├─ Extrai notas da tag
                  ├─ Cria instalador
                  ├─ Cria release
                  └─ Anexa instalador
                          │
                          ▼
                  ┌──────────────┐
                  │ GitHub       │
                  │ Release Page │
                  │ (público)    │
                  └──────────────┘
```

## 🎉 Pronto!

Agora você tem um sistema completo e profissional de release! Cada versão terá:
- ✅ Notas detalhadas e personalizadas
- ✅ Instruções claras de instalação
- ✅ Instalador pronto para download
- ✅ Tudo automatizado

Para criar seu primeiro release:
```cmd
release.bat
```

