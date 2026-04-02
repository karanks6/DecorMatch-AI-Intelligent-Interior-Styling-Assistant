@echo off
call myenv\Scripts\activate.bat
python patch_keras.py > patch_log.txt 2>&1
echo Done.
