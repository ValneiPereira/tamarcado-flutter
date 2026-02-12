# Plano de Migração: Tamarcado App — React Native (Expo) → Flutter

## Contexto

O **Tá Marcado!** é um app de agendamento de serviços profissionais (beleza, saúde, educação, etc.) com dois perfis de usuário (Cliente e Profissional). Atualmente o frontend é React Native 0.74 + Expo SDK 51 + TypeScript. O backend é uma API REST em Spring Boot 3.2 / Java 21 com JWT, PostgreSQL e Redis.

**Motivação da migração:** Adotar Flutter para melhor performance nativa, UI consistente entre plataformas, e ecossistema mais maduro para apps mobile-first.

**O app React Native existente será mantido como referência/especificação.** O Flutter será um projeto novo (`tamarcado-flutter/`).

---

## Progresso

| Fase | Descrição | Status |
|------|-----------|--------|
| Fase 1 | Setup do Projeto e Infraestrutura Base | Concluída |
| Fase 2 | Tema e Design System | Concluída |
| Fase 3 | Widgets Reutilizáveis + Utilitários | Concluída |
| Fase 4 | Camada de Dados e API | Concluída |
| Fase 5 | Gerenciamento de Estado (Riverpod) | Concluída |
| Fase 6 | Fluxo de Autenticação (5 telas) | Concluída |
| Fase 7 | Fluxo do Cliente (6 telas) | Concluída |
| Fase 8 | Fluxo do Profissional (6 telas) | Concluída |
| Fase 9 | Funcionalidades de Plataforma | Concluída |
| Fase 10 | Testes | Pendente |
| Fase 11 | Build e Deploy | Pendente |

---

## Arquitetura Escolhida

- **Padrão:** Clean Architecture com organização Feature-First
- **State Management:** Riverpod (melhor testabilidade e type-safety que GetX, menos boilerplate que BLoC)
- **Roteamento:** GoRouter (suporte a guards, deep links, shell routes para tabs)
- **HTTP:** Dio (interceptors nativos para token refresh)
- **Modelos:** Dart models manuais com fromJson/toJson/copyWith
- **Armazenamento:** flutter_secure_storage (multiplataforma)

### Mapeamento de tecnologias

| React Native (atual)         | Flutter (novo)                    |
|------------------------------|-----------------------------------|
| Redux Toolkit (3 slices)     | Riverpod (StateNotifier)          |
| Expo Router (file-based)     | GoRouter (ShellRoute para tabs)   |
| Axios + interceptors         | Dio + QueuedInterceptor           |
| SecureStore / AsyncStorage   | flutter_secure_storage            |
| expo-location                | geolocator                        |
| expo-image-picker            | image_picker                      |
| expo-notifications           | firebase_messaging                |
| date-fns (pt locale)         | intl (pt_BR)                      |
| Ionicons                     | Material Icons                    |
| Custom components (7)        | Custom widgets (7)                |

---

## Estrutura de Pastas

```
tamarcado_flutter/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── config/          # api_config, cloudinary_config
│   │   ├── constants/       # app_constants, services_data (enums/categorias)
│   │   ├── errors/          # app_exception, failure
│   │   ├── network/         # dio_client (JWT interceptor com token refresh)
│   │   ├── storage/         # secure_storage
│   │   ├── theme/           # app_colors, app_typography, app_spacing, app_theme
│   │   ├── utils/           # masks, validators, formatters
│   │   └── widgets/         # app_button, app_input, app_card, app_avatar,
│   │                        # star_rating, app_badge, loading_spinner
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/  # auth_remote_datasource
│   │   │   │   └── models/       # user_model, auth_response
│   │   │   └── presentation/
│   │   │       ├── providers/    # auth_provider (AuthNotifier + AuthState)
│   │   │       └── screens/      # login, choose_type, register_client,
│   │   │                         # register_professional, forgot_password
│   │   ├── client/
│   │   │   ├── data/
│   │   │   │   ├── datasources/  # appointments, professionals, reviews
│   │   │   │   └── models/       # appointment, professional, service, review
│   │   │   └── presentation/
│   │   │       ├── providers/    # appointments_provider, professionals_provider
│   │   │       └── screens/      # (6 telas - Fase 7)
│   │   ├── professional/
│   │   │   ├── data/
│   │   │   │   ├── datasources/  # dashboard_remote_datasource
│   │   │   │   └── models/       # dashboard_stats_model
│   │   │   └── presentation/
│   │   │       └── screens/      # (6 telas - Fase 8)
│   │   └── shared/
│   │       ├── data/
│   │       │   ├── datasources/  # user, cep, cloudinary
│   │       │   └── models/       # address_model
│   │       └── presentation/
│   │           └── widgets/      # address_form
│   └── routing/
│       ├── app_router.dart       # GoRouter com auth guard + ShellRoutes
│       └── route_names.dart      # Constantes de rotas
├── test/
│   └── widget_test.dart
└── pubspec.yaml
```

