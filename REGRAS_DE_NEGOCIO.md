# Regras de Negócio - Organizador de Oficina

## 📋 Índice
1. [Visão Geral](#visão-geral)
2. [Entidades do Sistema](#entidades-do-sistema)
3. [Regras de Categorias](#regras-de-categorias)
4. [Regras de Componentes](#regras-de-componentes)
5. [Regras de Estoque](#regras-de-estoque)
6. [Regras Financeiras](#regras-financeiras)
7. [Regras de Busca e Filtros](#regras-de-busca-e-filtros)
8. [Regras de Relatórios](#regras-de-relatórios)
9. [Regras de Exportação](#regras-de-exportação)
10. [Validações e Restrições](#validações-e-restrições)
11. [Fluxos de Processo](#fluxos-de-processo)
12. [Casos de Uso](#casos-de-uso)

---

## 🎯 Visão Geral

### Objetivo do Sistema
Gerenciar o estoque de componentes eletrônicos de uma oficina, permitindo:
- Organização por categorias personalizadas
- Controle de quantidade e localização física
- Rastreamento financeiro do investimento
- Geração de relatórios e exportações

### Usuário Alvo
- Técnicos em eletrônica
- Hobbistas e makers
- Oficinas de reparo eletrônico
- Laboratórios educacionais

---

## 📊 Entidades do Sistema

### 1. Categoria

**Definição:** Agrupamento lógico de componentes eletrônicos similares.

**Atributos:**
- `id`: Identificador único (gerado automaticamente)
- `nome`: Nome da categoria (obrigatório, texto)
- `descricao`: Descrição da categoria (opcional, texto)

**Relacionamentos:**
- 1 Categoria → N Componentes (one-to-many)

**Ciclo de Vida:**
```
[Criada] → [Ativa] → [Excluída]
```

### 2. Componente

**Definição:** Item físico do estoque com características técnicas e localização.

**Atributos:**
- `id`: Identificador único (gerado automaticamente)
- `categoria_id`: Referência à categoria (obrigatório)
- `modelo`: Identificação do modelo (obrigatório, texto)
- `quantidade`: Quantidade em estoque (obrigatório, inteiro ≥ 0)
- `localizacao`: Local físico de armazenamento (obrigatório, texto)
- `polaridade`: Tipo de polaridade (opcional, texto)
- `encapsulamento`: Tipo de encapsulamento (opcional, texto)
- `custo_unitario`: Custo por unidade (obrigatório, decimal ≥ 0)
- `observacao`: Notas adicionais (opcional, texto)

**Atributos Calculados:**
- `valor_total`: quantidade × custo_unitario (calculado em tempo real)

**Relacionamentos:**
- N Componentes → 1 Categoria (many-to-one)

**Ciclo de Vida:**
```
[Cadastrado] → [Em Estoque] → [Baixo Estoque] → [Esgotado] → [Excluído]
```

---

## 🏷️ Regras de Categorias

### RN001 - Criação de Categoria
- **Regra:** Toda categoria deve ter um nome único e não vazio
- **Validação:** Nome obrigatório, mínimo 1 caractere
- **Comportamento:** Sistema permite descrição opcional para detalhar a categoria

### RN002 - Categorias Iniciais
- **Regra:** Sistema cria 5 categorias padrão na primeira execução:
  1. Transistores
  2. Resistores
  3. Capacitores
  4. Diodos
  5. Circuitos Integrados
- **Objetivo:** Facilitar início do uso para novos usuários

### RN003 - Edição de Categoria
- **Regra:** Usuário pode editar nome e descrição a qualquer momento
- **Restrição:** Não pode deixar nome vazio
- **Impacto:** Alterações refletem imediatamente em todos os componentes associados

### RN004 - Exclusão de Categoria
- **Regra:** Ao excluir categoria, TODOS os componentes associados são excluídos
- **Tipo:** Exclusão em cascata (CASCADE DELETE)
- **Validação:** Sistema DEVE exigir confirmação explícita do usuário
- **Mensagem:** Alertar usuário sobre perda de dados de componentes

### RN005 - Listagem de Categorias
- **Regra:** Categorias são sempre listadas em ordem alfabética (A-Z)
- **Ordenação:** Por campo `nome` ascendente

---

## 🔧 Regras de Componentes

### RN006 - Cadastro de Componente
- **Regra:** Todo componente DEVE estar associado a uma categoria existente
- **Campos Obrigatórios:**
  - Categoria
  - Modelo
  - Quantidade
  - Localização
  - Custo Unitário
- **Campos Opcionais:**
  - Polaridade
  - Encapsulamento
  - Observação

### RN007 - Modelo do Componente
- **Regra:** Modelo é identificação única visual (não técnica de banco)
- **Formato:** Texto livre, recomendado MAIÚSCULAS
- **Exemplos:** BC547, 2N3904, LM358, 10K
- **Duplicação:** Sistema PERMITE modelos duplicados (diferentes localizações)

### RN008 - Quantidade
- **Regra:** Quantidade deve ser número inteiro não negativo
- **Valor Mínimo:** 0 (zero representa esgotado)
- **Valor Máximo:** Sem limite técnico
- **Tipo:** Integer (número inteiro)

### RN009 - Localização Física
- **Regra:** Localização é obrigatória para facilitar busca física
- **Formato Sugerido:**
  - Caixas: cx01, cx02, cx03...
  - Gavetas: gav01, gav02...
  - Estantes: est01-A, est01-B...
- **Validação:** Texto livre, mas não pode ser vazio

### RN010 - Polaridade
- **Regra:** Campo opcional para componentes com polaridade
- **Valores Comuns:** NPN, PNP, N-Channel, P-Channel
- **Uso:** Transistores, MOSFETs, diodos especiais

### RN011 - Encapsulamento
- **Regra:** Campo opcional para tipo físico do componente
- **Valores Comuns:** TO-92, TO-220, SMD0805, DIP-8, SOIC-16
- **Uso:** Importante para compatibilidade de montagem

### RN012 - Edição de Componente
- **Regra:** Todos os campos podem ser editados a qualquer momento
- **Validação:** Mesmas regras de cadastro se aplicam
- **Impacto:** Alteração de quantidade afeta cálculos de estoque

### RN013 - Exclusão de Componente
- **Regra:** Componente pode ser excluído independentemente
- **Validação:** Sistema pede confirmação
- **Comportamento:** Não afeta a categoria

---

## 📦 Regras de Estoque

### RN014 - Controle de Quantidade
- **Regra:** Sistema rastreia quantidade exata de cada componente
- **Atualização:** Manual pelo usuário (não automático)
- **Unidade:** Peças/unidades individuais

### RN015 - Baixo Estoque
- **Regra:** Componentes com quantidade < 10 são considerados "baixo estoque"
- **Threshold:** 10 unidades (fixo no sistema)
- **Alertas:** Disponível em relatório específico
- **Objetivo:** Ajudar planejamento de reposição

### RN016 - Componente Esgotado
- **Regra:** Componentes com quantidade = 0 estão esgotados
- **Comportamento:** Permanecem no sistema para histórico
- **Ação Recomendada:** Usuário deve atualizar quantidade ao reabastecer

### RN017 - Localização Múltipla
- **Regra:** Mesmo componente em locais diferentes = cadastros separados
- **Exemplo:** 
  - BC547 na cx01 = 1 cadastro
  - BC547 na cx02 = outro cadastro
- **Motivo:** Facilita localização física exata

---

## 💰 Regras Financeiras

### RN018 - Custo Unitário
- **Regra:** Custo unitário deve ser valor decimal não negativo
- **Formato:** Moeda brasileira (R$)
- **Precisão:** 2 casas decimais
- **Valor Mínimo:** 0.00 (gratuito/doação)
- **Valor Máximo:** Sem limite técnico

### RN019 - Cálculo de Valor Total
- **Fórmula:** `valor_total = quantidade × custo_unitario`
- **Tipo:** Calculado em tempo real (não armazenado)
- **Exibição:** Sempre em formato monetário (R$ 0.00)
- **Atualização:** Automática ao alterar quantidade ou custo

### RN020 - Valor Total do Estoque
- **Fórmula:** `Σ(quantidade × custo_unitario)` de todos componentes
- **Escopo:** Todos os componentes de todas as categorias
- **Uso:** Dashboard e relatórios
- **Tipo:** Calculado dinamicamente

### RN021 - Valor por Categoria
- **Fórmula:** `Σ(quantidade × custo_unitario)` dos componentes da categoria
- **Escopo:** Componentes de uma categoria específica
- **Uso:** Relatório de estoque por categoria

### RN022 - Atualização de Custos
- **Regra:** Custos são por cadastro, não atualizados automaticamente
- **Comportamento:** Cada entrada mantém seu custo histórico
- **Exemplo:** Mesmo componente em datas diferentes pode ter custos diferentes

---

## 🔍 Regras de Busca e Filtros

### RN023 - Busca Textual
- **Campos Pesquisados:**
  - Modelo do componente
  - Localização
- **Tipo:** Busca parcial (LIKE)
- **Case:** Insensível (maiúsculas/minúsculas)
- **Exemplo:** "BC" encontra BC547, BC548, BC337

### RN024 - Filtro por Categoria
- **Regra:** Usuário pode filtrar componentes por categoria específica
- **Comportamento:** Mostra apenas componentes da categoria selecionada
- **Opção:** "Todas" para limpar filtro

### RN025 - Filtro de Preço (Reservado)
- **Status:** Preparado no código, não implementado na UI
- **Funcionalidade:** Filtrar por faixa de custo (min-max)
- **Uso Futuro:** Encontrar componentes dentro de orçamento

### RN026 - Ordenação
- **Padrão:** Ordem alfabética por modelo (A-Z)
- **Alternativas Preparadas:**
  - Por quantidade
  - Por custo unitário
  - Por localização
- **Implementação:** Via parâmetro orderBy no banco

### RN027 - Combinação de Filtros
- **Regra:** Filtros podem ser combinados
- **Exemplo:** Buscar "BC" + Categoria "Transistores"
- **Comportamento:** Operador AND (todas condições devem ser atendidas)

### RN028 - Limpeza de Filtros
- **Regra:** Botão para limpar todos os filtros de uma vez
- **Comportamento:** Restaura listagem completa
- **Campos Resetados:**
  - Texto de busca
  - Categoria selecionada
  - Ordenação volta ao padrão

---

## 📊 Regras de Relatórios

### RN029 - Dashboard (Resumo Geral)
- **Métricas Exibidas:**
  1. Total de Categorias (count)
  2. Total de Componentes (count)
  3. Itens em Estoque (sum de quantidades)
  4. Valor Total Investido (sum de valores totais)
- **Atualização:** Ao carregar tela ou pull-to-refresh

### RN030 - Estoque por Categoria
- **Colunas:**
  - Nome da Categoria
  - Quantidade de Tipos (count de componentes distintos)
  - Quantidade de Itens (sum de quantidades)
  - Valor Total (sum de valores totais)
- **Ordenação:** Alfabética por nome da categoria
- **Inclusão:** Todas as categorias, mesmo sem componentes (mostra 0)

### RN031 - Relatório de Baixo Estoque
- **Critério:** Componentes com quantidade < 10
- **Ordenação:** Por quantidade ascendente (menor primeiro)
- **Objetivo:** Priorizar reposição dos mais críticos
- **Exibição:** Dialog/popup com lista

### RN032 - Formato Monetário
- **Padrão:** Real Brasileiro (R$)
- **Formato:** R$ 1.234,56
- **Separador Decimal:** Vírgula
- **Separador Milhares:** Ponto

---

## 📤 Regras de Exportação

### RN033 - Exportação CSV
- **Formato:** CSV (Comma-Separated Values)
- **Codificação:** UTF-8
- **Separador:** Vírgula
- **Cabeçalho:** Primeira linha com nomes dos campos
- **Campos Incluídos:**
  - ID
  - Categoria (nome, não ID)
  - Modelo
  - Quantidade
  - Localização
  - Polaridade
  - Encapsulamento
  - Custo Unitário (R$)
  - Valor Total (R$)
  - Observação
- **Nome do Arquivo:** `componentes_YYYYMMDD_HHMMSS.csv`
- **Localização:** Pasta Documentos do usuário

### RN034 - Exportação PDF
- **Formato:** PDF (A4)
- **Estrutura:**
  1. Cabeçalho com título e data/hora de geração
  2. Resumo geral (estatísticas)
  3. Tabela de componentes (paginada)
- **Campos na Tabela:**
  - Categoria
  - Modelo
  - Quantidade
  - Localização
  - Valor Total
- **Paginação:** 20 componentes por página
- **Nome do Arquivo:** `relatorio_YYYYMMDD_HHMMSS.pdf`
- **Localização:** Pasta Documentos do usuário

### RN035 - Confirmação de Exportação
- **Regra:** Sistema exibe caminho completo do arquivo após exportação
- **Duração:** 5 segundos (snackbar)
- **Cor:** Verde (sucesso) ou Vermelho (erro)

---

## ✅ Validações e Restrições

### Validações de Entrada

#### VL001 - Categoria Nome
- Obrigatório: SIM
- Tipo: Texto
- Tamanho Mínimo: 1 caractere
- Tamanho Máximo: Sem limite (TEXT no banco)
- Caracteres Especiais: Permitidos

#### VL002 - Componente Modelo
- Obrigatório: SIM
- Tipo: Texto
- Formato Recomendado: MAIÚSCULAS
- Tamanho: Sem restrição
- Unicidade: NÃO (pode repetir)

#### VL003 - Quantidade
- Obrigatório: SIM
- Tipo: Número inteiro
- Valor Mínimo: 0
- Valor Máximo: 2147483647 (INTEGER)
- Decimais: NÃO permitido

#### VL004 - Custo Unitário
- Obrigatório: SIM
- Tipo: Número decimal
- Valor Mínimo: 0.00
- Casas Decimais: 2
- Formato: 0.00

#### VL005 - Localização
- Obrigatório: SIM
- Tipo: Texto
- Tamanho Mínimo: 1 caractere
- Formato: Livre (mas recomendado padrão)

### Restrições de Negócio

#### RS001 - Integridade Referencial
- Componente NÃO pode existir sem categoria válida
- Foreign Key: categoria_id → categorias.id
- On Delete: CASCADE (exclui componentes ao excluir categoria)

#### RS002 - Confirmações Obrigatórias
- Exclusão de categoria: DEVE confirmar
- Exclusão de componente: DEVE confirmar
- Mensagens: Devem explicar consequências

#### RS003 - Valores Calculados
- Valor Total: SEMPRE calculado, nunca armazenado
- Estatísticas: SEMPRE recalculadas ao acessar

---

## 🔄 Fluxos de Processo

### Fluxo 1: Cadastrar Nova Categoria

```
[Início]
    ↓
[Usuário clica botão +]
    ↓
[Sistema exibe formulário]
    ↓
[Usuário preenche nome e descrição]
    ↓
[Usuário clica "Cadastrar"]
    ↓
[Sistema valida campos] ──→ [Erro?] ──→ [Exibe mensagem] ──┐
    ↓ Não                                                    │
[Insere no banco]                                            │
    ↓                                                         │
[Atualiza lista em memória]                                 │
    ↓                                                         │
[Reordena alfabeticamente]                                  │
    ↓                                                         │
[Exibe mensagem de sucesso]                                 │
    ↓                                                         │
[Volta para lista] ←────────────────────────────────────────┘
    ↓
[Fim]
```

### Fluxo 2: Cadastrar Novo Componente

```
[Início]
    ↓
[Usuário clica botão +]
    ↓
[Sistema carrega categorias]
    ↓
[Sistema exibe formulário]
    ↓
[Usuário seleciona categoria]
    ↓
[Usuário preenche campos obrigatórios]
    ↓
[Usuário preenche campos opcionais (se desejar)]
    ↓
[Sistema calcula valor total em tempo real]
    ↓
[Usuário clica "Cadastrar"]
    ↓
[Sistema valida todos os campos] ──→ [Erro?] ──→ [Exibe erros] ──┐
    ↓ Não                                                          │
[Insere no banco]                                                  │
    ↓                                                               │
[Atualiza lista em memória]                                       │
    ↓                                                               │
[Aplica filtros ativos]                                           │
    ↓                                                               │
[Exibe mensagem de sucesso]                                       │
    ↓                                                               │
[Volta para lista] ←──────────────────────────────────────────────┘
    ↓
[Fim]
```

### Fluxo 3: Buscar Componente

```
[Início]
    ↓
[Usuário digita no campo de busca]
    ↓
[Sistema aplica filtro em tempo real]
    ↓
[Busca em modelo E localização]
    ↓
[Aplica outros filtros ativos (categoria, etc)]
    ↓
[Atualiza lista exibida]
    ↓
[Resultado vazio?] ──→ [SIM] ──→ [Exibe mensagem "Nenhum encontrado"]
    ↓ NÃO
[Exibe componentes encontrados]
    ↓
[Fim]
```

### Fluxo 4: Excluir Categoria

```
[Início]
    ↓
[Usuário clica botão excluir]
    ↓
[Sistema conta componentes da categoria]
    ↓
[Exibe dialog de confirmação com alerta]
    ↓
[Usuário confirma?] ──→ [NÃO] ──→ [Cancela operação] ──→ [Fim]
    ↓ SIM
[Executa DELETE CASCADE]
    ↓
[Remove categoria do banco]
    ↓
[Remove componentes associados do banco]
    ↓
[Atualiza lista de categorias em memória]
    ↓
[Atualiza lista de componentes em memória]
    ↓
[Exibe mensagem de sucesso]
    ↓
[Fim]
```

### Fluxo 5: Exportar PDF

```
[Início]
    ↓
[Usuário clica "Exportar para PDF"]
    ↓
[Sistema busca todos os componentes]
    ↓
[Sistema busca todas as categorias]
    ↓
[Sistema busca estatísticas]
    ↓
[Cria documento PDF em memória]
    ↓
[Adiciona cabeçalho com data/hora]
    ↓
[Adiciona resumo geral]
    ↓
[Adiciona tabelas de componentes (pagina se necessário)]
    ↓
[Define nome do arquivo com timestamp]
    ↓
[Salva na pasta Documentos]
    ↓
[Sucesso?] ──→ [NÃO] ──→ [Exibe erro] ──→ [Fim]
    ↓ SIM
[Exibe caminho do arquivo (5 seg)]
    ↓
[Fim]
```

---

## 💼 Casos de Uso

### UC001 - Iniciar Uso do Sistema
**Ator:** Novo Usuário  
**Pré-condição:** Aplicativo instalado  
**Fluxo Principal:**
1. Usuário inicia aplicativo pela primeira vez
2. Sistema cria banco de dados
3. Sistema insere 5 categorias padrão
4. Sistema exibe dashboard (vazio)
5. Usuário pode começar a cadastrar componentes

**Pós-condição:** Sistema pronto para uso

### UC002 - Adicionar Componente ao Estoque
**Ator:** Usuário  
**Pré-condição:** Ao menos 1 categoria existe  
**Fluxo Principal:**
1. Usuário navega para "Componentes"
2. Usuário clica no botão "+"
3. Usuário seleciona categoria
4. Usuário informa: modelo, quantidade, localização, custo
5. Usuário opcionalmente informa: polaridade, encapsulamento, observação
6. Sistema valida dados
7. Sistema salva componente
8. Sistema exibe sucesso

**Pós-condição:** Componente cadastrado no estoque

### UC003 - Localizar Componente Físico
**Ator:** Usuário  
**Pré-condição:** Componentes cadastrados  
**Fluxo Principal:**
1. Usuário navega para "Componentes"
2. Usuário digita modelo na busca (ex: "BC547")
3. Sistema filtra e exibe resultados
4. Usuário visualiza localização (ex: "cx01")
5. Usuário vai até local físico e pega componente

**Pós-condição:** Usuário encontrou componente

### UC004 - Atualizar Quantidade Após Uso
**Ator:** Usuário  
**Pré-condição:** Componente existe e foi usado  
**Fluxo Principal:**
1. Usuário localiza componente na lista
2. Usuário clica em editar
3. Usuário atualiza campo quantidade (subtrai unidades usadas)
4. Sistema recalcula valor total
5. Sistema salva alteração
6. Dashboard é atualizado

**Pós-condição:** Estoque atualizado

### UC005 - Verificar Componentes para Reposição
**Ator:** Usuário  
**Pré-condição:** Sistema em uso há algum tempo  
**Fluxo Principal:**
1. Usuário navega para "Relatórios"
2. Usuário clica em "Componentes com Baixo Estoque"
3. Sistema lista componentes com quantidade < 10
4. Usuário anota quais precisa repor
5. Usuário usa lista para fazer compras

**Pós-condição:** Usuário sabe o que comprar

### UC006 - Compartilhar Inventário
**Ator:** Usuário  
**Pré-condição:** Componentes cadastrados  
**Fluxo Principal:**
1. Usuário navega para "Relatórios"
2. Usuário clica em "Exportar para PDF" ou "Exportar para CSV"
3. Sistema gera arquivo
4. Sistema salva em Documentos
5. Sistema exibe caminho do arquivo
6. Usuário abre pasta e envia arquivo (email, WhatsApp, etc)

**Pós-condição:** Inventário compartilhado

### UC007 - Reorganizar Estoque Físico
**Ator:** Usuário  
**Pré-condição:** Decisão de mudar organização  
**Fluxo Principal:**
1. Usuário move componentes fisicamente
2. Para cada componente movido:
   - Localiza no app
   - Edita campo localização
   - Salva
3. Todos os componentes atualizados

**Pós-condição:** App reflete organização física real

---

## 🎯 Regras de Experiência do Usuário

### UX001 - Feedback Visual
- Toda ação deve ter feedback visual (snackbar, loading, etc)
- Sucesso: Verde
- Erro: Vermelho
- Info: Azul
- Alerta: Laranja

### UX002 - Confirmações
- Ações destrutivas SEMPRE pedem confirmação
- Mensagem deve explicar consequência
- Botão de confirmar deve ter cor de alerta

### UX003 - Loading States
- Operações de banco mostram indicador de loading
- Lista vazia mostra mensagem explicativa
- Erro mostra mensagem com opção de retry

### UX004 - Navegação
- Menu lateral sempre acessível
- Botão voltar sempre presente
- Navegação intuitiva (máximo 3 níveis)

### UX005 - Atualização de Dados
- Pull-to-refresh em todas as listas
- Dados carregam automaticamente ao abrir tela
- Cache em memória para performance

---

## 📈 Métricas e KPIs

### Métricas Principais
1. **Total de Categorias** - Indica organização
2. **Total de Componentes** - Indica variedade do estoque
3. **Total de Itens** - Indica volume físico
4. **Valor Investido** - Indica valor financeiro do estoque

### Indicadores de Saúde
- **Taxa de Baixo Estoque:** (componentes < 10) / total × 100%
- **Valor Médio por Componente:** valor total / total componentes
- **Diversidade por Categoria:** componentes / categorias

---

## 🔮 Expansões Futuras (Planejadas)

### Funcionalidades Potenciais
1. **Histórico de Movimentações**
   - Log de entradas e saídas
   - Rastreamento de uso ao longo do tempo

2. **Alertas Automáticos**
   - Notificação quando estoque baixo
   - Lembretes de reposição

3. **Códigos de Barras**
   - Geração de etiquetas
   - Leitura por câmera

4. **Múltiplos Usuários**
   - Sincronização em nuvem
   - Compartilhamento de inventário

5. **Projetos**
   - Associar componentes a projetos
   - BOM (Bill of Materials)

6. **Fornecedores**
   - Cadastro de onde comprar
   - Histórico de preços

---

## 📝 Glossário

- **Categoria:** Agrupamento lógico de componentes
- **Componente:** Item individual do estoque
- **Estoque:** Quantidade disponível
- **Baixo Estoque:** Quantidade < 10 unidades
- **Localização:** Código do local físico
- **Valor Total:** Quantidade × Custo Unitário
- **Dashboard:** Tela inicial com resumo
- **Provider:** Gerenciador de estado (padrão Flutter)
- **Hot Reload:** Atualização de código sem reiniciar app

---

**Documento elaborado em:** 08/11/2025  
**Versão do Sistema:** 1.0.0  
**Última Atualização:** 08/11/2025

