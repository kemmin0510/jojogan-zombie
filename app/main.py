
import sys, io
sys.path.insert(0, '/app')
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import StreamingResponse
from utils.model import *
from utils.e4e_projection import projection as e4e_projection
from utils.util import *
from time import time
from opentelemetry import metrics
from opentelemetry.exporter.prometheus import PrometheusMetricReader
from opentelemetry.metrics import set_meter_provider
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from prometheus_client import start_http_server
from loguru import logger

import torch
import uuid
import warnings

warnings.filterwarnings("ignore", category=UserWarning)

# Start Prometheus client
start_http_server(port=8099, addr="0.0.0.0")

# Service name is required for most backends
resource = Resource(attributes={SERVICE_NAME: "ocr-service"})

# Exporter to export metrics to Prometheus
reader = PrometheusMetricReader()

# Meter is responsible for creating and recording metrics
provider = MeterProvider(resource=resource, metric_readers=[reader])
set_meter_provider(provider)
meter = metrics.get_meter("jojogan-zombie", "0.1.0")

# Create your first counter
counter = meter.create_counter(
    name="jojogan_zombie_counter",
    description="Number of Jojogan Zombie requests"
)

histogram = meter.create_histogram(
    name="jojogan_zombie_response_histogram",
    description="Jojogan Zombie response histogram",
    unit="seconds",
)

# Decorator the function to count the number of requests
def count_requests(func):
    def wrapper(*args, **kwargs):
        start_time = time()

        # Call the function
        result = func(*args, **kwargs)

        # Labels for all metrics
        label = {"api": "jojogan_zombie"}

        # Increment the counter
        counter.add(10, label)

        # Mark the end of the response
        end_time = time()
        elapsed_time = end_time - start_time

        # Add histogram
        logger.info('elapsed_time: {}'.format(elapsed_time))
        histogram.record(elapsed_time, label)

        return result


app = FastAPI()

# Set latent dim
latent_dim = 512

# Set device
device = 'cpu' # cuda or cpu

# Set model path
stylegan2_path = "./models/stylegan2-ffhq-config-f.pt"
zombie_path = "./models/zombie.pt"

# Load the original generator
generator = Generator(1024, latent_dim, 8, 2).to(device)
ckpt = torch.load(stylegan2_path, map_location=lambda storage, loc: storage)
generator.load_state_dict(ckpt["g_ema"], strict=False)
mean_latent = generator.mean_latent(10000)

# Load the finetured parameters
generator.load_state_dict(torch.load(zombie_path, map_location=device))

# Set the generator to evaluation mode
@count_requests
@app.post("/uploadfile/") # Post method
async def upload_file(file: UploadFile = File()):

    # Create temp filename
    temp_filename = f"{uuid.uuid4().hex}.png"

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