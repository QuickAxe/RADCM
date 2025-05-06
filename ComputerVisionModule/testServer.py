from flask import Flask, request
import os

app = Flask(__name__)


@app.route("/upload", methods=["POST"])
def upload_image():
    if "image" not in request.files:
        return "No image part in the request", 400

    image = request.files["image"]
    if image.filename == "":
        return "No selected image", 400

    filepath = os.path.join(UPLOAD_FOLDER, image.filename)
    image.save(filepath)

    return f"Image saved to {filepath}", 200


if __name__ == "__main__":

    # Folder to save uploaded images
    UPLOAD_FOLDER = "uploads"
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)
    app.run(debug=True, host="0.0.0.0")
