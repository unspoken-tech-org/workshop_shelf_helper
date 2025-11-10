# Modelo de Negócio - Organizador de Oficina

## 📊 Diagrama de Entidade-Relacionamento (Textual)

```
┌─────────────────────────┐
│      CATEGORIA          │
├─────────────────────────┤
│ • id (PK)               │
│ • nome                  │
│ • descricao             │
└──────────┬──────────────┘
           │
           │ 1
           │
           │ possui
           │
           │ N
           ▼
┌─────────────────────────┐
│     COMPONENTE          │
├─────────────────────────┤
│ • id (PK)               │
│ • categoria_id (FK) ────┘
│ • modelo                │
│ • quantidade            │
│ • localizacao           │
│ • polaridade            │
│ • encapsulamento        │
│ • custo_unitario        │
│ • observacao            │
├─────────────────────────┤
│ CALCULADO:              │
│ • valor_total           │
└─────────────────────────┘
```

## 🔄 Fluxograma Principal de Operações

```
                    ┌─────────────┐
                    │   INÍCIO    │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  Dashboard  │
                    └──────┬──────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
    ┌─────▼─────┐   ┌─────▼─────┐   ┌─────▼─────┐
    │Categorias │   │Componentes│   │ Relatórios│
    └─────┬─────┘   └─────┬─────┘   └─────┬─────┘
          │               │               │
    ┌─────▼─────┐   ┌─────▼─────┐   ┌─────▼─────┐
    │ CRUD      │   │ CRUD      │   │ Visualizar│
    │Categorias │   │Componentes│   │ Exportar  │
    └─────┬─────┘   └─────┬─────┘   └─────┬─────┘
          │               │               │
          │         ┌─────▼─────┐         │
          │         │  Buscar   │         │
          │         │  Filtrar  │         │
          │         └─────┬─────┘         │
          │               │               │
          └───────────────┴───────────────┘
                          │
                    ┌─────▼─────┐
                    │   Banco   │
                    │   Dados   │
                    │  (SQLite) │
                    └───────────┘
```

## 🎯 Matriz de Funcionalidades

| Funcionalidade | Categoria | Componente | Descrição |
|----------------|-----------|------------|-----------|
| **Criar** | ✅ | ✅ | Cadastrar novo registro |
| **Ler** | ✅ | ✅ | Visualizar e listar |
| **Atualizar** | ✅ | ✅ | Editar informações |
| **Excluir** | ✅ | ✅ | Remover registro |
| **Buscar** | ❌ | ✅ | Pesquisa textual |
| **Filtrar** | ❌ | ✅ | Filtro por categoria |
| **Ordenar** | ✅ | ✅ | Organização alfabética |
| **Exportar** | ❌ | ✅ | CSV e PDF |
| **Relatórios** | ✅ | ✅ | Estatísticas |

## 📋 Estados e Transições

### Estados da Categoria
```
    ┌─────────┐
    │ CRIADA  │
    └────┬────┘
         │
         ▼
    ┌─────────┐
    │  ATIVA  │◄────┐
    └────┬────┘     │
         │          │
         ├──────────┘
         │ (Editar)
         │
         ▼
    ┌─────────┐
    │EXCLUÍDA │
    └─────────┘
```

### Estados do Componente
```
    ┌──────────────┐
    │  CADASTRADO  │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │ EM ESTOQUE   │◄─────┐
    │ (qtd > 10)   │      │
    └──────┬───────┘      │
           │              │
           ▼              │
    ┌──────────────┐      │
    │BAIXO ESTOQUE │      │
    │ (qtd < 10)   │      │
    └──────┬───────┘      │
           │              │
           ├──────────────┘
           │ (Reposição)
           │
           ▼
    ┌──────────────┐
    │  ESGOTADO    │
    │  (qtd = 0)   │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │   EXCLUÍDO   │
    └──────────────┘
```

## 🔐 Regras de Integridade

### Integridade Referencial
```
CATEGORIA ──1:N──► COMPONENTE
    │
    └─► ON DELETE CASCADE
        (Ao excluir categoria, 
         exclui componentes)
```

### Restrições de Domínio
```
CATEGORIA.nome:
  ✓ NOT NULL
  ✓ LENGTH > 0

COMPONENTE.quantidade:
  ✓ INTEGER
  ✓ >= 0

COMPONENTE.custo_unitario:
  ✓ DECIMAL(10,2)
  ✓ >= 0.00

COMPONENTE.categoria_id:
  ✓ FOREIGN KEY
  ✓ MUST EXIST in CATEGORIA
```

## 💡 Lógica de Cálculos

### Fórmulas Principais

1. **Valor Total do Componente**
   ```
   valor_total = quantidade × custo_unitario
   ```

2. **Valor Total do Estoque**
   ```
   estoque_total = Σ(componente.quantidade × componente.custo_unitario)
   ```

