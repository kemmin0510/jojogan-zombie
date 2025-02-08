# Base image
FROM python:3.9.21-slim

# Set working directory
WORKDIR /app

# Install libraries
# RUN apt-get update && apt-get install -y \
#     cmake \
#     g++ \
#     make \
#     libgl1-mesa-glx \
#     libglib2.0-0 \
#     unzip \
#     && rm -rf /var/lib/apt/lists/*

# Copy and install dependencies
# COPY requirements.txt /app

# RUN pip install --upgrade pip
# RUN pip install --no-cache -r requirements.txt
# install pytorch with cpu
# RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
# install pytorch with cuda 126. Remember run --gpus all in CLI
# RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

# Copy directories to the container
COPY /app /app/app
COPY /utils /app/utils

# Download models file
# RUN gdown 1-lHVBy0fuZimCKw_ivABslfOjMYwrUYJ -O /app/models.zip
# RUN unzip /app/models.zip -d /

# Remove the zip file
# RUN rm /app/models.zip

# Mở port 8000 cho FastAPI
EXPOSE 8000

RUN pwd

RUN ls

RUN ls ./app

RUN readlink -f app/main.py

RUN chmod +x app/main.py

CMD ["ls"]
