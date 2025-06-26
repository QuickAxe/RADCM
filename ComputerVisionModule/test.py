# oh ghosh the things I'm doing here....
import cv2
import subprocess


def getImage():
    subprocess.run(
        "rpicam-jpeg -n --output /home/quickaxe/Desktop/RADCM/ComputerVisionModule/image.jpg --width 640 --height 640",
        shell=True,
    )

    image = cv2.imread("image.jpg")
    return image


while True:

    frame = getImage()

    cv2.imshow("f", frame)

    if cv2.waitKey(1) & 0xFF == ord("q"):
        break
