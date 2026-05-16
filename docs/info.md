# DecorMatch AI — Project Information

## 1. Introduction & Overview

**DecorMatch AI** is an intelligent interior styling assistant application. By simply snapping a photo of their space, users can instantly receive a comprehensive design analysis—identifying their current interior style, mapping out their room's dominant color palette, and detecting existing furniture. Based on this analysis, the app intelligently recommends curated decor items that match the user's aesthetic and allows them to visualize these items in their own room using Augmented Reality (AR).

### Problem Statement
Furnishing a home or restyling a room is often overwhelming. Individuals struggle to articulate their personal design style, find it difficult to mentally visualize how a new piece of furniture will fit into their existing space, and often purchase items that clash with their room's color palette. Traditional e-commerce apps lack design intelligence, while professional interior design services are expensive.

### Objective
To democratize interior design by providing a premium, AI-driven digital assistant that seamlessly blends deep-learning-based room analysis with an intuitive e-commerce and AR visualization experience.

---

## 2. Key Features

- **AI Room Analysis:** Upload a photo (from camera or gallery) and let the AI instantly classify the interior design style.
- **Smart Color Palette Extraction:** Automatically extracts the top 3 dominant colors from the uploaded room image.
- **Object Detection:** Identifies existing furniture and decor items (e.g., chairs, beds, plants) using advanced computer vision.
- **Curated Recommendations:** Recommends furniture and decor pieces that perfectly match the detected style and color palette.
- **AR Visualization:** "Try before you buy." Users can preview recommended 3D furniture models directly in their physical space using high-fidelity Augmented Reality.
- **Premium UI/UX:** A professionally designed, glassmorphic interface inspired by luxury editorial magazines, utilizing a deep emerald, warm gold, and cream palette.

---

## 3. Technology Stack & Architecture

DecorMatch AI employs a modern, decoupled microservices architecture:

### Frontend (Mobile App)
- **Flutter & Dart:** Chosen for its ability to deliver a natively compiled, high-performance, and beautiful UI across Android (and iOS) from a single codebase.
- **model_viewer_plus:** A modern web-component-based widget used to render 3D (`.glb`) models. This replaced deprecated native Sceneform plugins, relying directly on Google's ARCore / Android Scene Viewer to entirely eliminate native `SIGSEGV` memory crashes during AR rendering.
- **Riverpod:** Used for robust and scalable state management.

### AI Service (Backend Analytics)
- **Python & FastAPI:** Provides a blazing-fast, lightweight API specifically for serving the machine learning models.
- **TensorFlow / Keras:** Powers the custom interior style classification model.
- **Ultralytics YOLOv8:** An industry-leading, real-time object detection model used to identify interior items within the uploaded photo.
- **OpenCV & scikit-learn (KMeans):** Used for advanced image processing and dominant color extraction.

### Gateway / API Service (Backend Business Logic)
- **Node.js & Express.js:** Acts as the central gateway to serve product data, route requests between the mobile app and the Python AI service, and statically serve 3D `.glb` assets.

---

## 4. Trained Model Details

DecorMatch AI relies on a multi-stage AI pipeline to analyze a room:

1. **Interior Style Classification (EfficientNetV2 / ResNet50):** 
   - **Model Details:** The core custom model (`interior_style_v2.keras`) is trained via transfer learning on top of a base convolutional neural network (CNN). The top layers are fine-tuned on a custom dataset of interior design aesthetics (e.g., Bohemian, Minimalist, Scandinavian, Industrial).
   - **Accuracy:** By leveraging EfficientNetV2's robust feature extraction, the model achieves high categorical accuracy, minimizing confusion between similar styles like Modern and Minimalist.

2. **Object Detection (YOLOv8):**
   - **Details:** Uses the YOLOv8 nano (`yolov8n.pt`) weights to perform real-time bounding box detection. It filters generic COCO classes to focus specifically on interior-relevant items (e.g., couch, dining table, potted plant, tv, vase).

3. **Color Extraction (KMeans Clustering):**
   - **Details:** Images are decoded, converted mapping to RGB, resized for performance, and processed through KMeans clustering (`k=3`) to extract the absolute dominant hex codes of the room.

---

## 5. Unique Value Proposition & Prime Users

### What makes it unique?
Unlike standard furniture apps (like IKEA Place) which only offer AR, or Pinterest which only offers static inspiration, DecorMatch AI **closes the entire loop**. It uniquely combines context-aware AI styling (understanding what you *already have*) with actionable e-commerce recommendations and immediate AR validation. Furthermore, it solved complex 3D binary formatting issues by migrating completely to modern scene-viewer web technologies, ensuring maximum device compatibility.

### Prime Users
- **Homeowners & Renters:** Individuals looking to upgrade their living spaces without hiring an interior designer.
- **Design Enthusiasts:** People seeking aesthetic inspiration and curated shopping.
- **Furniture Shoppers:** Consumers who want to confidently visualize large ticket items in their space before making a purchase.

---

## 6. Project Progress & Phases

### Phase 1: Foundation & AI Pipeline **[COMPLETED]**
- [x] Initializing Flutter App and Node.js backend.
- [x] Setting up Python FastAPI service.
- [x] Training and exporting interior style models (Keras/H5).
- [x] Implementing YOLOv8 logic and KMeans color extraction.

### Phase 2: UX Overhaul & AR Stabilization **[COMPLETED]**
- [x] Premium cohesive UI redesign (splash, login, dashboard, results, profiles).
- [x] Implementation of the `AppTheme` utilizing Playfair Display & Inter fonts.
- [x] Resolving critical AR crashes (SIGSEGV) by replacing the legacy Sceneform AR plugin with `model_viewer_plus`.
- [x] Migrating 3D assets to a versioned Gateway endpoint to bypass broken Draco-compressed caching.

### Phase 3: Auth & Persistence **[IN PROGRESS / CURRENT WORK]**
- [ ] Integrating Firebase Authentication for the Login/Signup flows.
- [ ] Setting up Cloud Firestore to save "Analysis History" and "Saved Items" dynamically to the user's profile.
- [ ] Building out full Cart and checkout mock functionality.


