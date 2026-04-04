import cv2
import numpy as np
from sklearn.cluster import KMeans
import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input as mobilenet_preprocess, decode_predictions
from tensorflow.keras.applications.efficientnet_v2 import preprocess_input as efficientnet_preprocess
from tensorflow.keras.models import load_model
from PIL import Image
import io
import os
import json
from ultralytics import YOLO


# Load YOLOv8 for object detection (Decor Items)
yolo_model = YOLO('yolov8n.pt')

# Load the custom trained model if it exists, otherwise fallback to the ImageNet mock
MODEL_PATH_KERAS = os.path.join(os.path.dirname(__file__), 'interior_style_v2.keras')
MODEL_PATH_H5 = os.path.join(os.path.dirname(__file__), 'interior_style_model.h5')

if os.path.exists(MODEL_PATH_KERAS):
    print(f"Loading custom trained model from {MODEL_PATH_KERAS}...")
    style_model = load_model(MODEL_PATH_KERAS)
    is_custom_model = True
elif os.path.exists(MODEL_PATH_H5):
    print(f"Loading custom trained model from {MODEL_PATH_H5}...")
    style_model = load_model(MODEL_PATH_H5)
    is_custom_model = True
else:
    print("Custom model not found. Falling back to MobileNetV2 ImageNet mock. Please run train.py or place your .keras/.h5 model here.")
    style_model = MobileNetV2(weights='imagenet', include_top=True)
    is_custom_model = False

# Predefined styles (Fallback)
STYLES = [
    "Minimalist",
    "Bohemian",
    "Modern",
    "Traditional Indian",
    "Scandinavian",
    "Industrial"
]

# Dynamically load the exact class order from your Keras training run!
INDEX_PATH = os.path.join(os.path.dirname(__file__), 'class_indices_v2.json')
if os.path.exists(INDEX_PATH):
    print(f"Loading true class mapping from {INDEX_PATH}")
    with open(INDEX_PATH, 'r', encoding='utf-8') as f:
        class_map = json.load(f)

    # Some users save {"Bohemian": 0}, others save {"0": "Bohemian"}
    # Let's detect the format and invert if necessary
    first_val = list(class_map.values())[0] if class_map else None
    
    if isinstance(first_val, int) or (isinstance(first_val, str) and first_val.isdigit()):
        # Format is {"Bohemian": 0}
        inverted_map = {int(v): str(k) for k, v in class_map.items()}
    else:
        # Format is {"0": "Bohemian"}
        inverted_map = {int(k): str(v) for k, v in class_map.items()}
        
    max_idx = max(inverted_map.keys()) if inverted_map else -1
    STYLES = [inverted_map.get(i, "Unknown Style") for i in range(max_idx + 1)]
    print(f"Realigned STYLES mapping: {STYLES}")

def map_imagenet_to_style(predictions):
    """
    Since we don't have a dataset to train a custom head on interior design,
    we simulate the network by mapping top ImageNet predictions to our styles.
    In a real app, you would freeze base_layers and train a custom dense layer head
    on a custom room dataset.
    """
    # Just a mock deterministic logic based on the decoded predictions
    top_pred = predictions[0][0] # class name
    hash_val = sum([ord(c) for c in top_pred[1]])
    style_index = hash_val % len(STYLES)
    confidence = float(predictions[0][0][2])
    
    # Boost confidence slightly for realism of a trained model
    adjusted_conf = min(0.99, confidence + 0.5) 
    
    return STYLES[style_index], round(adjusted_conf, 2)

def extract_dominant_colors(image_bytes, k=3):
    """
    Extracts top k dominant colors from an image using KMeans.
    Returns a list of hex color codes.
    """
    # Convert image bytes to numpy array
    nparr = np.frombuffer(image_bytes, np.uint8)
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    # Convert BGR to RGB
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    
    # Resize image for faster processing
    image = cv2.resize(image, (100, 100))
    
    # Flatten the image
    pixels = image.reshape(-1, 3)
    
    # Perform KMeans
    kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
    kmeans.fit(pixels)
    
    colors = kmeans.cluster_centers_
    
    hex_colors = []
    for color in colors:
        r, g, b = [int(c) for c in color]
        hex_colors.append(f"#{r:02x}{g:02x}{b:02x}")
        
    return hex_colors

def extract_detected_items(image_bytes):
    """
    Uses YOLOv8 to detect real objects (like chairs, beds, plants) in the room.
    """
    img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    results = yolo_model(img, verbose=False) # Run inference
    
    detected_items = []
    
    # YOLO returns a list of Results objects
    for r in results:
        boxes = r.boxes
        for box in boxes:
            # Get class ID
            cls_id = int(box.cls[0].item())
            # Get class name
            class_name = r.names[cls_id]
            # Get confidence
            conf = float(box.conf[0].item())
            
            # Filter somewhat relevant interior generic COCO classes
            interior_relevant = ['chair', 'couch', 'potted plant', 'bed', 'dining table', 'tv', 'vase', 'clock', 'book', 'refrigerator', 'oven', 'sink', 'microwave']
            
            if class_name in interior_relevant and conf > 0.3:
                if class_name not in detected_items:
                    detected_items.append(class_name)
                    
    return detected_items

def analyze_room_image(image_bytes):
    """
    1. Runs style classification using Custom ResNet50 (or Mock MobileNet)
    2. Runs object detection using YOLOv8
    3. Runs dominant color extraction using OpenCV/KMeans
    """
    img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    
    if is_custom_model:
        # Dynamically get required input size from the loaded model
        target_size = style_model.input_shape[1:3] # e.g. (300, 300)
        img_resized = img.resize(target_size)
        img_array = tf.keras.preprocessing.image.img_to_array(img_resized)
        img_array = np.expand_dims(img_array, axis=0)
        
        # Real pipeline (EfficientNetV2Preprocessing)
        img_array = efficientnet_preprocess(img_array)
        preds = style_model.predict(img_array)
        style_index = np.argmax(preds[0])
        confidence = float(np.max(preds[0]))
        style = STYLES[style_index]
    else:
        # Mock pipeline
        img_resized = img.resize((224, 224))
        img_array = tf.keras.preprocessing.image.img_to_array(img_resized)
        img_array = np.expand_dims(img_array, axis=0)
        
        img_array = mobilenet_preprocess(img_array)
        preds = style_model.predict(img_array)
        decoded_preds = decode_predictions(preds, top=3)
        style, confidence = map_imagenet_to_style(decoded_preds)
    
    # 2. Object Detection
    detected_items = extract_detected_items(image_bytes)
    
    # 3. Color Extraction
    dominant_colors = extract_dominant_colors(image_bytes, k=3)
    
    return {
        "style": style,
        "confidence": round(confidence, 2),
        "dominant_colors": dominant_colors,
        "detected_items": detected_items,
        "is_real_ai": is_custom_model
    }
