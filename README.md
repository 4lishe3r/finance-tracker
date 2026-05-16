# Finance Tracker

A personal finance tracking application built with Flutter as a final project.

## About

Finance Tracker helps you manage personal finances with budget tracking, currency conversion, and shared household expenses.

## Features

- **Dashboard** — monthly budget overview, spending pie chart by category, recent transactions
- **Expenses** — expense list grouped by month, category filter, swipe to delete, edit support
- **Budget** — set monthly budget limit, 6-month spending bar chart
- **Currency Converter** — real-time currency conversion (160+ currencies including KZT, RUB)
- **Shared Expenses** — household expense sharing via Firestore, real-time sync
- **Settings** — theme toggle (light/dark/system), default currency, username

## Tech Stack

| Layer | Technology |
|---|---|
| Navigation | `go_router` |
| State Management | `Riverpod` |
| Local Database | `Drift` (SQLite) |
| Lightweight Storage | `Shared Preferences` |
| Networking | `Chopper` + ExchangeRate API |
| Cloud | `Firebase Firestore` |
| Charts | `fl_chart` |

## Architecture

The project follows Clean Architecture principles:

```
lib/
├── core/              # Constants, themes
├── data/
│   ├── datasources/   # Drift, Chopper, Firestore
│   ├── models/        # JSON models
│   └── repositories/  # Repository implementations
├── domain/
│   ├── entities/      # Domain entities
│   └── repositories/  # Abstract interfaces
├── providers/         # Riverpod providers
└── ui/
    ├── router/        # go_router configuration
    ├── screens/       # App screens
    └── widgets/       # Reusable widgets
```

## Setup & Installation

### 1. Clone the repository

```bash
git clone https://github.com/<your-repo>/finance_tracker.git
cd finance_tracker
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This will generate `lib/firebase_options.dart` automatically.

### 4. Generate code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Run the app

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android
```

## Team

| Member | Contribution |
|---| Zhalgas, Alisher |
| — | Architecture, Riverpod, Drift |
| — | UI, navigation, themes |
| — | Firebase, Chopper, currency converter |

## Demo

> Link to video demo
https://youtu.be/3zZ3h_QZg18