---

## Fases de Implementação

### Fase 1 — Setup do Projeto e Infraestrutura Base ✅
**Complexidade: Média**

**Concluído:**
- Projeto Flutter criado com suporte Android, iOS e Web
- `pubspec.yaml` configurado com todas as dependências
- `analysis_options.yaml` configurado
- Estrutura de pastas completa criada
- `main.dart` (ProviderScope) e `app.dart` (MaterialApp.router)
- `api_config.dart` com URLs por plataforma/ambiente
- `cloudinary_config.dart` com presets e fallback
- `app_constants.dart` com constantes globais
- `services_data.dart` com todos os enums (ServiceCategory, ServiceType, AppointmentStatus, UserType, NotificationType)
- Classes de erro: `Failure` (5 tipos) e `AppException` (4 tipos)

**Dependências principais:**
```yaml
flutter_riverpod, dio, go_router, flutter_secure_storage,
cached_network_image, shimmer, geolocator, image_picker,
firebase_messaging, intl, mask_text_input_formatter
```

---

### Fase 2 — Tema e Design System ✅
**Complexidade: Baixa** | Depende de: Fase 1

**Concluído:**

| Arquivo origem (RN)     | Arquivo destino (Flutter)           |
|--------------------------|-------------------------------------|
| `src/theme/colors.ts`    | `core/theme/app_colors.dart`        |
| `src/theme/typography.ts`| `core/theme/app_typography.dart`    |
| `src/theme/spacing.ts`   | `core/theme/app_spacing.dart`       |
| (novo)                   | `core/theme/app_theme.dart`         |

**Paleta principal:**
- Primary: `#1E3A8A` | Success: `#10B981` | Error: `#EF4444` | Warning: `#F59E0B`
- Background: `#F9FAFB` | Surface: `#FFFFFF` | Star: `#FFD700`

---

### Fase 3 — Widgets Reutilizáveis + Utilitários ✅
**Complexidade: Média** | Depende de: Fase 2

**7 widgets migrados:**

| Componente RN       | Widget Flutter      | Detalhes                                         |
|----------------------|---------------------|-------------------------------------------------|
| `Button.tsx`         | `AppButton`         | 4 variantes (primary/secondary/outline/ghost), 3 tamanhos, loading state |
| `Input.tsx`          | `AppInput`          | Label, erro, ícones L/R, toggle senha, focus state |
| `Card.tsx`           | `AppCard`           | 3 variantes (default/elevated/outlined), onPress opcional |
| `Avatar.tsx`         | `AppAvatar`         | 5 tamanhos (32-120px), imagem/iniciais/fallback  |
| `StarRating.tsx`     | `StarRating`        | Display + interativo, meia estrela, contagem     |
| `Badge.tsx`          | `AppBadge`          | 5 cores (primary/success/warning/error/neutral)  |
| `LoadingSpinner.tsx` | `LoadingSpinner`    | Fullscreen ou inline, texto opcional             |

**3 utilitários migrados:**

| Arquivo origem        | Arquivo destino          | Funções                                           |
|-----------------------|--------------------------|---------------------------------------------------|
| `masks.ts`            | `core/utils/masks.dart`  | maskPhone, maskCep, maskCpf, maskCnpj, maskCurrency, unmask |
| `validators.ts`       | `core/utils/validators.dart` | isValidEmail, isValidCpf, isValidPhone, isValidCep, isValidPassword, isValidName |
| `formatters.ts`       | `core/utils/formatters.dart` | formatDate, formatCurrency (R$), formatDistance, formatStatus, getInitials, getServiceIcon |

---

