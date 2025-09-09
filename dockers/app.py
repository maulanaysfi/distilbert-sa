from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from transformers import AutoTokenizer, AutoModelForSequenceClassification

import torch, os

app = FastAPI()

model_path = "models"
tokenizer = AutoTokenizer.from_pretrained(model_path)
model = AutoModelForSequenceClassification.from_pretrained(model_path)
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)

classes = ['sadness', 'joy', 'love', 'anger', 'fear', 'surprise']

static_dir = os.path.join(os.path.dirname(__file__), "static")

if not os.path.isdir(static_dir):
    os.makedirs(static_dir)

app.mount("/static", StaticFiles(directory=static_dir), name="static")

class TextIn(BaseModel):
    text: str

@app.get("/")
def index():
    with open(f"{static_dir}/index.html", "r", encoding="utf-8") as f:
        html_content = f.read()
    return HTMLResponse(content=html_content, status_code=200)

@app.post("/predict")
def predict(raw_input: TextIn):
    tokenized_input = tokenizer(raw_input.text, return_tensors="pt", truncation=True, padding=True).to(device)
    with torch.no_grad():
        logits = model(**tokenized_input).logits
    #probs = torch.nn.functional.softmax(logits, dim=-1)
    pred = torch.argmax(logits, dim=1).item()
    return {"class-index": int(pred), "class": classes[pred]}
