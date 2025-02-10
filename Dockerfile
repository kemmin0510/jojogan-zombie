# Base image
FROM python:3.9.21-slim

# Set working directory
WORKDIR /app

RUN apt-get update
RUN pip install --upgrade pip
RUN pip install fastapi==0.115.8 uvicorn==0.34.0 fastapi-cli==0.0.7 pydantic==2.10.6 pydantic-core==2.27.2


# # Install libraries
# RUN apt-get update && apt-get install -y \
#     cmake \
#     g++ \
#     make \
#     libgl1-mesa-glx \
#     libglib2.0-0 \
#     unzip \
#     && rm -rf /var/lib/apt/lists/*

# # Copy and install dependencies
# COPY requirements.txt /app

# RUN pip install --upgrade pip
# RUN pip install --no-cache -r requirements.txt
# # install pytorch with cpu
# RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
# # install pytorch with cuda 126. Remember run --gpus all in CLI
# # RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

# # Copy directories to the container
COPY /app /app/app
# COPY /utils /app/utils

# # Download models file
# RUN gdown 1-lHVBy0fuZimCKw_ivABslfOjMYwrUYJ -O /app/models.zip
# RUN unzip /app/models.zip -d /

# # Remove the zip file
# RUN rm /app/models.zip

# Expose the port
EXPOSE 8000

# Run the FastAPI application
CMD ["python", "app/main.py"]