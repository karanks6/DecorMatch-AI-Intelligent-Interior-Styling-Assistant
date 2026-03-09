import os
import tensorflow as tf
from tensorflow.keras.applications import ResNet50
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import ModelCheckpoint, EarlyStopping

# Config
DATA_DIR = os.path.join(os.path.dirname(__file__), 'dataset')
MODEL_SAVE_PATH = os.path.join(os.path.dirname(__file__), 'interior_style_model.h5')
BATCH_SIZE = 32
IMG_SIZE = (224, 224)
EPOCHS = 10

def create_model(num_classes):
    """Builds a custom classification head on top of ResNet50"""
    # Load ResNet50 without the top fully connected layers
    base_model = ResNet50(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
    
    # Freeze the base model
    base_model.trainable = False
    
    # Add custom head
    x = base_model.output
    x = GlobalAveragePooling2D()(x)
    x = Dense(512, activation='relu')(x)
    x = Dropout(0.5)(x)
    predictions = Dense(num_classes, activation='softmax')(x)
    
    model = Model(inputs=base_model.input, outputs=predictions)
    
    model.compile(optimizer=Adam(learning_rate=0.001), 
                  loss='categorical_crossentropy', 
                  metrics=['accuracy'])
    return model

def train():
    """Main training loop"""
    print("Starting Training Pipeline...")
    
    # 1. Data Augmentation and Loading
    datagen = ImageDataGenerator(
        preprocessing_function=tf.keras.applications.resnet50.preprocess_input,
        validation_split=0.2, # 80/20 split
        rotation_range=20,
        width_shift_range=0.2,
        height_shift_range=0.2,
        horizontal_flip=True
    )

    train_generator = datagen.flow_from_directory(
        DATA_DIR,
        target_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='training'
    )

    validation_generator = datagen.flow_from_directory(
        DATA_DIR,
        target_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='validation'
    )

    # Automatically get number of classes from folders
    num_classes = len(train_generator.class_indices)
    print(f"Detected {num_classes} style classes: {train_generator.class_indices}")
    
    if num_classes == 0:
        print("Error: No dataset found. Please run dataset_loader.py and populate the created folders with images first.")
        return

    # 2. Model Creation
    model = create_model(num_classes)
    
    # 3. Callbacks
    checkpoint = ModelCheckpoint(MODEL_SAVE_PATH, monitor='val_accuracy', save_best_only=True, mode='max', verbose=1)
    early_stop = EarlyStopping(monitor='val_loss', patience=3, restore_best_weights=True)

    # 4. Train Head
    print("Phase 1: Training custom classification head...")
    history = model.fit(
        train_generator,
        epochs=EPOCHS,
        validation_data=validation_generator,
        callbacks=[checkpoint, early_stop]
    )
    
    # 5. Fine Tuning (Optional)
    print("Phase 2: Fine-tuning the top layers of ResNet50 (Unfreezing last 10 layers)...")
    base_model = model.layers[0] # Not perfectly accurate layer indexing, conceptual
    base_model.trainable = True
    for layer in base_model.layers[:-10]:
        layer.trainable = False

    model.compile(optimizer=Adam(learning_rate=1e-5), # Lower learning rate
                  loss='categorical_crossentropy', 
                  metrics=['accuracy'])
                  
    model.fit(
        train_generator,
        epochs=5,
        validation_data=validation_generator,
        callbacks=[checkpoint]
    )

    print(f"Training Complete! Saved model to {MODEL_SAVE_PATH}")

if __name__ == "__main__":
    train()
