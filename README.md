# 🗒️ Flutter Notes App (Fullstack Project)

This repository contains a complete **note-taking application** built with **Flutter (frontend)** and **Flask (backend)**.  
It demonstrates how to design a clean, maintainable, and offline-first app architecture with a simple and intuitive user experience.

---

## 🎯 Overview

The project allows users to:
- Create, edit, and delete notes  
- Search and filter notes by title or content  
- Pin important notes to keep them at the top  
- Undo deletions instantly  
- Access notes even when offline  
- Automatically sync with the backend when online  

While the concept is simple, the implementation demonstrates how to combine **frontend–backend communication**, **state management**, and **cloud integration** into a cohesive fullstack project.

---

## 🧩 Tech Stack

### 📱 Frontend – Flutter
- Built with **Flutter** using **Bloc/Cubit** for state management  
- **Hive** for local offline data caching  
- **Firebase Authentication** for user login and signup  
- **Dio** for API communication  
- Clean separation of UI, logic, and data layers  

### ⚙️ Backend – Flask (Python)
- **Flask** + **Flask-CORS** for REST API  
- **Firebase Admin SDK** for authentication and Firestore access  
- CRUD endpoints for notes: `/notes`, `/notes/<id>`  
- Secure, token-based user isolation  
- Can be deployed easily to Render, Railway, or Cloud Run  

---

Each module can run independently:
- `frontend/` → Flutter mobile/web app  
- `backend/` → Flask REST API  

---

## 🚀 Key Features
✅ Firebase Authentication (email/password)  
✅ CRUD operations for notes  
✅ Offline-first caching with Hive  
✅ Automatic backend sync  
✅ Pinned & undo delete functionality  
✅ Search and filtering  
✅ Cross-platform (Android, iOS, Web)  

---

## 🧭 Project Goals
This project was developed to demonstrate:
- Practical use of **state management (Bloc)**  
- Designing a **scalable architecture** for mobile apps  
- Integrating **Flutter with a custom backend API**  
- Handling **offline synchronization**  
- Writing **clean, readable, and reusable code**  

---

## 🧠 Why This Project Matters
Although it’s a simple note-taking app, the project covers many real-world fundamentals:
- Authentication flow  
- API design & communication  
- Offline storage & caching  
- Data synchronization logic  
- Modular architecture  

These are essential building blocks for larger production-grade applications.

---

## 💡 Future Possibilities
- Add AI-powered note summarization or title suggestions  
- Implement push notifications for reminders  
- Add user profile & cloud storage for attachments  
- Deploy fullstack version publicly  

---
