# Flutter Note App

This is a Flutter-based mobile note-taking application built with a clean architecture and Bloc state management.  
It focuses on **offline-first usage**, **local caching with Hive**, **Firebase authentication**, and **smooth synchronization** with a backend API (Flask).

---

## 🚀 Features

- **User Authentication** (Firebase: email/password)
- **Create, Update, Delete Notes**
- **Pin / Unpin Notes** (pinned notes stay on top)
- **Undo Delete** with Snackbar
- **Search & Filter** (by title or content)
- **Offline-first caching** (Hive local DB)
- **Automatic Sync** when network connection restores
- **Clean architecture** with Repository & Data Sources
- **State Management** with Bloc/Cubit

---

## 🧱 Project Structure

lib/
├── main.dart
├── firebase_options.dart
└── src/
    ├── blocs/                      # State management (NotesCubit, NotesState)
    ├── data/                       # Repository & local/remote data sources
    │   ├── local_data_source.dart
    │   ├── remote_data_source.dart
    │   └── notes_repository_impl.dart
    ├── models/                     # Note model (data class)
    ├── pages/                      # Screens (Login, Notes, Detail)
    │   ├── auth_gate.dart
    │   ├── login_page.dart
    │   ├── notes_page.dart
    │   └── note_detail_page.dart
    └── widgets/                    # Reusable UI components (NoteItem, etc.)


---

## ⚙️ Technologies & Packages

| Package | Purpose |
|----------|----------|
| **flutter_bloc** | Global state management (Bloc/Cubit pattern) |
| **hive / hive_flutter** | Local data persistence and offline caching |
| **dio** | HTTP client for communicating with the backend API |
| **firebase_core / firebase_auth** | Firebase initialization & authentication |
| **connectivity_plus** | Detects internet connectivity for syncing data |

---

## 🧩 How It Works

### State Management
- `NotesCubit` holds and updates the app state (`NotesState`).
- UI listens to Cubit updates via `BlocBuilder`.

### Offline-First Strategy
1. Notes are stored in local Hive boxes (`notes_box` and `pending_box`).
2. Any action (create/update/delete) is queued locally.
3. When online, pending actions are synced to the backend automatically.

### Repository Pattern
- `NotesRepository` connects the local (`Hive`) and remote (`Dio`) data sources.
- Handles all synchronization and caching logic.

### Search & Filter
- User input filters cached notes by **title** or **content**.
- Filtering runs locally (instant response, works offline).

---

🧭 Demo Flow

Sign up or log in using Firebase Auth.

Create, edit, or delete notes.

Pin notes — pinned notes always stay at the top.

Delete a note → Undo via Snackbar.

Search notes by title or content.

Go offline, make edits, come back online — data syncs automatically.

📚 Architecture Summary

UI Layer: Stateless widgets, separated by pages.

State Layer: Cubit (NotesCubit) manages all business logic.

Data Layer: Repository integrates LocalDataSource (Hive) and RemoteDataSource (Dio).

Sync Layer: Automatic background syncing after reconnection.

🛠️ Development Notes

Keep serviceAccountKey.json out of version control.

Use .env.example in the backend to configure sensitive data.

Supports Web, Android, and iOS (tested on Android emulator and Chrome).

🧩 Future Improvements

Add dark mode & theme customization.

Implement AI-powered summarization or title suggestion for notes.

Add push notifications for reminders.

Integrate tagging and sorting by category.


