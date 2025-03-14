# Reporta UFOP

## 📌 Visão Geral
O **Reporta UFOP** é um aplicativo desenvolvido em **Flutter** para permitir que estudantes da Universidade Federal de Ouro Preto (UFOP) possam reportar problemas estruturais no campus. O aplicativo facilita a comunicação entre alunos e a administração da universidade para a resolução de incidentes.

## 🚀 Tecnologias Utilizadas

O projeto foi desenvolvido utilizando:

- **Flutter** – Framework principal para o desenvolvimento do aplicativo.
- **Firebase Authentication** – Gerenciamento de autenticação de usuários.
- **Firebase Storage** – Armazenamento de imagens enviadas pelos usuários.
- **Firebase Firestore** – Banco de dados NoSQL para armazenar os reportes e informações do usuário.

## 📂 Estrutura do Projeto

A estrutura de diretórios segue a arquitetura limpa:
```
lib/
│── data/
│   ├── repositories/
│   ├── models/
│── domain/
│   ├── entities/
│   ├── usecases/
│── infra/
│   ├── adapters/
│   ├── database/
│── presentation/
│   ├── controllers/
│   ├── pages/
│── ui/
│   ├── components/
│   ├── theme/
│── main.dart
```

## 📌 Funcionalidades

- **Autenticação** – Usuários podem se cadastrar e fazer login utilizando Firebase Authentication.
- **Envio de Reportes** – Os estudantes podem enviar reportes de problemas no campus.
- **Upload de Imagens** – O usuário pode anexar imagens para melhor detalhar os problemas reportados.
- **Consulta de Status** – O usuário pode visualizar o status dos reportes enviados.
- **Painel Administrativo** – Interface para os administradores gerenciarem os reportes.

## 🔧 Configuração do Projeto

### 1️⃣ Instalar as Dependências
```bash
flutter pub get
```

### 2️⃣ Configurar Firebase
1. Acesse o **Firebase Console** e crie um novo projeto.
2. Ative o **Authentication** e configure os métodos desejados.
3. Configure o **Firestore Database** e o **Firebase Storage**.
4. Baixe o arquivo `google-services.json` (Android) e `GoogleService-Info.plist` (iOS) e adicione-os às respectivas pastas.

### 3️⃣ Rodar a Aplicação
```bash
flutter run
```

## 🛠️ Bibliotecas Utilizadas

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.16.0
  firebase_storage: ^11.6.0
  get: ^4.6.6
  flutter_bloc: ^8.1.6
  image_picker: ^1.0.8
  path_provider: ^2.1.2
  permission_handler: ^11.0.1
  url_launcher: ^6.1.14
```

## 📝 Contribuindo

1. Faça um **fork** do repositório.
2. Crie uma **branch** para a sua funcionalidade (`git checkout -b minha-funcionalidade`).
3. Faça **commit** das suas alterações (`git commit -m 'Adicionando funcionalidade X'`).
4. Faça o **push** para a branch (`git push origin minha-funcionalidade`).
5. Abra um **Pull Request**.

## 📄 Licença

Este projeto está sob a licença **MIT**.
