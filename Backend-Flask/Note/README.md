# 🐍 Notes API (Flask Backend)

This is a lightweight backend API built with **Flask** and **Firebase Admin SDK**, designed to integrate seamlessly with the Flutter Notes App.  
It provides secure CRUD operations for user-specific notes stored in **Firebase Firestore** and protected via **Firebase Authentication**.

---

## 🚀 Features
- 🔐 **Authentication:** Token verification via Firebase ID tokens  
- 🗂️ **CRUD Endpoints:** Create, Read, Update, and Delete notes  
- 📌 **Pinned Notes:** Supports pinning/unpinning logic with proper ordering  
- 🌐 **CORS Enabled:** Allows requests from the Flutter frontend  
- 🧩 **Clean JSON responses:** Consistent structure for all endpoints  
- 🧱 **Firestore Integration:** Notes stored per user under `/users/{uid}/notes`  
- 🛡️ **Error Handling:** Clear HTTP status codes and messages  

---

## 🧱 Project Structure
`app.py` – main application entry point  
`serviceAccountKey.json` – Firebase credentials (⚠️ *exclude from git*)  

---

## ⚙️ Technologies & Libraries

| Library | Purpose |
|----------|----------|
| **Flask** | Lightweight web framework |
| **Flask-CORS** | Cross-origin requests from Flutter |
| **Firebase-Admin** | Firebase Authentication & Firestore client |
| **uuid / datetime** | Generate note IDs and timestamps |

---

## 🧩 How It Works

### 1. Authentication  
Each request includes an `Authorization: Bearer <Firebase ID Token>` header.  
The backend verifies this token via the Firebase Admin SDK and extracts the user’s UID.

### 2. CRUD Logic  
Each user has an isolated Firestore sub-collection: users/{uid}/notes



Supported routes:

| Method | Endpoint | Description |
|:-------|:----------|:-------------|
| `GET` | `/notes` | Returns user’s notes (sorted, pinned first) |
| `POST` | `/notes` | Creates a new note |
| `PUT` | `/notes/<note_id>` | Updates existing note fields |
| `DELETE` | `/notes/<note_id>` | Deletes a note |

### 3. Offline Support (via Flutter App)
The Flutter client queues local changes in Hive and syncs automatically when online, calling these endpoints.

---

## 🧠 Example Workflow

Flutter app signs in via Firebase Auth

It sends an ID token with each API request

Flask verifies the token, retrieves the UID

Notes are stored under the authenticated user’s Firestore path


## 🧩 Example JSON Object
{
  "id": "8fa214d30e1544c99",
  "title": "New Note",
  "content": "Meeting notes for project X",
  "pinned": true,
  "pinnedAt": "2025-10-25T18:20:00Z",
  "createdAt": "2025-10-25T18:20:00Z"
}
