from locust import HttpUser, task, between, constant

class UploadUser(HttpUser):
    wait_time = between(6, 10)  # Random interval between requests
    # wait_time = constant(0)  # Constant interval between requests

    @task
    def upload_image(self):
        file_path = "./data/src/iu.jpeg"  
        with open(file_path, "rb") as file:
            files = {"file": (file_path, file, "image/jpeg")}
            response = self.client.post("/uploadfile/", files=files, name="uploadfile")

        if response.status_code != 200:
            print(f"Upload failed: {response.status_code}, {response.text}")