### Fase 4 — Camada de Dados e API ✅
**Complexidade: Alta** | Depende de: Fase 1

**4.1 — Cliente HTTP (Dio)** ✅

Implementado em `core/network/dio_client.dart`:
- Request interceptor: injeta `Authorization: Bearer <token>`
- Response interceptor: em 401, faz refresh automático via `/auth/refresh-token`
- Flag `_isRefreshing` + `_failedQueue` com `Completer<void>` para fila de requisições
- Logout automático se refresh falhar (callback `onLogout`)
- Dio separado para refresh (evita loop do interceptor)

**4.2 — Modelos Dart** ✅

| Interface TS            | Model Dart                    | Feature     |
|-------------------------|-------------------------------|-------------|
| User, Client            | `UserModel`                   | auth        |
| Professional            | `ProfessionalModel`           | client      |
| Address                 | `AddressModel`                | shared      |
| Service                 | `ServiceModel`                | client      |
| Appointment             | `AppointmentModel`            | client      |
| Review                  | `ReviewModel`                 | client      |
| AuthResponse            | `AuthResponse`                | auth        |
| DashboardStats          | `DashboardStatsModel`         | professional|

**4.3 — Remote Datasources** ✅

| Service TS                 | Datasource Dart                 | Endpoints                               |
|----------------------------|---------------------------------|-----------------------------------------|
| `auth.service.ts`          | `AuthRemoteDatasource`          | login, register/client, register/professional, refresh, forgotPassword |
| `user.service.ts`          | `UserRemoteDatasource`          | getProfile, updateProfile, updatePhoto, changePassword, deleteAccount |
| `appointments.service.ts`  | `AppointmentsRemoteDatasource`  | CRUD appointments, accept/reject/complete |
| `professionals.service.ts` | `ProfessionalsRemoteDatasource` | search, getById, services CRUD          |
| `reviews.service.ts`       | `ReviewsRemoteDatasource`       | createReview, getProfessionalReviews    |
| `cep.service.ts`           | `CepRemoteDatasource`           | lookupCep (backend + ViaCEP fallback)   |
| `cloudinary.service.ts`    | `CloudinaryDatasource`          | upload (base64 + fallback presets)      |
| (novo)                     | `DashboardRemoteDatasource`     | getProfessionalStats, getClientStats    |

**4.4 — Secure Storage** ✅

`flutter_secure_storage` com API unificada para tokens e dados do usuário.

---

### Fase 5 — Gerenciamento de Estado (Riverpod) ✅
**Complexidade: Alta** | Depende de: Fase 4

**Providers implementados:**

| Redux Slice                   | Riverpod Provider                | Descrição                                |
|-------------------------------|----------------------------------|------------------------------------------|
| `authSlice.ts` + `useAuth.ts` | `AuthNotifier` (StateNotifier)   | user, isAuthenticated, login/logout/register |
| `appointmentsSlice.ts`        | `AppointmentsNotifier`           | lista de agendamentos, filtro por status |
| `professionalsSlice.ts`       | `ProfessionalSearchNotifier` + `ProfessionalsListNotifier` | busca (step/category/sort) + lista paginada |

**Roteamento (GoRouter)** ✅

| Rota Expo Router                       | Rota GoRouter                     |
|----------------------------------------|-----------------------------------|
| `app/index.tsx`                        | `/` (LoginScreen)                 |
| `app/choose-type.tsx`                  | `/choose-type`                    |
| `app/register-client.tsx`              | `/register-client`                |
| `app/register-professional.tsx`        | `/register-professional`          |
| `app/forgot-password.tsx`              | `/forgot-password`                |
| `app/(client)/home.tsx`                | `/client/home` (ShellRoute)       |
| `app/(client)/appointments.tsx`        | `/client/appointments`            |
| `app/(client)/profile.tsx`             | `/client/profile`                 |
| `app/(client)/edit-profile.tsx`        | `/client/profile/edit`            |
| `app/(client)/addresses.tsx`           | `/client/profile/addresses`       |
| `app/(client)/change-password.tsx`     | `/client/profile/change-password` |
| `app/(professional)/dashboard.tsx`     | `/professional/dashboard` (ShellRoute) |
| `app/(professional)/appointments.tsx`  | `/professional/appointments`      |
| `app/(professional)/profile.tsx`       | `/professional/profile`           |
| `app/(professional)/edit-profile.tsx`  | `/professional/profile/edit`      |
| `app/(professional)/address.tsx`       | `/professional/profile/address`   |
| `app/(professional)/change-password.tsx`| `/professional/profile/change-password` |

