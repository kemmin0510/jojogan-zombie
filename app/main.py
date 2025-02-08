
import sys, io
sys.path.insert(0, '/app')
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import FileResponse, StreamingResponse
from torchvision import utils
from utils.model import *
from utils.e4e_projection import projection as e4e_projection
from utils.util import *
import torch
import uvicorn
import uuid

app = FastAPI()

# @app.get("/")
# async def read_root():
#     return {"message": "Hello World"}

# Set latent dim
latent_dim = 512

# Set device
device = 'cpu' # cuda or cpu

# Set model path
stylegan2_path = "../models/stylegan2-ffhq-config-f.pt"
zombie_path = "../models/zombie.pt"

# Load the original generator
generator = Generator(1024, latent_dim, 8, 2).to(device)
ckpt = torch.load(stylegan2_path, map_location=lambda storage, loc: storage)
generator.load_state_dict(ckpt["g_ema"], strict=False)
mean_latent = generator.mean_latent(10000)

# Load the finetured parameters
generator.load_state_dict(torch.load(zombie_path, map_location=device))

@app.post("/uploadfile/")
async def upload_file(file: UploadFile = File()):

    # Create temp filename
    temp_filename = f"/app/app/tmp/{uuid.uuid4().hex}.png"

    # Save the temp file
    with open(temp_filename, "wb") as f:
        f.write(await file.read())

    # Aligns and crops face from the source image
    aligned_face = align_face(temp_filename)

    # Project the aligned face to latent space
    my_w = e4e_projection(img=aligned_face, device=device).unsqueeze(0)

    # Generatre the image
    with torch.no_grad():
        generated_image = generator(my_w, input_is_latent=True)
        # utils.save_image(generated_image, "generated.png", normalize=True)

    # Remove temp file
    os.remove(temp_filename)

    processed_image = generated_image[0].permute(1, 2, 0).cpu().numpy()
    processed_image = ((processed_image + 1) / 2.0) * 255  # If image has been normalized to [-1, 1]
    processed_image = np.clip(processed_image, 0, 255).astype(np.uint8)
    # Convert to PIL message
    processed_image = Image.fromarray(processed_image)
    
    # Store in buffer
    buf = io.BytesIO()
    processed_image.save(buf, format="PNG")
    buf.seek(0)

    return StreamingResponse(buf, media_type="image/png")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, log_level="info", reload=True, workers=1)