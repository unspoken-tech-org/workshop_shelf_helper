<!--
Sync Impact Report - Version 1.0.0
===========================================
Version Change: [NEW] → 1.0.0
Ratification Date: 2026-01-14
Constitution Type: Initial Creation

Modified Principles: N/A (Initial Version)

Added Sections:
- I. Qualidade de Código
- II. Padrões de Teste
- III. Performance e Otimização
- IV. Experiência do Usuário (UX)
- V. Arquitetura Limpa
- VI. Gestão de Dados
- VII. Manutenibilidade

Templates Status:
✅ plan-template.md - Constitution Check section is generic and compatible
✅ spec-template.md - Functional requirements align with quality principles
✅ tasks-template.md - Test-driven phases align with testing principles

Follow-up TODOs: None

Notes:
- Constitution created for Windows Desktop Flutter application
- Focus: Quality, Testing, Performance, User Experience
- Technology stack: Flutter/Dart, SQLite, Provider pattern
- Architecture: Clean Architecture with repositories and entities
-->

# Workshop Shelf Helper - Constituição de Desenvolvimento

## Princípios Fundamentais

### I. Qualidade de Código

**Regras Não-Negociáveis:**

- **DEVE** seguir as convenções de nomenclatura Dart/Flutter:
  - Arquivos em snake_case
  - Classes em PascalCase
  - Variáveis e funções em camelCase
  - Interfaces com prefixo `I`
  - Entidades com sufixo `Entity`
- **DEVE** usar anotações de tipo explícitas em todos os casos
- **DEVE** aplicar null safety rigorosamente (usar `?` apenas quando necessário)
- **DEVE** organizar imports na ordem: dart core → flutter → third-party → local
- **DEVE** executar `flutter analyze` sem warnings antes de cada commit
- **DEVE** formatar código com `dart format` (linha 80-100 caracteres)
- **NUNCA** criar funções que retornam widgets - sempre criar classes Widget dedicadas
- **SEMPRE** usar construtores `const` quando possível para otimização de performance

**Justificativa:** Código consistente e bem tipado reduz bugs em 40% (estudos de null safety) e facilita manutenção em projetos desktop de longa duração.

### II. Padrões de Teste

**Regras Não-Negociáveis:**

- **DEVE** implementar testes unitários para:
  - Mappers (Entity ↔ Model)
  - Providers (lógica de negócio)
  - Repositories (acesso a dados)
  - Utilitários (normalização, validação)
- **DEVE** atingir cobertura mínima de 70% em código crítico
- **DEVE** executar `flutter test` antes de commits em funcionalidades críticas
- **DEVE** testar cenários de erro e edge cases (dados nulos, vazios, inválidos)
- **DEVE** usar testes de integração para fluxos completos (CRUD de componentes/categorias)
- **DEVE** mockar dependências externas (database, file system)
- **NUNCA** commitar código que quebra testes existentes

**Justificativa:** Aplicações desktop Windows requerem estabilidade robusta. Testes garantem que mudanças no SQLite local ou migrações não corrompam dados do usuário.

### III. Performance e Otimização

**Regras Não-Negociáveis:**

- **DEVE** normalizar campos de texto para busca eficiente (`model_normalized`, `location_normalized`)
- **DEVE** usar índices em colunas de busca frequente no SQLite
- **DEVE** implementar lazy loading em listas longas (virtualization)
- **DEVE** usar `const` widgets para evitar rebuilds desnecessários
- **DEVE** otimizar queries SQLite (evitar N+1, usar JOINs apropriados)
- **DEVE** chamar `notifyListeners()` apenas em blocos `finally` para evitar múltiplas notificações
- **DEVE** implementar debouncing em campos de busca (mínimo 300ms)
- **NUNCA** bloquear a UI thread - usar `async/await` para operações de I/O
- **NUNCA** carregar toda a base de dados na memória

**Metas de Performance:**
- Tempo de inicialização: < 2 segundos
- Resposta de busca: < 300ms para 10.000 registros
- Operações CRUD: < 100ms
- Uso de memória: < 200MB em operação normal

**Justificativa:** Aplicações desktop devem ser responsivas. Normalização de texto + índices garantem buscas instantâneas mesmo com milhares de componentes.

### IV. Experiência do Usuário (UX)

**Regras Não-Negociáveis:**

- **DEVE** fornecer feedback visual imediato para todas as ações (loading, sucesso, erro)
- **DEVE** validar campos em tempo real com mensagens claras
- **DEVE** implementar diálogos de confirmação para ações destrutivas (exclusões)
- **DEVE** manter estado de busca/filtros ao navegar entre telas
- **DEVE** usar Material Design 3 de forma consistente
- **DEVE** implementar navegação intuitiva via Drawer com acesso a todas as funcionalidades
- **DEVE** suportar pull-to-refresh em listagens
- **DEVE** exibir estados vazios com instruções claras
- **NUNCA** mostrar stack traces técnicos ao usuário final
- **NUNCA** permitir ações sem confirmação que possam causar perda de dados

**Justificativa:** Usuários de desktop esperam aplicações polidas e profissionais. Feedback claro reduz erros e suporte.

