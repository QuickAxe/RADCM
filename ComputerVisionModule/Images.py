import cv2 as cv
import time 

def handleImages(messageQue, cap, timeBetweenImages):
    
    imageNo = 0

    while True:

        # check if the queue has a value, meaning that the survey should continue 
        if( not messageQue.empty() and messageQue.queue[0] == "start"):
            ret, frame = cap.read()
        
            # if frame is read correctly ret is True
            if not ret:
                print("Can't capture image, retrying ...")
                time.sleep(0.33)
                continue 
                
            # ! get current gps coordinates.... using a simulated value now, because we have only one gps module that's currently in jimmy
            # this must sound so weird out of context 

            lng = 34.21
            lat = 12.42

            # save the image to the... "database", a local file directory in our case :)
            filename = f"images/{imageNo}.jpg"        
            cv.imwrite(filename, frame)

            print("survey running, sending {imageNo} image...")

            # wait for a certain time to take the next image 
            time.sleep(timeBetweenImages)
        
        elif( not messageQue.empty() and messageQue.queue[0] == "stop"):
            
            #! send all images back to the server? or to the phone??
            print("hello survey stopped, sending all images now...")
            
