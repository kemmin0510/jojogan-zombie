from fastapi.testclient import TestClient
from app.main import app

API_URL = f'http://localhost:8000/uploadfile/'

client = TestClient(app)

def test_post():
    
    # Open image file
    with open("./data/src/iu.jpeg", "rb") as img_file:
        files = {"file": ("test_image.jpg", img_file, "image/jpeg")}
        
        # Send a POST request to the API
        response = client.post(API_URL, files=files)
        
        # Status code 200 or not
        assert response.status_code == 200, f"Unexpected status code: {response.status_code}"
        
        # Check if the response is an image
        assert response.headers["Content-Type"].startswith("image/"), "Response is not an image"

    print("✅ Test passed: File uploaded and received successfully.")