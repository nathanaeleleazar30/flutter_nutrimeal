# NutriMeal – Architecture & Feature Overview

## 📚 Overview
NutriMeal is a healthy catering application that demonstrates a full **offline‑first** data‑persistence architecture using Flutter. The app separates data by sensitivity and stores each type in the most appropriate local storage solution.

---

## 🏗️ System Architecture

```text
┌─────────────────────────────────────────────────────────────────────┐
│                     NUTRIMEAL STORAGE ARCHITECTURE                  │
├───────────────────────┬─────────────────────────────┬───────────────────────┤
│   Structured Data     │   Non‑Sensitive Settings   │   Sensitive Secrets   │
│   (Offline‑First)     │   (SharedPreferences)      │   (SecureStorage)     │
├───────────────────────┼─────────────────────────────┼───────────────────────┤
│   Drift (SQLite)      │   shared_preferences        │   flutter_secure_storage │
├───────────────────────┼─────────────────────────────┼───────────────────────┤
│ • Cache menu / meals  │ • Last filter category      │ • Access token (JWT)  │
│ • `last_fetched` UTC  │ • Notification toggle       │ • Refresh token       │
│ • Real‑time `.watch()`│ • Sync timestamp            │ • User ID             │
│ • Atomic transactions │ • Theme / onboarding state │ • Auto‑wipe on logout │
└───────────────────────┴─────────────────────────────┴───────────────────────┘
```

### 1️⃣ Structured Storage – **Drift (SQLite)**
- **Packages**: `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`
- **Location**: `lib/data/local/database/`, `lib/data/repositories/meal_repository.dart`
- **Key capabilities**:
  - Type‑safe, reactive tables.
  - Offline caching of menu data fetched from the backend.
  - `last_fetched` column (UTC ms) tracks freshness.
  - Reactive `watch()` streams update the UI instantly.
  - Atomic batch writes guarantee data integrity.

### 2️⃣ Non‑Sensitive Settings – **SharedPreferences**
- **Package**: `shared_preferences`
- **Location**: `lib/data/local/preferences/preferences_service.dart`
- **Stores**:
  - Last selected filter category.
  - Notification enable/disable flag.
  - Sync timestamp.
  - On‑boarding completion status.
- **Never** stores credentials or tokens.

### 3️⃣ Sensitive Secrets – **FlutterSecureStorage**
- **Package**: `flutter_secure_storage`
- **Location**: `lib/data/local/secure/secure_storage_service.dart`, `lib/controllers/auth_controller.dart`
- **Stores**:
  - `access_token` (JWT)
  - `refresh_token`
  - `user_id`
- **Security**: Uses Android Keystore / iOS Keychain for hardware‑backed encryption. Automatic session restore on launch and secure wipe on logout.

### 4️⃣ Clean Architecture & Global State
- **Layers**:
  - `data/` – low‑level storage and repository implementations.
  - `controllers/` – Provider‑based global state (`NutriMealMenuController`, `AuthController`).
  - `screens/` & `widgets/` – UI that reacts to state changes.
- **Global UI features**: shopping cart, badge counters, category filters, authentication status – all reflected instantly across screens.

---

## ✨ Core Features
- **Offline‑First Caching** – Menus are usable without internet.
- **Reactive UI** – Stream‑based data triggers real‑time UI updates.
- **Atomic Transactions** – Bulk writes are safely wrapped in a transaction.
- **Secure Token Management** – Credentials are encrypted and isolated.
- **Lightweight Preferences** – Non‑sensitive settings stored efficiently.
- **Clean Architecture** – Easy to test, extend, and maintain.
- **Comprehensive Tests** – Unit & integration tests verify every requirement (see `test/local_storage_tugas9_test.dart`).

---

## 🧪 Automated Testing
Run the dedicated test suite to validate storage behavior:

```bash
flutter test test/local_storage_tugas9_test.dart
```

Key assertions include:
- Structured data caching with timestamps.
- Reactive watch streams.
- Atomic batch insert.
- Correct handling of non‑sensitive preferences.
- Secure storage of tokens.

---

## 🚀 Getting Started
1. **Install dependencies**
   ```bash
   flutter pub get
   ```
2. **Generate Drift code (if needed)**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
3. **Run the app**
   ```bash
   flutter run
   ```
4. **Static analysis**
   ```bash
   flutter analyze
   ```

---

## 📂 Related Documentation
- **API Config Guide** – `API_CONFIG_GUIDE.md`
- **Flutter Testing Guide** – `FLUTTER_TESTING_GUIDE.md`

---

*This repository is part of the NutriMeal PBL UAS mobile‑developer assignment, showcasing a production‑grade offline‑first storage solution built with clean architecture.*
