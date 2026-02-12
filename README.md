# 📱 Tá Marcado! - Flutter App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Riverpod-000000?style=for-the-badge&logo=riverpod&logoColor=white" alt="Riverpod" />
  <img src="https://img.shields.io/badge/Go_Router-0175C2?style=for-the-badge&logo=flutter&logoColor=white" alt="GoRouter" />
</p>

## 📝 Sobre o Projeto

O **Tá Marcado!** é uma plataforma completa para agendamento de serviços, conectando clientes a profissionais de diversas áreas. Esta aplicação Flutter representa o front-end mobile, oferecendo uma experiência fluida, moderna e intuitiva para ambos os perfis de usuário.

---

## 🚀 Principais Funcionalidades

### 👥 Para Clientes
- **Busca Geolocalizada**: Encontre profissionais próximos a você.
- **Filtragem por Categoria**: Explore serviços por tipo de especialidade.
- **Agendamento em Tempo Real**: Escolha horários disponíveis e reserve instantaneamente.
- **Histórico e Avaliações**: Gerencie seus compromissos e avalie os serviços prestados.

### 💼 Para Profissionais
- **Dashboard de Gestão**: Visualize ganhos, estatísticas e próximos agendamentos.
- **Gestão de Agenda**: Aceite, recuse ou conclua serviços de forma simplificada.
- **Catálogo de Serviços**: Cadastre e gerencie os serviços oferecidos.
- **Presença Digital**: Perfil profissional com fotos, localização e avaliações.

---

## 🛠️ Stack Tecnológica

- **Framework**: [Flutter](https://flutter.dev/)
- **Linguagem**: [Dart](https://dart.dev/)
- **Gerenciamento de Estado**: [Riverpod](https://riverpod.dev/)
- **Navegação**: [GoRouter](https://pub.dev/packages/go_router)
- **Cliente HTTP**: [Dio](https://pub.dev/packages/dio)
- **Segurança**: Flutter Secure Storage (JWT)

---

## 🏗️ Arquitetura

O projeto segue os princípios de **Clean Architecture** e **Feature-First Structure**:

```text
lib/
├── core/           # Componentes globais, temas, utilitários e serviços base.
├── features/       # Módulos independentes por funcionalidade.
│   ├── auth/       # Autenticação e Gestão de Usuários.
│   ├── client/     # Funcionalidades do Cliente.
│   ├── professional/# Funcionalidades do Profissional.
│   └── shared/     # Componentes e modelos compartilhados.
├── routing/        # Configuração de rotas e guards.
└── shared/         # Widgets globais.
```

---

## 🌿 GitFlow & CI/CD Strategy

Adotamos um fluxo de trabalho profissional para garantir a estabilidade do código:

### 1. Branches Principais
- **`master`**: Código em produção (sempre estável).
- **`develop`**: Branch de integração para novas funcionalidades.
- **`task/fe-{id}-{desc}`**: Branches de desenvolvimento.

### 🚀 Esteira de Automação (GitHub Actions)
Toda interação com as branches principais dispara nosso pipeline:

| Trigger | Ações | Requisito de Merge |
| :--- | :--- | :--- |
| **Push em Task** | `flutter analyze` | Feedback rápido |
| **PR para Develop** | `Lint` + `Unit Tests` | **100% Pass** |
| **Push em Develop** | `Lint` + `Unit Tests` + `Build Check` | Notificação de falha |
| **PR para Master** | `Completa Suite de Testes` | APROVAÇÃO OBRIGATÓRIA |

### 🧪 Como rodar testes locais
```bash
# Rodar todos os testes
flutter test

# Rodar um teste específico
flutter test test/core/utils/validators_test.dart
```

---

## 🏁 Como Começar

### Pré-requisitos
- Flutter SDK (stable)
- Conexão com o [Tá Marcado API](https://github.com/ValneiPereira/tamarcado-api)

### Instalação
1. Clone este repositório.
2. `flutter pub get`
3. `flutter pub run build_runner build --delete-conflicting-outputs`
4. `flutter run`

---
<p align="center">Desenvolvido com ❤️ pela equipe Tá Marcado!</p>
