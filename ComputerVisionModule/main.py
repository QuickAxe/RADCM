from queue import Queue
from threading import Thread

import cv2 as cv

from server import runServer
from Images import handleImages

DEBUG = False

# global queue for managing messages between the threads
messageQue = Queue()

# the time to wait between consequitive images while performing a survey, in seconds
TIMEBETWEENIMAGES = 0.5
#! this is useless now, as the new image capturing command itself takes a long time

# if not DEBUG:
#     # init the open cv object to use the webcam
#     cap = cv.VideoCapture(0)
# else:
#     cap = cv.VideoCapture("ComputerVisionModule/sampleVideo.mp4")


# create threads for the server and one for the images handling code
t0 = Thread(target=runServer, args=(messageQue,))
t1 = Thread(target=handleImages, args=(messageQue))

if __name__ == "__main__":
    # start running the threads
    t0.start()
    t1.start()
