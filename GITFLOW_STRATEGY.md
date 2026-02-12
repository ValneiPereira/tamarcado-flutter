# 🔄 Estratégia de CI/CD e GitFlow (Flutter)

Este documento define o fluxo de trabalho Git e a automação de testes (CI/CD) para o projeto `tamarcado-flutter`.

## 🌿 GitFlow - Estratégia de Branches

Adotamos uma versão simplificada do GitFlow, alinhada com o backend:

### 1. Branches Principais
- **`master`** (ou `main`): Código em produção. Protegida.
- **`develop`**: Código em fase de integração e homologação. Protegida.

### 2. Branches de Trabalho
- **`task/fe-{numero}-{descricao}`**: Para novas funcionalidades e correções.
  - Ex: `task/fe-001-login-logic`
  - Criar sempre a partir da `develop`.

---

## 🧪 Estratégia de Testes e CI/CD

Para otimizar o tempo de desenvolvimento local, a execução dos testes unitários e de widget será centralizada na esteira de integração contínua (CI).

### 🚀 Fluxo da Esteira (GitHub Actions / GitLab CI)

#### 1. Em Branches de Task
- **Ações**: Apenas lint (análise estática).
- **Objetivo**: Feedback rápido para o desenvolvedor sobre o estilo do código.

#### 2. Em Pull Requests para `develop`
- **Ações**: 
  1. `flutter analyze` (Lint)
  2. `flutter test` (Testes Unitários e de Widget)
- **Bloqueio**: O merge para `develop` só é permitido se **todos os testes passarem**.

#### 3. Em `develop` e `master`
- **Ações**: Execução completa da suite de testes.
- **Deploy**: Se os testes passarem em `master`, inicia-se o processo de build para as lojas (Android/iOS).

---

## 📝 Convenções de Commit

Mantemos o padrão já estabelecido:
`[TASK-FE-XXX] tipo(escopo): descrição curta`

### Regra de Ouro:
> **Testes locais são recomendados, mas a validação obrigatória ocorre apenas na esteira (CI) ao atingir as branches `develop` e `master`.**

---

## 🛠️ Exemplo de Configuração CI (Pseudo-code)

```yaml
# .github/workflows/ci.yml
on:
  push:
    branches: [ develop, master ]
  pull_request:
    branches: [ develop ]

jobs:
  test:
    runs-with: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test  # Executado apenas nestas branches/PRs
```