Guard de autenticação: redireciona para `/` se não autenticado, e para `/client/home` ou `/professional/dashboard` se já autenticado (baseado em `userType`).

---

### Fase 6 — Fluxo de Autenticação (5 telas) ✅
**Complexidade: Alta** | Depende de: Fases 3, 4, 5

| Tela                     | Arquivo Flutter                              | Destaques                              |
|--------------------------|----------------------------------------------|----------------------------------------|
| Login                    | `auth/presentation/screens/login_screen.dart` | Header estilizado, email/senha, loading, auto-redirect |
| Escolha de Tipo          | `auth/presentation/screens/choose_type_screen.dart` | 2 cards (Cliente/Profissional) com ícones |
| Registro Cliente         | `auth/presentation/screens/register_client_screen.dart` | Dados pessoais + AddressForm com busca CEP |
| Registro Profissional    | `auth/presentation/screens/register_professional_screen.dart` | Dados + dropdowns categoria/tipo + serviços dinâmicos + endereço |
| Esqueci a Senha          | `auth/presentation/screens/forgot_password_screen.dart` | Header primary, validação email, dialog de sucesso |

**Widget reutilizável extraído:** `AddressForm` em `shared/presentation/widgets/address_form.dart`
- 7 campos com controllers
- Auto-preenchimento via CEP (backend + ViaCEP fallback)
- Loading indicator durante busca
- Máscara CEP + uppercase no estado

---

### Fase 7 — Fluxo do Cliente (6 telas) ✅
**Complexidade: Alta** | Depende de: Fase 6

| Tela                 | Referência RN                        | Destaques                                     |
|----------------------|--------------------------------------|-----------------------------------------------|
| Home                 | `app/(client)/home.tsx`              | Busca em 3 steps: categoria → tipo → profissionais (com distância/rating) |
| Agendamentos         | `app/(client)/appointments.tsx`      | 2 tabs (Próximos/Histórico), cancelar, avaliar |
| Perfil               | `app/(client)/profile.tsx`           | Menu: editar, endereço, senha, sair, excluir   |
| Editar Perfil        | `app/(client)/edit-profile.tsx`      | Upload foto (Cloudinary), nome, telefone, endereço |
| Endereços            | `app/(client)/addresses.tsx`         | Visualizar/editar endereço                     |
| Alterar Senha        | `app/(client)/change-password.tsx`   | Senha atual + nova + confirmação               |

**Tab navigation:** `StatefulShellRoute.indexedStack` com `BottomNavigationBar` — 3 tabs visíveis (Home, Agendamentos, Perfil), 3 telas aninhadas.

---

### Fase 8 — Fluxo do Profissional (6 telas) ✅
**Complexidade: Alta** | Depende de: Fase 7 (reutiliza widgets)

| Tela                 | Referência RN                              | Destaques                                   |
|----------------------|--------------------------------------------|---------------------------------------------|
| Dashboard            | `app/(professional)/dashboard.tsx`         | Stats cards (pendentes, concluídos, rating, receita R$), próximos agendamentos |
| Agendamentos         | `app/(professional)/appointments.tsx`      | 3 tabs (Pendentes/Confirmados/Histórico), aceitar/recusar/concluir |
| Perfil               | `app/(professional)/profile.tsx`           | Menu: editar, serviços, horários, endereço, sair |
| Editar Perfil        | `app/(professional)/edit-profile.tsx`      | Foto + dados + gestão de serviços (add/edit/delete) |
| Endereço             | `app/(professional)/address.tsx`           | Visualizar endereço de atendimento          |
| Alterar Senha        | (reutiliza widget do cliente)              | Mesmo widget                                |

---

### Fase 9 — Funcionalidades de Plataforma ✅
**Complexidade: Alta** | Depende de: Fases 7, 8

