import cv2 as cv
import time
from PIL import Image
import piexif
import piexif.helper

import glob

import requests
import os

import subprocess

# ! remove this later, probably
DEBUG = True


# function to read the image using the rpi cam
# note: this is a stupid workaround, because I already spent like 5 hours trying to get it to work normally and I can't be bothered any more
def readImage():
    subprocess.run(
        "rpicam-jpeg -n --output /home/quickaxe/Desktop/RADCM/ComputerVisionModule/image.jpg --width 640 --height 640",
        shell=True,
    )

    image = cv.imread("image.jpg")
    return image


# function to save the image with it's location encoded as part of it's EXIF data, in the UserComment field
def saveImage(image, lat, lng, imageNumber):

    # convert the image to PIL format because opencv is stupid and messes up EXIF data (ok it's not stupid, sorry opencv)
    image = cv.cvtColor(image, cv.COLOR_BGR2RGB)
    image = Image.fromarray(image)

    # create a "comment" and convert it to bytes
    commentText = f"{lat} {lng}"
    commentBytes = piexif.helper.UserComment.dump(commentText)

    # create the default EXIF dict and store the above comment in it
    exifDict = {
        "0th": {},
        "Exif": {piexif.ExifIFD.UserComment: commentBytes},
        "GPS": {},
        "1st": {},
        "thumbnail": None,
    }
    exifBytes = piexif.dump(exifDict)

    # save the image finally
    image.save(f"./Images/image-{imageNumber}.jpg", exif=exifBytes)


# I did not code this function, cgpt did
# ughh it just makes things so.. easy
def extract_user_comment(image_path):
    try:
        exif_dict = piexif.load(image_path)
        user_comment = exif_dict["Exif"].get(piexif.ExifIFD.UserComment)
        if user_comment:
            if user_comment.startswith(b"ASCII\x00\x00\x00"):
                return user_comment[8:].decode("ascii")
            elif user_comment.startswith(b"UNICODE\x00"):
                return user_comment[8:].decode("utf-16")
            elif user_comment.startswith(b"JIS\x00\x00\x00"):
                return user_comment[8:].decode("shift_jis")
            else:
                return user_comment.decode("utf-8", errors="ignore")
        return None
    except Exception as e:
        return f"Error reading EXIF: {e}"


def sendImages():

    imagePaths = glob.glob("./Images/*.jpg")

    #! add proper url here
    url = "https://radcm.sorciermahep.tech/api/anomalies/images"

    for imagePath in imagePaths:

        location = extract_user_comment(imagePath).split()
        print(location)
        lat = float(location[0])
        lng = float(location[1])

        data = {
            "source": "imageModule",
            "lat": lat,
            "lng": lng,
        }

        with open(imagePath, "rb") as imgage:

            files = {"image": imgage}

            response = requests.post(url, files=files, data=data)

        print(f"Sent {imagePath} - Status: {response.status_code}")
        print(response.text)


def handleImages(messageQue):

    imageNo = 0

    if DEBUG:
        import os

        print("hello")
        print(os.getcwd())

    while True:

        # check if the current command is to start the survey
        if not messageQue.empty() and messageQue.queue[0] == "start":

            frame = readImage()

            if not DEBUG:
                # if frame is read correctly frame will have some value
                if not frame:
                    print("Can't capture image, retrying ...")
                    time.sleep(0.33)
                    continue
            else:
                # if frame is read correctly frame will have some value
                if not frame:
                    print("Can't capture image, exiting ...")
                    time.sleep(0.33)
                    break

            # ! get current gps coordinates.... using a simulated value now, because we have only one gps module that's currently in jimmy
            # this must sound so weird out of context

            lng = 34.21
            lat = 12.42

            # save the image to the... "database", a local file directory in our case :)
            saveImage(frame, lat, lng, imageNo)
            imageNo += 1

            print(f"survey running, saving image-{imageNo} ...")

        elif not messageQue.empty() and messageQue.queue[0] == "stop":

            # stop survey now...
            print("hello survey stopped...")
            # remove the "stop" command from the queue
            messageQue.get()

        elif not messageQue.empty() and messageQue.queue[0] == "sendImages":
            # send all the images in the "database"
            sendImages()
            # remove the "sendImages" command from the queue
            messageQue.get()

        elif not messageQue.empty():
            # should be an unreachable state, but just incase it's reached....
            messageQue.get()
            print("strange error, message in the queue that doesn't belong there")
            time.sleep(0.1)

        # to prevent this thread from just going ham when the queue is empty, adding a tiny delay
        else:
            time.sleep(0.1)