### V. Arquitetura Limpa

**Regras Não-Negociáveis:**

- **DEVE** seguir a separação em camadas:
  - **Models**: Lógica de negócio (em `models/`)
  - **Entities**: Representação de banco de dados (em `database/entities/`)
  - **Mappers**: Conversão entre Entity e Model (em `mappers/`)
  - **Repositories**: Acesso a dados (em `repositories/`)
  - **Providers**: Gerenciamento de estado (em `providers/`)
  - **Screens**: UI organizadas por feature (em `screens/`)
  - **Widgets**: Componentes reutilizáveis (em `widgets/`)
- **DEVE** usar interfaces (`IDatabase`, `IComponentRepository`) para inversão de dependência
- **DEVE** injetar dependências via construtores (não usar singletons globais)
- **NUNCA** acessar banco de dados diretamente de Widgets ou Screens
- **NUNCA** misturar lógica de negócio com lógica de apresentação

**Justificativa:** Separação clara facilita testes, manutenção e evolução. Projetos Flutter desktop tendem a crescer em complexidade.

### VI. Gestão de Dados

**Regras Não-Negociáveis:**

- **DEVE** usar migrations versionadas para alterações de schema
- **DEVE** implementar seeders para dados iniciais/testes
- **DEVE** validar integridade referencial (foreign keys)
- **DEVE** usar transações para operações multi-step
- **DEVE** implementar backup/export (CSV, PDF) para proteção de dados do usuário
- **DEVE** normalizar texto em campos de busca (usar `normalizeText()` utility)
- **DEVE** tratar erros de banco de dados graciosamente (retornar null ou listas vazias)
- **NUNCA** deletar dados sem verificar dependências
- **NUNCA** commitar arquivos de banco de dados (.db) no repositório

**Justificativa:** Dados locais são críticos - perda de dados é inaceitável. Migrações garantem atualizações seguras.

### VII. Manutenibilidade

**Regras Não-Negociáveis:**

- **DEVE** usar variáveis de ambiente (.env) para configurações sensíveis
- **DEVE** documentar funções complexas com comentários claros
- **DEVE** seguir padrão de nomenclatura consistente em toda a base de código
- **DEVE** manter arquivos com responsabilidade única (< 300 linhas idealmente)
- **DEVE** usar padrão `copyWith` para modelos imutáveis
- **DEVE** implementar tratamento de erros em blocos try-catch-finally
- **DEVE** logar erros críticos para diagnóstico
- **NUNCA** usar hardcoded strings para queries SQL (usar constantes)
- **NUNCA** deixar código comentado no repositório (usar git history)

**Justificativa:** Código legível reduz tempo de onboarding e facilita correções. Variáveis de ambiente previnem exposição de credenciais.

## Padrões de Navegação

**Compartilhamento de Providers:**

Ao navegar entre telas que compartilham estado:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: context.read<CategoryProvider>()),
        ChangeNotifierProvider.value(value: context.read<ComponentProvider>()),
      ],
      child: const DestinationScreen(),
    ),
  ),
);
```

- **DEVE** usar `ChangeNotifierProvider.value` para reutilizar instâncias
- **DEVE** usar `_` para parâmetros não utilizados do builder
- **DEVE** usar `context.read<>()` do escopo pai, não do builder

## Gestão de Estado

**Padrão Provider:**

```dart
class MyProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Item> _items = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Item> get items => _items;

  Future<bool> loadItems() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _items = await _repository.getAll();
      return true;
    } catch (e) {
      _error = 'Erro ao carregar: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

- **DEVE** encapsular estado privado (underscore)
- **DEVE** expor apenas getters públicos
- **DEVE** retornar bool/resultado em operações assíncronas
- **DEVE** limpar erros antes de novas operações
- **DEVE** chamar `notifyListeners()` em finally

## Governança

### Conformidade com a Constituição

- **TODOS** os Pull Requests **DEVEM** verificar conformidade com esta constituição
- **TODAS** as revisões de código **DEVEM** validar aderência aos princípios
- **TODA** complexidade adicional **DEVE** ser justificada documentadamente
- **TODA** violação **DEVE** incluir justificativa e alternativas consideradas

### Processo de Emendas

- Emendas **DEVEM** ser documentadas com justificativa técnica
- Emendas **DEVEM** incluir plano de migração para código existente
- Emendas **DEVEM** atualizar versão seguindo Semantic Versioning:
  - **MAJOR**: Remoção/redefinição incompatível de princípios
  - **MINOR**: Adição de novos princípios ou seções
  - **PATCH**: Clarificações e correções

### Revisão de Compliance

- **DEVE** ser realizada antes de releases
- **DEVE** incluir checklist de todos os princípios
- **DEVE** validar que código crítico possui testes
- **DEVE** verificar performance contra metas estabelecidas

### Orientações de Runtime

Consulte `AGENTS.md` para diretrizes detalhadas de desenvolvimento e padrões específicos do Flutter/Dart.

**Versão**: 1.0.0 | **Ratificado**: 2026-01-14 | **Última Emenda**: 2026-01-14
