from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from PIL import Image
import torch
import io

# Load YOLOv5 model (you can replace with a custom-trained model path)
model = torch.hub.load('ultralytics/yolov5', 'yolov5s', pretrained=True)

app = FastAPI()

@app.post("/count-crops/")
async def count_crops(file: UploadFile = File(...)):
    print(f"Received file: {file.filename}")
    contents = await file.read()
    image = Image.open(io.BytesIO(contents))

    # Run detection
    results = model(image)
    detections = results.pandas().xyxy[0]

    # For real projects: filter by class name if needed (e.g., 'plant', 'crop', etc.)
    crop_count = len(detections)

    return JSONResponse(content={"crop_count": crop_count})
