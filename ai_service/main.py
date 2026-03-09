from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from model import analyze_room_image

app = FastAPI(title="DecorMatch AI Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "DecorMatch AI Service is running. Use /analyze-room via POST."}

@app.get("/health")
def health_check():
    return {"status": "AI Service is healthy"}

@app.post("/analyze-room")
async def analyze_room(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        analysis_result = analyze_room_image(contents)
        return analysis_result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
