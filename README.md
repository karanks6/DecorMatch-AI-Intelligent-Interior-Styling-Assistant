# DecorMatch AI

**DecorMatch AI** is a premium, highly intelligent interior styling assistant that empowers users to effortlessly design and furnish their homes. By combining deep learning, computer vision, and augmented reality (AR), the platform acts as a personal digital interior designer.

---

## 📖 Description

DecorMatch AI bridges the gap between imagination and reality in interior design. Users simply snap a photo of their room, and the app instantly performs a comprehensive aesthetic analysis. It detects the current interior style, maps out the dominant color palette, and identifies existing furniture. Based on this contextual understanding, DecorMatch AI curates and recommends decor items that harmonize perfectly with the user's space. To complete the experience, users can seamlessly preview these recommended items directly in their physical room using high-fidelity 3D Augmented Reality (AR) before making a purchase.

---

## ❗ Problem Statement

Furnishing a home or restyling a room is a notoriously overwhelming and high-friction process for most consumers:
1. **Lack of Design Literacy:** Individuals often struggle to articulate their personal design style or understand what pieces complement their existing decor.
2. **The "Will it Fit?" Dilemma:** Mentally visualizing how a new piece of furniture will look, fit, and feel in a physical space is incredibly difficult, leading to high return rates in the furniture e-commerce sector.
3. **Color Clashing:** Consumers frequently purchase items that clash with their room's existing dominant color palette because they lack the tools to match shades accurately.
4. **Market Gaps:** Traditional e-commerce apps lack design intelligence, acting merely as catalogs. Conversely, hiring a professional interior designer is prohibitively expensive for the average homeowner or renter.

---

## 💡 How DecorMatch AI Solves the Problem

DecorMatch AI solves these pain points by offering an end-to-end, "AI-first" interior design pipeline:
- **Demystifying Style:** The AI automatically classifies the user's room into established design aesthetics (e.g., Scandinavian, Industrial, Minimalist), giving them the vocabulary and confidence to design.
- **Color Harmony:** By programmatically extracting the absolute dominant hex codes from the user's room, the system only recommends items that color-coordinate with the existing environment.
- **Context-Aware Recommendations:** Because the system uses object detection to know what furniture already exists in the room (e.g., detecting a sofa but no coffee table), recommendations are highly relevant.
- **AR Validation:** The "Try before you buy" AR feature completely eliminates the guesswork of visualizing furniture. Users can see the scale, texture, and placement of a 3D model in their actual room through their phone's camera.

---

## 🎯 Objectives

The core objectives of DecorMatch AI are:
- **Democratize Interior Design:** Provide a premium, accessible digital assistant that replaces the need for expensive design consultations.
- **Reduce E-commerce Friction:** Lower the return rate of furniture by allowing users to physically validate products in their space via AR.
- **Deliver a Seamless UX:** Blend complex deep-learning analytics with an intuitive, glassmorphic, luxury-inspired mobile interface that makes the styling process feel effortless and engaging.

---

## ✨ Features

- **Instant AI Room Analysis:** Upload a photo (via camera or gallery) and receive a deep-learning-based classification of your interior design style.
- **Smart Color Palette Extraction:** Automatically extracts and displays the top 3 dominant colors from the uploaded room image.
- **Object Detection:** Identifies existing furniture and decor items (e.g., chairs, beds, plants, TVs) using advanced computer vision to understand the room's composition.
- **Curated Recommendations:** An intelligent recommendation engine that suggests furniture and decor pieces perfectly matched to the detected style and color palette.
- **AR Visualization:** Users can instantly project recommended 3D furniture models (`.glb`) into their physical space using high-fidelity Augmented Reality powered by ARCore.
- **Persistent Saved Items & History:** Users can save their favorite items and view past room analyses, all synchronized across sessions.
- **Smart Notifications:** A local notification engine powered by WorkManager that sends analysis completion alerts, staggered daily reminders for saved items, and personalized style recommendations—even when the app is completely closed.
- **Premium UI/UX:** A professionally designed, glassmorphic interface inspired by luxury editorial magazines, utilizing a cohesive deep emerald, warm gold, and cream color palette.

---

## 🛠 Technical Architecture & Technologies Used

DecorMatch AI employs a modern, decoupled microservices architecture to ensure high performance and scalability:

### 1. Frontend (Mobile App)
- **Flutter & Dart:** The core framework chosen for its ability to deliver a natively compiled, high-performance, and beautiful UI across Android and iOS from a single codebase.
- **model_viewer_plus:** A modern web-component-based widget used to render 3D (`.glb`) models. This replaces deprecated native Sceneform plugins, relying directly on Google's ARCore / Android Scene Viewer to provide stable AR rendering without native memory crashes.
- **flutter_local_notifications & workmanager:** Used to build a robust background notification scheduler that operates outside the main app lifecycle.
- **Firebase Auth & Firestore:** Integrated for robust user authentication and real-time cloud data persistence.
- **Riverpod:** Employed for scalable, compile-safe state management across the application.

### 2. AI Service (Backend Analytics)
- **Python & FastAPI:** Provides a blazing-fast, lightweight API dedicated exclusively to serving the heavy machine learning models.
- **TensorFlow / Keras:** Powers the custom interior style classification model. The core model (`interior_style_v2.keras`) utilizes transfer learning on top of an EfficientNetV2/ResNet50 base, fine-tuned on a custom dataset of interior design aesthetics to achieve high categorical accuracy.
- **Ultralytics YOLOv8:** An industry-leading, real-time object detection model (`yolov8n.pt`) used to identify specific interior items (couch, dining table, potted plant, etc.) by filtering generic COCO classes.
- **OpenCV & scikit-learn (KMeans):** Utilized for advanced image processing. Images are decoded, resized, and processed through KMeans clustering (`k=3`) to extract the absolute dominant hex color codes.

### 3. Gateway / API Service (Backend Business Logic)
- **Node.js & Express.js:** Acts as the central nervous system of the backend architecture. It serves product data, routes requests between the mobile app and the Python AI service, and statically serves the 3D `.glb` assets to the frontend.



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
   - Windows: `myenv\Scripts\activate`
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
