# Guia Rápido - Organizador de Oficina

## 🚀 Início Rápido

### Executar o Aplicativo

```bash
flutter run -d windows
```

### Compilar para Produção

```bash
flutter build windows --release
```

O executável estará em: `build\windows\x64\runner\Release\app_organizador_oficina.exe`

## 📋 Funcionalidades Principais

### 1. Dashboard (Tela Inicial)
- Visualização de estatísticas gerais do estoque
- Acesso rápido às principais funcionalidades
- Atualização automática dos dados

### 2. Gerenciamento de Categorias
**Como acessar:** Menu lateral → Categorias

**Operações disponíveis:**
- ➕ **Adicionar:** Clique no botão flutuante (+)
- ✏️ **Editar:** Clique no ícone de lápis ao lado da categoria
- 🗑️ **Excluir:** Clique no ícone de lixeira (confirma antes de excluir)

**Campos:**
- Nome da categoria (obrigatório)
- Descrição (opcional)

### 3. Gerenciamento de Componentes
**Como acessar:** Menu lateral → Componentes

**Operações disponíveis:**
- ➕ **Adicionar:** Clique no botão flutuante (+)
- ✏️ **Editar:** Clique no ícone de lápis ao lado do componente
- 🗑️ **Excluir:** Clique no ícone de lixeira
- 🔍 **Buscar:** Digite no campo de busca (busca por modelo ou localização)
- 🔽 **Filtrar:** Clique no ícone de filtro para filtrar por categoria

**Campos do Componente:**
- **Categoria:** Selecione de uma lista (obrigatório)
- **Modelo:** Ex: BC547 (obrigatório)
- **Quantidade:** Número de unidades em estoque (obrigatório)
- **Localização:** Ex: cx01, cx02 (obrigatório)
- **Polaridade:** Ex: NPN, PNP (opcional)
- **Encapsulamento:** Ex: TO-92 (opcional)
- **Custo Unitário:** Valor em R$ (obrigatório)
- **Observação:** Informações adicionais (opcional)

### 4. Relatórios
**Como acessar:** Menu lateral → Relatórios

**Recursos disponíveis:**

**📊 Resumo Geral**
- Total de categorias
- Total de componentes
- Itens em estoque
- Valor total investido

**📈 Estoque por Categoria**
- Tabela detalhada mostrando:
  - Nome da categoria
  - Quantidade de tipos de componentes
  - Total de itens
  - Valor total por categoria

**💾 Exportação de Dados**

1. **CSV (Excel):**
   - Clique em "Exportar para CSV"
   - Arquivo salvo em: `Documentos\componentes_YYYYMMDD_HHMMSS.csv`
   - Pode ser aberto no Excel ou LibreOffice

2. **PDF:**
   - Clique em "Exportar para PDF"
   - Arquivo salvo em: `Documentos\relatorio_YYYYMMDD_HHMMSS.pdf`
   - Relatório completo formatado

3. **Baixo Estoque:**
   - Clique em "Componentes com Baixo Estoque"
   - Lista componentes com quantidade < 10

## 💡 Dicas de Uso

### Organização de Localização
Recomenda-se usar um padrão para os códigos de localização:
- `cx01`, `cx02`, `cx03` para caixas
- `gav01`, `gav02` para gavetas
- `est01-A`, `est01-B` para estantes com divisões

### Categorias Sugeridas
O sistema já vem com algumas categorias iniciais:
- Transistores
- Resistores
- Capacitores
- Diodos
- Circuitos Integrados

Você pode adicionar mais conforme necessário!

### Busca Rápida
Na tela de componentes:
- Digite apenas parte do modelo (ex: "BC" para encontrar BC547, BC548, etc.)
- Digite o código da localização (ex: "cx01") para ver todos os componentes daquela caixa

### Backup dos Dados
O banco de dados é salvo em:
`C:\Users\[seu_usuario]\Documents\organizador_oficina.db`

**Importante:** Faça backup regular deste arquivo!

## 🎨 Interface

### Ícones e Cores
- 🔵 **Azul:** Categorias
- 🟢 **Verde:** Componentes
- 🟣 **Roxo:** Relatórios e valores financeiros
- 🟠 **Laranja:** Alertas e estoque

### Navegação
- **Menu lateral (☰):** Acesso a todas as telas
- **Botão (+):** Adicionar novo item
- **Atualizar (↻):** Recarregar dados

## ⚠️ Observações Importantes

1. **Exclusão de Categoria:** 
   - Ao excluir uma categoria, TODOS os componentes dela também serão excluídos
   - O sistema pede confirmação antes de prosseguir

2. **Valores Monetários:**
   - Use ponto ou vírgula como separador decimal
   - Aceita até 2 casas decimais
   - Ex: 0.50 ou 0,50

3. **Campos Obrigatórios:**
   - São marcados com asterisco (*)
   - O sistema não permite salvar sem preencher estes campos

4. **Atualização Automática:**
   - O dashboard é atualizado automaticamente ao entrar
   - Use "puxar para atualizar" nas listagens para recarregar dados

## 🆘 Solução de Problemas

### Erro ao abrir o aplicativo
- Verifique se todas as dependências foram instaladas: `flutter pub get`

### Banco de dados não encontrado
- O banco é criado automaticamente na primeira execução
- Localização: Pasta Documentos do usuário

### Exportação não funciona
- Verifique permissões de escrita na pasta Documentos
- O caminho completo do arquivo é exibido após a exportação

## 📞 Suporte

Para problemas ou sugestões, verifique:
- A versão do Flutter: `flutter --version`
- Logs do aplicativo para erros específicos

---

**Desenvolvido com Flutter 💙**

