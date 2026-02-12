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
- **Perfil Personalizado**: Edição de fotos, endereços e dados pessoais.

### 💼 Para Profissionais
- **Dashboard de Gestão**: Visualize ganhos, estatísticas e próximos agendamentos.
- **Gestão de Agenda**: Aceite, recuse ou conclua serviços de forma simplificada.
- **Catálogo de Serviços**: Cadastre e gerencie os serviços oferecidos e seus respectivos preços.
- **Presença Digital**: Perfil profissional com fotos, localização e avaliações de clientes.

---

## 🛠️ Stack Tecnológica

- **Framework**: [Flutter](https://flutter.dev/)
- **Linguagem**: [Dart](https://dart.dev/)
- **Gerenciamento de Estado**: [Riverpod](https://riverpod.dev/)
- **Navegação**: [GoRouter](https://pub.dev/packages/go_router)
- **Cliente HTTP**: [Dio](https://pub.dev/packages/dio)
- **Segurança**: Flutter Secure Storage (JWT)
- **Design System**: Material 3 com temas personalizados.

---

## 🏗️ Arquitetura

O projeto segue os princípios de **Clean Architecture** e **Feature-First Structure**, organizando o código para alta escalabilidade e testabilidade:

```text
lib/
├── core/           # Componentes globais, temas, utilitários e serviços base.
├── features/       # Módulos independentes por funcionalidade.
│   ├── auth/       # Autenticação e Gestão de Usuários.
│   ├── client/     # Funcionalidades exclusivas do Cliente.
│   ├── professional/# Funcionalidades exclusivas do Profissional.
│   └── shared/     # Componentes e modelos compartilhados entre features.
├── routing/        # Configuração de rotas e guards de autenticação.
└── shared/         # Widgets e constantes globais da UI.
```

---

## 🏁 Como Começar

### Pré-requisitos
- Flutter SDK (versão estável mais recente)
- Conexão com o [Tá Marcado API](https://github.com/ValneiPereira/tamarcado-api)

### Instalação
1. Clone este repositório.
2. Navegue até a pasta do projeto:
   ```bash
   cd tamarcado-flutter
   ```
3. Instale as dependências:
   ```bash
   flutter pub get
   ```
4. Gere os modelos e providers (se necessário):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
5. Inicie a aplicação:
   ```bash
   flutter run
   ```

---

## ⚖️ Estratégias de Desenvolvimento

Para detalhes sobre como contribuir, gerenciar branches e como nossa esteira de testes funciona, consulte:
- [🌿 Estratégia de Branches & Commits](../tamarcado-api/docs/BRANCH_STRATEGY.md)
- [🔄 Estratégia de GitFlow e Testes](GITFLOW_STRATEGY.md)

---

## 📄 Licença

Este projeto está sob a licença do proprietário. Consulte os termos de uso para mais detalhes.

---
<p align="center">Desenvolvido com ❤️ pela equipe Tá Marcado!</p>
