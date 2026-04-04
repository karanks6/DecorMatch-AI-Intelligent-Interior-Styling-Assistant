import zipfile
import json
import os
import tempfile
import shutil

keras_path = os.path.join(os.path.dirname(__file__), 'interior_style_v2.keras')
backup_path = os.path.join(os.path.dirname(__file__), 'interior_style_v2_backup.keras')

if not os.path.exists(keras_path):
    print("Model not found!")
    exit(1)

# Backup original
if not os.path.exists(backup_path):
    shutil.copy2(keras_path, backup_path)

temp_dir = tempfile.mkdtemp()

try:
    with zipfile.ZipFile(keras_path, 'r') as zip_ref:
        zip_ref.extractall(temp_dir)
        
    config_path = os.path.join(temp_dir, 'config.json')
    if os.path.exists(config_path):
        with open(config_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Very simple text replacement that works reliably for this exact key
        content = content.replace(', "quantization_config": null', '')
        content = content.replace('"quantization_config": null, ', '')
        content = content.replace('"quantization_config": null', '')
        
        with open(config_path, 'w', encoding='utf-8') as f:
            f.write(content)
            
        print("Config successfully cleaned.")
        
    else:
        print("No config.json found in generic zip root.")

    # Re-zip
    with zipfile.ZipFile(keras_path, 'w', zipfile.ZIP_DEFLATED) as zip_ref:
        for root, dirs, files in os.walk(temp_dir):
            for file in files:
                file_path = os.path.join(root, file)
                archive_name = os.path.relpath(file_path, temp_dir)
                zip_ref.write(file_path, archive_name)
                
    print(f"Patched {keras_path} successfully!")
except Exception as e:
    print("Error:", e)
finally:
    shutil.rmtree(temp_dir)

