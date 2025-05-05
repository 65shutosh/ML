from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from PIL import Image
import torch
import io

# change with custom model here
model = torch.hub.load('ultralytics/yolov5', 'yolov5s', pretrained=True)

app = FastAPI()

@app.post("/count-crops/")
async def count_crops(file: UploadFile = File(...)):
    print(f"Received file: {file.filename}")
    contents = await file.read()
    image = Image.open(io.BytesIO(contents))

    # detection
    results = model(image)
    detections = results.pandas().xyxy[0]

    # Here we have to do it for crops
    crop_count = len(detections)

    return JSONResponse(content={"crop_count": crop_count})
