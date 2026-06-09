# Decibel - Aplicação de Música e Avaliações

Bem-vindo ao **Decibel**, uma aplicação Flutter para descobrir, avaliar e partilhar músicas com a comunidade!

## Sobre o Projeto

Decibel é uma aplicação móvel desenvolvida em Flutter que permite aos utilizadores:
- Criar contas e fazer login
- Pesquisar e descobrir músicas e artistas
- Criar e gerir playlists pessoais
- Escrever e ler avaliações sobre músicas
- Ver perfis de artistas com histórico de imagens
- Receber notificações de atividades
- Partilhar avaliações com a comunidade

**Repositório:** https://github.com/2024152576/projeto_cm_grupo13_pl1/

**Design:** https://www.figma.com/design/bOwfVptOoBbDYNKkJziFw4/Decibel?node-id=0-1&t=CzxCQDy1XlNeMd8Q-1

---

## Funcionalidades Principais

### Autenticação
- Criar nova conta com email e senha
- Login com autenticação Firebase
- Recuperação de senha
- Logout seguro

### Exploração de Música
- Homepage com recomendações
- Pesquisa de músicas
- Pesquisa de artistas
- Página de detalhes de artista com imagens
- Página de detalhes da música

### Playlists
- Criar playlists pessoais
- Adicionar/remover músicas de playlists
- Ver detalhes da playlist
- Gerir playlists

### Avaliações
- Escrever avaliações sobre músicas
- Atribuir classificação em estrelas
- Ver avaliações de outros utilizadores
- Gostar/desgostar avaliações
- Comentários em avaliações

### Perfil de Utilizador
- Visualizar perfil pessoal
- Ver histórico de artistas favoritos
- Ver músicas avaliadas
- Gerir definições de conta

### Notificações
- Notificações locais em tempo real
- Alertas de novos comentários
- Notificações de atividade

---

## Pré-requisitos

Antes de instalar, certifique-se que tem instalado:

- **Flutter SDK** (versão 3.11.5 ou superior)
  - [Instalar Flutter](https://docs.flutter.dev/get-started/install)
- **Dart** (incluído com Flutter)
- **Git**
- **Android Studio** (para desenvolvimento Android) ou **VS Code**
- Uma conta **Firebase** configurada

### Dependências Principais
- firebase_core: ^2.27.0
- firebase_auth: ^4.17.8
- cloud_firestore: ^4.15.1
- flutter_local_notifications: ^19.0.0
- http: ^1.6.0
- intl: ^0.20.2

---

## Instalação

### 1. Clonar o Repositório

```bash
git clone https://github.com/2024152576/projeto_cm_grupo13_pl1.git
cd projeto_cm_grupo13_pl1
```

### 2. Configurar o Flutter

Verifique se o Flutter está devidamente instalado:

```bash
flutter doctor
```

Resolva qualquer problema indicado pelo comando acima.

### 3. Instalar Dependências

```bash
flutter pub get
```

Este comando vai descarregar todas as dependências necessárias definidas no ficheiro `pubspec.yaml`.

### 4. Executar em Dispositivo/Emulador

**VS Code:**
Iniciar o emulador e no ficheiro main, clicar na opção "Start Debugging".

**Android Studio:**
Iniciar o emulador e clicar no botão verde de execução do programa.

---

## Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada da aplicação
├── firebase_options.dart        # Configuração Firebase
├── models/                      # Modelos de dados
│   ├── music.dart
│   ├── playlist_model.dart
│   ├── review_model.dart
│   └── user_model.dart
├── Screens/                     # Ecrãs da aplicação
│   ├── splash_screen.dart
│   ├── login.dart
│   ├── create_account_screen.dart
│   ├── homepage.dart
│   ├── music_page.dart
│   ├── artist_page.dart
│   ├── playlist_detail_screen.dart
│   ├── create_playlist_screen.dart
│   ├── write_review.dart
│   ├── review_detail_screen.dart
│   ├── user_profile_screen.dart
│   ├── settings_screen.dart
│   └── album_page.dart
├── services/                    # Serviços (API, BD, autenticação)
│   ├── auth_service.dart
│   ├── database_service.dart
│   ├── lastFM_service.dart
│   ├── artist_image_service.dart
│   └── notification_service.dart
└── widgets/                     # Componentes reutilizáveis
    └── review_like_button.dart
```

---

## Troubleshooting

### "Flutter not found"
- Adicione Flutter ao PATH do seu sistema
- Execute `flutter doctor` para verificar a instalação

### Hot reload não funciona
- Reinicie o emulador/dispositivo
- Execute `flutter run` novamente

### Problemas de dependências
```bash
flutter clean
flutter pub get
flutter run
```

---

## Equipa

Projeto desenvolvido pelo **Grupo 13** - Projeto Computação Móvel

---

## Recursos Úteis

- [Documentação Flutter](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Last.fm API](https://www.last.fm/api)
- [Flutter Best Practices](https://docs.flutter.dev/style-guide)

---

## Licença

Este projeto é de código aberto e está disponível no GitHub.

