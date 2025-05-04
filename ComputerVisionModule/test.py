import cv2

video_path = 'ComputerVisionModule/sampleVideo.mp4' # Replace with your video file path
cap = cv2.VideoCapture(video_path)

if not cap.isOpened():
    print("Error: Could not open video file.")
else:
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        cv2.imshow('Video', frame)
        if cv2.waitKey(25) & 0xFF == ord('q'): # Press 'q' to exit
            break
    cap.release()
    cv2.destroyAllWindows()