# DecorMatch AI - Installation & Deployment Guide

## Architecture Overview
- **app/**: Flutter Mobile Application
- **gateway/**: Node.js Express API Server
- **ai_service/**: Python FastAPI Microservice

---

## 1. AI Microservice (Python)

### Requirements
- Python 3.9+

### Setup
1. `cd ai_service`
2. Create virtual environment: `python -m venv venv`
3. Activate environment:
   - Mac/Linux: `source venv/bin/activate`
   - Windows: `venv\Scripts\activate`
4. Install dependencies: `pip install -r requirements.txt`

### Running Locally
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```
Service will be available at `http://localhost:8000`.

---

## 2. API Gateway (Node.js)

### Requirements
- Node.js v18+
- Firebase Admin SDK credentials (`ServiceAccountKey.json`)

### Setup
1. `cd gateway`
2. Install dependencies: `npm install`
3. If using real Firebase, place `ServiceAccountKey.json` inside `src/config/`.

### Running Locally
```bash
npm run dev
```
Server runs at `http://localhost:3000`.

---

## 3. Mobile App (Flutter)

### Requirements
- Flutter SDK 3.3.0+
- An iOS/Android Emulator or Physical Device (required for AR).

### Setup
1. `cd app`
2. Get packages: `flutter pub get`
3. Link with Firebase using FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

### Running Locally
```bash
flutter run
```

---

## Deployment Recommendations
- **AI Service:** Deploy to Google Cloud Run or AWS App Runner container to handle image processing easily.
- **Node.js Gateway:** Deploy to platforms like Vercel, Render, or Google App Engine.
- **Database / File Storage:** Firebase Firestore and Firebase Cloud Storage.
- **Flutter App:** Publish to App Store / Google Play using Fastlane.
