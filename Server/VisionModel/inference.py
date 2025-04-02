from ultralytics import YOLO
from io import BytesIO
from PIL import Image
from celery import shared_task

model = YOLO("VisionModel/models/yolo11m_cbam.pt")

# Crack -> 3, Pothole -> 1
remap_dict = {0: 3, 1: 1}


@shared_task
def vision_predict_anomaly_class(image_list):
    """
    Predict multiple anomalies if present in an image, powered by Ultralytics YOLO.
    #### Args:
    image_list (list[bytes]): A list of images each represented by a byte array.
    #### Returns:
    list[list[tuple[str, float]]]: A list of tuples of predicted classes for each image in the bytes_list, along with the associated confidence value.
    """

    images = [Image.open(BytesIO(image)) for image in image_list]

    results = model.predict(images, conf=0.5, stream=True, verbose=False)

    probs_list = []
    for result in results:
        result = result.summary()

        temp_list = []

        if not result:
            continue

        for detections in result:
            temp_list.append(
                (remap_dict[detections["class"]], detections["confidence"])
            )

        probs_list.append(temp_list)

    return probs_list


if __name__ == "__main__":
    import os
    import glob

    image_dir = "./"
    image_paths = glob.glob(os.path.join(image_dir, "*.png"))

    image_data_list = [open(image_path, "rb") for image_path in image_paths]

    vision_predict_anomaly_class(image_data_list)
