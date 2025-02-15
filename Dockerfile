# Base image
FROM minhnhk/python-jojogan-zombie:v3

# Set working directory
WORKDIR /app

# Download models file
RUN gdown 1-lHVBy0fuZimCKw_ivABslfOjMYwrUYJ -O /app/models.zip
RUN unzip /app/models.zip -d /app

# Remove the zip file
RUN rm /app/models.zip

# Copy directories to the container
COPY /app /app/app
COPY /utils /app/utils

# Expose the port
EXPOSE 8000

# Run the FastAPI application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
# CMD ["tail", "-f", "/dev/null"]