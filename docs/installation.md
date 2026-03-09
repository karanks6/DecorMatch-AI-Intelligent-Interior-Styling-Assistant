# DecorMatch AI - Installation & Deployment Guide

## Architecture Overview
- **app/**: Flutter Mobile Application
- **gateway/**: Node.js Express API Server
- **ai_service/**: Python FastAPI Microservice

---

## Prerequisites
- Flutter SDK 3.3.0+
- Node.js v18+
- Python 3.9+
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)
- A Firebase project ([create one here](https://console.firebase.google.com/))

---

## 🔥 Firebase Setup (Do This First)

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** → name it `DecorMatch-AI`
3. Enable these services:
   - **Authentication** → Sign-in methods → Enable **Email/Password**
   - **Cloud Firestore** → Create database → Start in **test mode**
   - **Storage** → Get started → Start in **test mode**

### Step 2: Generate Service Account Key (for Node.js Gateway)
1. Firebase Console → ⚙️ **Project Settings** → **Service accounts**
2. Click **"Generate new private key"**
3. Save the file as `gateway/src/config/ServiceAccountKey.json`

### Step 3: Configure Flutter App with Firebase
```bash
firebase login
cd app
flutterfire configure --project=decormatch-ai
```
This generates `lib/firebase_options.dart` automatically.

> ⚠️ **Never commit** `ServiceAccountKey.json`, `google-services.json`, or `firebase_options.dart` to Git. They are already in `.gitignore`.

---

## 1. AI Microservice (Python)

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

### Setup
1. `cd gateway`
2. Install dependencies: `npm install`
3. Place `ServiceAccountKey.json` inside `src/config/` (from Firebase Step 2).

### Running Locally
```bash
npm run dev
```
Server runs at `http://localhost:3000`.

> The gateway auto-detects `ServiceAccountKey.json`. If not found, it starts in mock mode with a warning.

---

## 3. Mobile App (Flutter)

### Setup
1. `cd app`
2. Get packages: `flutter pub get`
3. Configure Firebase (from Firebase Step 3):
   ```bash
   flutterfire configure --project=decormatch-ai
   ```

### Running Locally
```bash
flutter run
```

> **AR Preview** requires a physical ARCore/ARKit-compatible device.

---

## Running All Services Together

Start each in a separate terminal:

```bash
# Terminal 1: AI Microservice
cd ai_service && uvicorn main:app --host 0.0.0.0 --port 8000 --reload

# Terminal 2: API Gateway
cd gateway && npm run dev

# Terminal 3: Flutter App
cd app && flutter run
```

---

## Deployment Recommendations
- **AI Service:** Google Cloud Run or AWS App Runner
- **Node.js Gateway:** Vercel, Render, or Google App Engine
- **Database / Storage:** Firebase Firestore & Cloud Storage
- **Flutter App:** Publish to App Store / Google Play using Fastlane
