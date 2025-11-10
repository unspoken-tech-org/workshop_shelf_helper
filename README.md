# Organizador de Oficina

Aplicativo Flutter para Windows para gerenciamento de estoque de componentes eletrônicos.

## Funcionalidades

### Gestão de Categorias
- Criar, editar e excluir categorias de componentes
- Categorias dinâmicas gerenciadas pelo usuário
- Interface intuitiva para organização

### Gestão de Componentes
- Cadastro completo de componentes eletrônicos com:
  - Modelo do componente
  - Quantidade em estoque
  - Localização (ex: cx01, cx02, cx03)
  - Polaridade (ex: NPN, PNP)
  - Encapsulamento (ex: TO-92)
  - Custo unitário
  - Observações
- Busca e filtros avançados
- Visualização organizada por categoria

### Relatórios e Estatísticas
- Dashboard com estatísticas gerais
- Relatório de estoque por categoria
- Identificação de componentes com baixo estoque
- Valor total investido no estoque

### Exportação de Dados
- Exportação para CSV (lista completa de componentes)
- Exportação para PDF (relatório completo formatado)

## Tecnologias Utilizadas

- **Flutter**: Framework para desenvolvimento desktop
- **SQLite**: Banco de dados local (sqflite_common_ffi)
- **Provider**: Gerenciamento de estado com ChangeNotifierProvider
- **Material Design 3**: Interface moderna e intuitiva

## Dependências

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1          # Gerenciamento de estado
  sqflite_common_ffi: ^2.3.0 # SQLite para desktop
  path_provider: ^2.1.1     # Gerenciamento de arquivos
  path: ^1.8.3
  pdf: ^3.10.7              # Geração de PDFs
  csv: ^6.0.0               # Exportação CSV
  intl: ^0.19.0             # Formatação de datas e valores
```

## Como Executar

### Pré-requisitos
- Flutter SDK instalado
- Windows 10 ou superior

### Instalação

1. Clone o repositório:
```bash
git clone <url-do-repositorio>
cd app-organizador-oficina
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o aplicativo:
```bash
flutter run -d windows
```

### Build para Produção

Para criar um executável para Windows:

```bash
flutter build windows --release
```

O executável estará em: `build/windows/runner/Release/`

## Estrutura do Projeto

```
lib/
├── database/
│   └── database_helper.dart      # Helper do SQLite
├── models/
│   ├── categoria.dart            # Model de Categoria
│   └── componente.dart           # Model de Componente
├── providers/
│   ├── categoria_provider.dart   # Provider de Categorias
│   └── componente_provider.dart  # Provider de Componentes
├── screens/
│   ├── home_screen.dart          # Tela principal com dashboard
│   ├── categorias/
│   │   ├── categorias_list_screen.dart
│   │   └── categoria_form_screen.dart
│   ├── componentes/
│   │   ├── componentes_list_screen.dart
│   │   └── componente_form_screen.dart
│   └── relatorios/
│       └── relatorios_screen.dart
├── services/
│   └── export_service.dart       # Serviço de exportação
├── widgets/
│   ├── confirmar_dialog.dart     # Dialog de confirmação
│   ├── custom_card.dart          # Card personalizado
│   └── custom_text_field.dart    # Campo de texto customizado
└── main.dart                     # Ponto de entrada da aplicação
```

## Banco de Dados

O aplicativo utiliza SQLite com duas tabelas principais:

### Tabela `categorias`
- `id`: INTEGER PRIMARY KEY
- `nome`: TEXT NOT NULL
- `descricao`: TEXT

### Tabela `componentes`
- `id`: INTEGER PRIMARY KEY
- `categoria_id`: INTEGER (Foreign Key)
- `modelo`: TEXT NOT NULL
- `quantidade`: INTEGER
- `localizacao`: TEXT
- `polaridade`: TEXT
- `encapsulamento`: TEXT
- `custo_unitario`: REAL
- `observacao`: TEXT

## Recursos do Aplicativo

### Dashboard
- Visão geral do estoque
- Estatísticas em tempo real
- Acesso rápido às funcionalidades

### Busca e Filtros
- Busca por modelo ou localização
- Filtro por categoria
- Ordenação personalizada

### Validações
- Campos obrigatórios validados
- Formato de valores monetários
- Confirmação antes de exclusões

### Experiência do Usuário
- Interface responsiva
- Feedback visual para ações
- Pull-to-refresh nas listagens
- Navegação intuitiva com drawer

## Licença

Este projeto foi desenvolvido para fins educacionais e de uso pessoal.

## Autor

Desenvolvido com Flutter 💙
