# Base image
FROM python:3.9.21-slim

# Set working directory
WORKDIR /app

# Install libraries
RUN apt-get update && apt-get install -y \
    cmake \
    g++ \
    make \
    libgl1-mesa-glx \
    libglib2.0-0 \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Copy and install dependencies
COPY requirements.txt /app
COPY pyproject.toml /app
COPY /src /app/src

RUN pip install --upgrade pip
RUN pip install --no-cache -r requirements.txt
# install pytorch with cpu
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
# install pytorch with cuda 126. Remember run --gpus all in CLI
# RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

# Copy directories to the container
COPY /app /app/app
COPY /utils /app/utils
RUN gdown 1-lHVBy0fuZimCKw_ivABslfOjMYwrUYJ -O /app/models.zip
RUN unzip /app/models.zip -d /

RUN rm /app/models.zip

# COPY /models/zombie.pt /models/zombie.pt
# COPY /models/stylegan2-ffhq-config-f.pt /models/stylegan2-ffhq-config-f.pt
# COPY /models/dlibshape_predictor_68_face_landmarks.dat /models/dlibshape_predictor_68_face_landmarks.dat
# COPY /models/e4e_ffhq_encode.pt /models/e4e_ffhq_encode.pt

# Mở port 8000 cho FastAPI
EXPOSE 8000

# Chạy ứng dụng FastAPI bằng Uvicorn
CMD ["python", "app/main.py"]
