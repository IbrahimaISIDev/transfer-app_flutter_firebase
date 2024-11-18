# Money Transfer App

## Description
Application mobile de transfert d'argent développée avec Flutter, GetX et Firebase.

## Fonctionnalités
- Authentification utilisateur
- Transferts d'argent
- Gestion des transactions
- Interface client et distributeur

## Prérequis
- Flutter SDK
- Dart
- Firebase Account

## Installation
1. Cloner le dépôt
2. Installer les dépendances : `flutter pub get`
3. Configurer Firebase
4. Lancer l'application : `flutter run`

## Technologies
- Flutter
- GetX
- Firebase
- Dart

## Licence
[Choisir une licence]

################################################################################################################################################

# Configuration Environnement de Développement

## Prérequis
- Flutter SDK
- Dart SDK
- Visual Studio Code
- Extensions VSCode
- Firebase CLI
- GetX CLI

## Étapes d'installation

### 1. Installation des SDK
```bash
# Installer Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:[PATH_TO_FLUTTER_GIT_DIRECTORY]/flutter/bin"

# Installer Dart 
sudo apt-get update
sudo apt-get install dart

# Vérifier les installations
flutter doctor
dart --version
```

### 2. Configuration VSCode
Extensions recommandées :
- Flutter
- Dart
- GetX Snippets
- Firebase Extension

### 3. Installation des CLI
```bash
# Installer GetX CLI
dart pub global activate getx_cli

# Installer Firebase CLI
curl -sL https://firebase.tools | bash
firebase login
```

### 4. Création du projet
```bash
# Créer un nouveau projet Flutter avec GetX
getx create my_money_transfer_app
cd my_money_transfer_app

# Configuration Firebase
flutterfire configure
```

### Configuration initiale pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.5
  firebase_core: ^latest_version
  firebase_auth: ^latest_version
  cloud_firestore: ^latest_version
```