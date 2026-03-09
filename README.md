# Gestão Rural App (Flutter MVVM)

## Árvore de diretórios

`	ext
lib/
  app/
    app.dart
    router.dart
  core/
    constants/
    errors/
    network/
      interceptors/
    storage/
    theme/
    utils/
    widgets/
  data/
    datasources/
    mappers/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    modules/
      auth/
      dashboard/
      farms/
      fields/
      crops/
      seasons/
      operations/
      machines/
      machine_records/
      financial/
      ai/
      satellite/
      settings/
    shared/
      states/
      viewmodels/
      widgets/
test/
`

## Arquitetura MVVM

- **View (presentation/modules/...)**: renderização, componentes e interação do usuário.
- **ViewModel (..._viewmodel.dart)**: orquestra estado, chama UseCases e adapta dados para UI.
- **State (..._state.dart + ViewState)**: status previsível (idle/loading/success/error).
- **Domain**: entidades puras, contratos de repositório e casos de uso.
- **Data**: implementação de repositórios, datasources remotos e models de API.
- **Core**: cross-cutting concerns (tema, rede, storage seguro, erros, widgets base).

## Navegação (go_router)

Fluxo:
- / splash
- /login
- /dashboard
- módulos de negócio:
  - /farms, /fields, /crops, /seasons, /operations
  - /machines, /machine-records, /financial
  - /ai, /satellite, /settings

## Autenticação JWT

- Login: POST /api/auth/login
- Refresh: POST /api/auth/refresh
- Sessão: GET /api/auth/me

### Estratégia

- Tokens salvos em SharedPreferences.
- AuthInterceptor injeta Authorization: Bearer.
- RefreshTokenInterceptor tenta renovar sessão ao receber 401 e repete a request.
- Splash tenta restaurar sessão e redireciona para login/dashboard.

## Módulos contemplados

- Auth, Dashboard, Fazendas, Talhões, Culturas, Safras, Operações, Máquinas,
  Registros de Máquinas, Financeiro, IA, Satélite e Configurações.

## Testes base

- parsing/model (AuthSessionModel)
- unit de ViewModel (AuthViewModel)
