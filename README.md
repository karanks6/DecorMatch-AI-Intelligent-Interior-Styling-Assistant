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
