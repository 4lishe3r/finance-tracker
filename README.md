# Finance Tracker

A personal finance tracking application built with Flutter as a final project, demonstrating Clean Architecture, state management with Riverpod, local and cloud persistence, and external API integration.

## Demo

📹 [Video Demo](https://youtu.be/3zZ3h_QZg18)

---

## Features

| Screen | Description |
|---|---|
| **Dashboard** | Monthly budget overview with progress bar, spending pie chart by category, recent transactions list |
| **Expenses** | Full expense list grouped by month, category filter (bottom sheet), swipe-to-delete, tap-to-edit |
| **Budget** | Set monthly budget limit via Shared Preferences, 6-month bar chart of spending history |
| **Currency Converter** | Real-time conversion for 160+ currencies (including KZT, RUB) via frankfurter.app API, live rates grid |
| **Shared Expenses** | Household expense sharing via Cloud Firestore — real-time sync across devices using the same Household ID |
| **Settings** | Light / dark / system theme toggle, default currency, username — all persisted in Shared Preferences |

---

## Architecture

The project follows **Clean Architecture** with strict layer separation:

```
lib/
├── core/
│   ├── constants/         # App-wide constants (categories, currencies)
│   └── theme/             # Material 3 light & dark themes
│
├── data/
│   ├── datasources/
│   │   ├── local/         # Drift (SQLite) database — tables, DAO methods
│   │   └── remote/        # Chopper API service, Firestore datasource
│   ├── models/            # JSON → Dart model classes
│   └── repositories/      # Concrete implementations of domain interfaces
│
├── domain/
│   ├── entities/          # Pure Dart entity classes (no Flutter dependency)
│   └── repositories/      # Abstract interfaces (contracts)
│
├── providers/             # Riverpod providers — DI and state
│
└── ui/
    ├── router/            # GoRouter declarative navigation
    ├── screens/           # Feature screens (dashboard, expenses, budget, …)
    └── widgets/           # Shared widgets (MainScaffold with NavigationBar)
```

**Dependency rule:** UI → Domain ← Data. Domain knows nothing about Flutter or external packages.

---

## Tech Stack

| Requirement | Solution |
|---|---|
| Navigation | `go_router` — declarative routes, ShellRoute, nested sub-routes (`/expenses/add`, `/expenses/edit/:id`) |
| State management | `flutter_riverpod` — `StreamProvider`, `FutureProvider.family`, `AsyncNotifierProvider` |
| Local database | `drift` (SQLite) — type-safe queries, auto-generated code, reactive Streams |
| Lightweight storage | `shared_preferences` — theme mode, username, monthly budget |
| External API | `chopper` — HTTP client with `JsonConverter` and `HttpLoggingInterceptor`; API: [frankfurter.app](https://frankfurter.app) |
| Cloud persistence | `cloud_firestore` — real-time shared household expenses |
| Charts | `fl_chart` — PieChart (category breakdown), BarChart (6-month history) |
| Code generation | `build_runner`, `drift_dev`, `riverpod_generator`, `chopper_generator` |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.3.0`
- Firebase project with Firestore enabled
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

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

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart` automatically.

### 4. Generate code (Drift, Riverpod, Chopper)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Run the app

```bash
# Windows desktop (recommended)
flutter run -d windows

# Web
flutter run -d chrome
```

---

## Key Design Decisions

**Why Riverpod over Provider?**  
Riverpod provides compile-time safety, no BuildContext dependency, and first-class support for async state (`AsyncValue`). `StreamProvider` connects directly to Drift's reactive streams — UI updates automatically when the database changes.

**Why two storage layers (Drift + SharedPreferences)?**  
Different tools for different data. Drift handles structured, relational data (expenses with categories, dates, amounts). SharedPreferences handles simple key-value settings (theme, budget limit, username). Using Drift for a boolean flag would be over-engineering.

**Why Chopper over http directly?**  
Chopper provides a type-safe, annotation-based API client with built-in interceptors (logging, authentication), automatic JSON conversion, and clean separation between API definition and usage.

---

## Team

| Member | Contribution |
|---|---|
| Zhalgas | Architecture, Riverpod providers, Drift database layer |
| Alisher | UI screens, navigation (GoRouter), theming |
| — | Firebase integration, Chopper API client, currency converter |

---

## Project Structure Notes

- `database.g.dart` and `app_router.g.dart` are auto-generated — do not edit manually
- Firebase config (`firebase_options.dart`) is included for convenience; rotate keys before production
- The `web/` folder includes `sqlite3.wasm` and `drift_worker.dart.js` required for Drift on web