3. **Valor por Categoria**
   ```
   categoria_valor = Σ(componentes_da_categoria.valor_total)
   ```

4. **Taxa de Baixo Estoque**
   ```
   taxa = (COUNT(qtd < 10) / COUNT(total)) × 100%
   ```

## 🎨 Padrões de Dados

### Formato de Localização (Sugerido)
```
Padrão: [tipo][número][-divisão]

Exemplos:
  cx01        → Caixa 1
  cx02        → Caixa 2
  gav01       → Gaveta 1
  est01-A     → Estante 1, divisão A
  arm02-B3    → Armário 2, prateleira B, posição 3
```

### Nomenclatura de Modelos
```
Padrão: MAIÚSCULAS

Transistores:
  BC547, BC548, 2N3904, 2N2222

Resistores:
  10K, 1K, 100R, 4K7 (4.7K)

Capacitores:
  100uF, 10nF, 1uF/50V

CIs:
  LM358, NE555, 74HC595
```

## 📊 Métricas de Performance

### Indicadores de Qualidade do Estoque

| Métrica | Fórmula | Ideal |
|---------|---------|-------|
| **Cobertura** | (Tipos cadastrados / Tipos necessários) × 100% | > 80% |
| **Disponibilidade** | (Itens > 0 / Total itens) × 100% | > 90% |
| **Investimento Médio** | Valor total / Total componentes | Monitorar |
| **Rotatividade** | (Uso no período / Estoque médio) | N/A* |
| **Taxa Crítica** | (Itens = 0 / Total) × 100% | < 10% |

*Não implementado - requer histórico

## 🔄 Ciclo de Vida dos Dados

### 1. Entrada de Dados
```
Usuário → Formulário → Validação → Banco de Dados
```

### 2. Armazenamento
```
SQLite Local → Pasta Documentos → organizador_oficina.db
```

### 3. Processamento
```
Provider (Estado) → Filtros/Buscas → View (UI)
```

### 4. Saída de Dados
```
Relatórios → Exportação → CSV/PDF → Pasta Documentos
```

## 🎯 Casos de Uso Prioritários

### Alta Prioridade
1. ✅ Cadastrar componente
2. ✅ Buscar componente
3. ✅ Atualizar quantidade
4. ✅ Ver localização
5. ✅ Dashboard

### Média Prioridade
6. ✅ Gerenciar categorias
7. ✅ Relatórios
8. ✅ Exportar dados
9. ✅ Baixo estoque

### Baixa Prioridade (Futuro)
10. ⏳ Histórico de movimentações
11. ⏳ Alertas automáticos
12. ⏳ Códigos de barras
13. ⏳ Multi-usuário

## 📐 Arquitetura de Dados

```
┌─────────────────────────────────────┐
│         CAMADA DE APRESENTAÇÃO      │
│  (Screens: Home, Categorias,        │
│   Componentes, Relatórios)          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       CAMADA DE LÓGICA DE NEGÓCIO   │
│  (Providers: CategoriaProvider,     │
│   ComponenteProvider)                │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      CAMADA DE ACESSO A DADOS       │
│  (DatabaseHelper: CRUD operations)   │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       CAMADA DE PERSISTÊNCIA        │
│  (SQLite: organizador_oficina.db)   │
└─────────────────────────────────────┘
```

## 🔍 Regras de Validação (Resumo)

| Campo | Obrig. | Tipo | Min | Max | Padrão |
|-------|--------|------|-----|-----|--------|
| categoria.nome | ✅ | String | 1 | ∞ | - |
| categoria.descricao | ❌ | String | 0 | ∞ | null |
| componente.modelo | ✅ | String | 1 | ∞ | - |
| componente.quantidade | ✅ | Int | 0 | 2B | - |
| componente.localizacao | ✅ | String | 1 | ∞ | - |
| componente.polaridade | ❌ | String | 0 | ∞ | null |
| componente.encapsulamento | ❌ | String | 0 | ∞ | null |
| componente.custo_unitario | ✅ | Decimal | 0.00 | ∞ | - |
| componente.observacao | ❌ | String | 0 | ∞ | null |

## 🎓 Glossário Técnico

| Termo | Definição | Exemplo |
|-------|-----------|---------|
| **CRUD** | Create, Read, Update, Delete | Operações básicas |
| **Foreign Key** | Chave estrangeira | categoria_id |
| **Primary Key** | Chave primária | id |
| **Provider** | Gerenciador de estado | CategoriaProvider |
| **SQLite** | Banco de dados leve | organizador_oficina.db |
| **CASCADE** | Ação em cadeia | DELETE CASCADE |
| **ChangeNotifier** | Notificador de mudanças | extends ChangeNotifier |
| **Snackbar** | Notificação temporária | Feedback visual |

---

**Versão:** 1.0.0  
**Data:** 08/11/2025  
**Autor:** Sistema Organizador de Oficina

