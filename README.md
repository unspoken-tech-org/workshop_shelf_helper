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
- **flutter_dotenv**: Gerenciamento de variáveis de ambiente

## Configuração de Ambiente

O aplicativo utiliza variáveis de ambiente para configurações sensíveis e específicas do ambiente. Um arquivo `.env.example` é fornecido como template.

### Variáveis Disponíveis

- `GITHUB_OWNER`: Nome do usuário ou organização do GitHub (usado para verificação de atualizações)
- `GITHUB_REPO`: Nome do repositório no GitHub


### Como Configurar

1. Copie o arquivo `.env.example` para `.env`:
   ```bash
   copy .env.example .env
   ```

2. Edite o arquivo `.env` e preencha as variáveis com suas informações:
   ```env
   GITHUB_OWNER=seu-usuario-github
   GITHUB_REPO=app-organizador-oficina
   ```

**Importante**: O arquivo `.env` não é versionado no Git para proteger informações sensíveis.

## Dependências

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1           # Gerenciamento de estado
  sqflite_common_ffi: ^2.3.0 # SQLite para desktop
  path_provider: ^2.1.1      # Gerenciamento de arquivos
  path: ^1.8.3
  pdf: ^3.10.7               # Geração de PDFs
  csv: ^6.0.0                # Exportação CSV
  intl: ^0.19.0              # Formatação de datas e valores
  flutter_dotenv: ^5.2.1     # Variáveis de ambiente
  dio: ^5.4.0                # Cliente HTTP
  url_launcher: ^6.2.0       # Abrir URLs
  package_info_plus: ^9.0.0  # Informações do pacote
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

2. Configure as variáveis de ambiente:
```bash
# Copie o arquivo de exemplo
copy .env.example .env

# Edite o arquivo .env e adicione suas configurações:
# GITHUB_OWNER=seu-usuario-github
# GITHUB_REPO=app-organizador-oficina
```

3. Instale as dependências:
```bash
flutter pub get
```

4. Execute o aplicativo:
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
├── config/
│   └── env_config.dart           # Configurações de ambiente
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
│   ├── export_service.dart       # Serviço de exportação
│   └── update_service.dart       # Serviço de atualização
├── widgets/
│   ├── confirmar_dialog.dart     # Dialog de confirmação
│   ├── custom_card.dart          # Card personalizado
│   ├── custom_text_field.dart    # Campo de texto customizado
│   └── update_dialog.dart        # Dialog de atualização
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
