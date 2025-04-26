import cv2 as cv



def takeandSaveImage(cap, imageNo):
    
    ret, frame = cap.read()
 
    # if frame is read correctly ret is True
    if not ret:
        print("Can't capture image, Exiting ...")
        return False 
        
    # ! get current gps coordinates.... using a simulated value now, because we hace only one gps module that's currently in jimmy
    # this must sound so weird out of context 

    lng = 34.21
    lat = 12.42

    # save the image to the... "database", a local file directory in our case :)
    filename = f"{imageNo}.jpg"
    
    cv.imwrite(filename, frame)
    
