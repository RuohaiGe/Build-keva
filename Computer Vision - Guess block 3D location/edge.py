import numpy as np
import cv2 as cv

THRES = 1.2
BLUR_LEVEL = 3

#threshold
img = cv.imread('planks1.jpg')
img_copy = img

#threshold out white and black background
for i in range(img.shape[0]):
    for j in range(img.shape[1]):
        pixel = (int(img[i,j,0]),int(img[i,j,1]),int(img[i,j,2]))
        pixel_avg = (pixel[0]+pixel[1]+pixel[2]) / 3.0
        if(pixel_avg == 0): pixel_avg = 1;
        pixel_normalized = (pixel[0]/pixel_avg,pixel[1]/pixel_avg,pixel[2]/pixel_avg)
        if(pixel_normalized[0] < THRES and pixel_normalized[1] < THRES and pixel_normalized[2] < THRES):
            img_copy[i,j] = [0,0,0]

#Show the threshold result
cv.imshow('img_copy',img_copy)
cv.waitKey(0)
cv.destroyAllWindows()

#Blur the image and show the result
blur = cv.blur(img_copy, (BLUR_LEVEL, BLUR_LEVEL))
cv.imshow('blur',blur)
cv.waitKey(0)
cv.destroyAllWindows()

#Detect edges using canny method and show the result
edges = cv.Canny(blur, 100, 200)
cv.imshow('edges',edges)
cv.waitKey(0)
cv.destroyAllWindows()