import requests
import os

API_URL_GET = f'http://test:8000/'

def test_get():
    response = requests.get(API_URL_GET)
    assert response.status_code == 200, f"Unexpected status code: {response.status_code}"
    assert response.json() == {"message": "Hello World"}, f"Unexpected message: {response.json()}"
    print("✅ Test passed: API is running.")

API_URL = f'http://test:8000/uploadfile/'

def test_post():
    # Open image file
    with open("./data/src/iu.jpeg", "rb") as img_file:
        files = {"file": ("test_image.jpg", img_file, "image/jpeg")}
        
        # Send a POST request to the API
        response = requests.post(API_URL, files=files)
        
        # Status code 200 or not
        assert response.status_code == 200, f"Unexpected status code: {response.status_code}"
        
        # Check if the response is an image
        assert response.headers["Content-Type"].startswith("image/"), "Response is not an image"

    print("✅ Test passed: File uploaded and received successfully.")