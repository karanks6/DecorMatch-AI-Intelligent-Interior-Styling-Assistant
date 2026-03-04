# DecorMatch AI - API Documentation

## Node.js Gateway Endpoints

### 1. Health Check
Checks if Gateway is awake.
- **URL:** `/api/health`
- **Method:** `GET`
- **Response:**
  ```json
  { "status": "Gateway is healthy", "ts": "2026-03-04T..." }
  ```

### 2. Analyze Room Image
Uploads a photo for AI processing and returns decor recommendations.
- **URL:** `/api/analyze-room`
- **Method:** `POST`
- **Content-Type:** `multipart/form-data`
- **Body:** `image` (File)
- **Response:**
  ```json
  {
    "analysis": {
      "style": "Bohemian",
      "confidence": 0.88,
      "dominant_colors": ["#C65D4F", "#D9A066", "#3F4E4F"]
    },
    "recommendations": [
      {
        "product_id": "p2",
        "name": "Bohemian Woven Rug",
        "style_category": "Bohemian",
        "price": 129.99
      }
    ]
  }
  ```

### 3. Fetch Products
- **URL:** `/api/products`
- **Method:** `GET`

### 4. Fetch Products by Style
- **URL:** `/api/products/style/:style`
- **Method:** `GET`

---

## Python AI Service Endpoints (Internal)

### 1. Analyze Core
Receives an image buffer directly from Node.js and processes it through ResNet/MobileNet and KMeans.
- **URL:** `/analyze-room`
- **Method:** `POST`
- **Content-Type:** `multipart/form-data`
- **Body:** `file` (File buffer)
- **Response:**
  ```json
  {
    "style": "Modern",
    "confidence": 0.95,
    "dominant_colors": ["#1F2933", "#F7F3EF"]
  }
  ```