| Feature           | Pacote Flutter              | Implementação |
|-------------------|-----------------------------|----------------|
| Geolocalização    | `geolocator`                | `client_home_screen`: permissão + `getCurrentPosition()`. `core/utils/location_utils.dart`: Haversine `distanceKm()`. |
| Image Picker      | `image_picker`              | Telas de edição de perfil (cliente/profissional) + `CloudinaryDatasource`. |
| Upload Cloudinary | Dio + Cloudinary API        | `shared/data/datasources/cloudinary_datasource.dart`. |
| Busca CEP         | Dio (backend + ViaCEP)      | `shared/data/datasources/cep_remote_datasource.dart` + `AddressForm`. |
| Push Notifications| `firebase_messaging`        | `main.dart`: Firebase init. `push_notification_service.dart`: token + POST `/notifications/register-device`. Registro ao autenticar em `app.dart`. |
| Máscaras de input | `mask_text_input_formatter` | `core/utils/masks.dart`: phone, CEP, CPF, CNPJ, currency. Usado em formulários. |
| Permissões        | Android/iOS nativos         | `AndroidManifest.xml`: INTERNET, ACCESS_FINE_LOCATION, CAMERA, POST_NOTIFICATIONS. `Info.plist`: NSLocationWhenInUseUsageDescription, NSCameraUsageDescription, NSPhotoLibraryUsageDescription. |

---

### Fase 10 — Testes ⏳
**Complexidade: Média** | Depende de: todas as fases anteriores

| Tipo        | O que testar                                           | Cobertura alvo |
|-------------|-------------------------------------------------------|----------------|
| Unitário    | validators, masks, formatters, models (JSON), usecases | 90%+           |
| Unitário    | Providers (auth, appointments, professionals)          | 80%+           |
| Widget      | 7 widgets reutilizáveis + telas principais             | 80%+           |
| Integração  | Fluxo login, registro, busca, agendamento              | 60%+           |

---

### Fase 11 — Build e Deploy ⏳
**Complexidade: Média** | Depende de: todas as fases anteriores

- **Android:** Configurar signing, permissões (LOCATION, CAMERA, INTERNET), Firebase (`google-services.json`)
- **iOS:** Info.plist (permissões), Firebase (`GoogleService-Info.plist`), Apple Developer signing
- **Web:** `flutter build web`, deploy em hosting (AWS/Vercel/Firebase)
- **CI/CD:** GitHub Actions para testes + build automático
- **Variáveis de ambiente:** `--dart-define=API_URL=...`

---

## Riscos e Mitigações

| Risco | Severidade | Mitigação |
|-------|------------|-----------|
| Interceptor de token refresh com fila no Dio | Alta | Implementado com `Completer<void>` + Dio separado para refresh |
| Upload Cloudinary cross-platform | Média | `XFile.readAsBytes()` + base64 (funciona em todas as plataformas) |
| Navegação pós-logout (limpar pilha) | Média | `GoRouter.go('/')` substitui toda a pilha; guard redireciona automaticamente |
| Secure storage no Web (localStorage) | Média | Manter mesmo nível do app atual; considerar HttpOnly cookies futuramente |
| Diferenças visuais Material vs RN | Baixa | Customizado via ThemeData para aproximar do design original |

---

## Arquivos de Referência (app React Native)

Os 5 arquivos mais importantes consultados durante a migração:

1. **`src/api/client.ts`** — Lógica do HTTP client com token refresh e fila
2. **`src/types/index.ts`** — Todos os tipos/interfaces (contrato com a API)
3. **`src/hooks/useAuth.ts`** — Fluxo completo de autenticação
4. **`app/(client)/home.tsx`** — Tela mais complexa (busca 3 steps + geo + sort)
5. **`src/services/cloudinary.service.ts`** — Upload multi-plataforma com fallback

---

## Ordem de Execução

```
Fase 1 (Setup) ──→ Fase 2 (Tema) ──→ Fase 3 (Widgets/Utils)
      │                                        │
      └──→ Fase 4 (Dados/API) ──→ Fase 5 (Estado/Rotas) ──→ Fase 6 (Auth) ✅
                                                                   │
                                              Fase 7 (Cliente) ←───┘  ✅
                                                   │
                                              Fase 8 (Profissional) ✅
                                                   │
                                              Fase 9 (Plataforma) ✅
                                                   │
                                              Fase 10 (Testes) ──→ Fase 11 (Deploy) ⏳
```

> **Nota:** Fases 1-9 concluídas. Próximo: Fase 10 (Testes).
