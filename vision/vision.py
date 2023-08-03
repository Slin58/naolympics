from naoqi import ALProxy
import time
import sys
import argparse
import cv2
from skimage import filters, feature, io, transform
from skimage.color import rgb2gray
from PIL import Image
import numpy as np
import vision_definitions
"""
  First get an image from Nao, then show it on the screen with PIL.
  """
def get_image_from_nao(ip, port):
    foreheadCam = 2
    camProxy = ALProxy("ALVideoDevice", ip, port)
    # visionProxy = ALProxy("ALVisionRecognition", ip, port)
    # visionProxy.open
    camProxy.setParam(vision_definitions.kCameraSelectID, foreheadCam)
    resolution = 3    # VGA
    colorSpace = 11   # RGB

    videoClient = camProxy.subscribe("python_client", resolution, colorSpace, 5)
  # Get a camera image.
  # image[6] contains the image data passed as an array of ASCII chars.
    naoImage = camProxy.getImageRemote(videoClient)

    camProxy.unsubscribe(videoClient)


  # Now we work with the image returned and save it as a PNG  using ImageDraw
  # package.

  # Get the image size and pixel array.
    imageWidth = naoImage[0]
    imageHeight = naoImage[1]
    array = naoImage[6]
    im = Image.frombytes("RGB", (imageWidth, imageHeight), array)
    np_im = np.asarray(im)
    return rgb2gray(np_im)

def findBiggestContour(mask):
        temp_bigger = []
        img1, cont, hier = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
        if len(cont) == 0:
                return False
        for cnt in cont:
                temp_bigger.append(cv2.contourArea(cnt))
        greatest = max(temp_bigger)
        index_big = temp_bigger.index(greatest)
        cv2.drawContours(mask, cont, index_big, (255, 0, 0), 3)
        

def find_tic_tac_toe_board(image):
    # Konvertieren Sie das Bild in Graustufen
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Fuehren Sie eine Kanten-Erkennung durch
    edges = cv2.Canny(gray_image, 150, 250, apertureSize=3)

    # Fuehren Sie die Hough-Transformation durch, um die Linien zu finden
    lines = cv2.HoughLinesP(edges, 1, 2*np.math.pi/180, threshold=100, minLineLength=300, maxLineGap=10)

    # Zeichnen Sie die Linien auf ein leeres Bild (nur fuer die Visualisierung)
    line_image = np.zeros_like(image)
    for line in lines:
        x1, y1, x2, y2 = line[0]
        cv2.line(image, (x1, y1), (x2, y2), (0, 255, 0), 2)

    # Finden Sie die Eckpunkte des TicTacToe-Spielfeldes
    corners = cv2.goodFeaturesToTrack(edges, 4, 0.01, 10)
    corners = np.int0(corners)

    # Zeichnen Sie die Eckpunkte auf ein leeres Bild (nur fuer die Visualisierung)
    corner_image = np.zeros_like(image)
    for corner in corners:
        x, y = corner.ravel()
        cv2.circle(image, (x, y), 5, (0, 0, 255), -1)

    # Rueckgabe der Eckpunkte des Spielfeldes
    cv2.imshow('image1',image)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    return corners

def template_match(image, patch):
                # Read the main image
        img_rgb = image
        
        # Convert it to grayscale
        img_gray = cv2.cvtColor(img_rgb, cv2.COLOR_BGR2GRAY)
        
        # Read the template
        template = cv2.cvtColor(patch, cv2.COLOR_BGR2GRAY)
        
        # Store width and height of template in w and h
        w, h = template.shape[::-1]
        
        # Perform match operations.
        res = cv2.matchTemplate(img_gray, template, cv2.TM_CCOEFF_NORMED)
        min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(res)
        # If the method is TM_SQDIFF or TM_SQDIFF_NORMED, take minimum
        top_left = max_loc
        bottom_right = (top_left[0] + w, top_left[1] + h)
        
        # print(top_left[0],top_left[0]+w, top_left[1],top_left[1]+h)
        result = img_rgb[top_left[1]:top_left[1]+h, top_left[0]:top_left[0]+w]
        
        # cv2.rectangle(img_rgb,top_left, bottom_right, 255, 2)
        # res = cv2.resize(img_rgb,None,fx=0.5, fy=0.5, interpolation = cv2.INTER_CUBIC)
        # cv2.imshow('Detected', res)
        # cv2.waitKey(0)
        return result

def current_approach(img, debug=[], tile_canny=0, tile_offset=40):
        #create a 2d array to hold the gamestate
        gamestate = [["-","-","-"],["-","-","-"],["-","-","-"]]

        #kernel used for noise removal
        kernel =  np.ones((5,5),np.uint8)
        # get the image width and height
        img_width = img.shape[0]
        img_height = img.shape[1]
        if 1 in debug:
            imgRes = cv2.resize(img,None,fx=0.5, fy=0.5, interpolation = cv2.INTER_CUBIC)
            cv2.imshow("Input image", imgRes)
            cv2.waitKey(0)
            cv2.destroyAllWindows()
        
        thresh1 = process(img)

        if 2 in debug:
            threshRes = cv2.resize(thresh1,None,fx=0.5, fy=0.5, interpolation = cv2.INTER_CUBIC)
            cv2.imshow("Processed image", threshRes)
            cv2.waitKey(0)
            cv2.destroyAllWindows()


        #find and draw contours. RETR_EXTERNAL retrieves only the extreme outer contours
        contours, hierarchy = cv2.findContours(thresh1, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        if(len(contours) > 1):
            contours = sorted(contours, key=lambda x: cv2.contourArea(x))[1:]
            print("contours size: ", len(contours))

        elif len(contours) is 1:
        
            # cv2.drawContours(img, contours, -1, (0,255,0), 15)
            x,y,w,h = cv2.boundingRect(contours[0])
            contourCut = thresh1[x:x+w, y:y+h]
            cont, hierarchy = cv2.findContours(contourCut, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
            contours = []
            for i in range(len(hierarchy[0])):
                h = hierarchy[0][i]
                if h[3] == 0:
                    contours.append(cont[i])
            cv2.drawContours(img, contours, -1, (0, 255, 0), 15)
            # print("inner contours size: ", len(cont))
        


        for cnt in contours:
                        # use boundingrect to get coordinates of tile
                        x,y,w,h = cv2.boundingRect(cnt)
                        center = _get_center_position_of_rectangle(x,x+w, y, y+h)
                        # create new image from binary, for further analysis. Trim off the edge that has a line
                        # tile = thresh1[x+40:x+w-80,y+40:y+h-80]
                        if tile_canny:
                            tile = cv2.Canny(thresh1[y+tile_offset:y+h-tile_offset,x+tile_offset:x+w-tile_offset], 100, 150)
                        else:
                            tile = thresh1[y+tile_offset:y+h-tile_offset,x+tile_offset:x+w-tile_offset]


                        # tileCont, tileHier = cv2.findContours(tile, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
                        # cv2.drawContours(img, tileCont, -1, (0, 250, 0), 10)
                        # create new image from main image, so we can draw the contours easily
                        # cv2.drawContours(thresh1, [cnt], -1, (255,0,0), 15)
                        #determine the array indexes of the tile
                        tileX = int(round(x/w))
                        tileY = int(round(y/h))
                        tileCount = 0
                        if(tileY == 0 and tileX == 0):
                            tileCount = 1
                        elif(tileY == 1 and tileX == 0):
                            tileCount = 4
                        elif(tileY == 2 and tileX == 0):
                            tileCount = 7
                        elif(tileY == 0 and tileX == 1):
                            tileCount = 2
                        elif(tileY == 1 and tileX == 1):
                            tileCount = 5
                        elif(tileY == 2 and tileX == 1):
                            tileCount = 8
                        elif(tileY == 0 and tileX == 2):
                            tileCount = 3
                        elif(tileY == 1 and tileX == 2):
                            tileCount = 6
                        elif(tileY == 2 and tileX == 2):
                            tileCount = 9
                        else:
                             print("Undefined tile!")
                        
                        if 3 in debug:
                            print("tile nr: ", tileCount, " x: ",x, " y: ",y," width: ",w, " height: ",h,"tileX: ",tileX," tileY: ",tileY)  
                            
                        
                        if 4 in debug:
                            tileRes = cv2.resize(tile,None,fx=0.5, fy=0.5, interpolation = cv2.INTER_CUBIC)

                            cv2.imshow(str(tileCount), tileRes)
                            cv2.waitKey(0)
                            cv2.destroyAllWindows()
                            
                        #HoughCircles(image, Method, ratio of accumulator array, minDist between circles, param1 for houghGrad higher canny thres, param2 for houghGrad accumulator array thres)
                        circles = cv2.HoughCircles(tile,cv2.HOUGH_GRADIENT, 1, 200, param1 = 200,
                param2 = 20, minRadius = 65, maxRadius = 130)
                        if(circles is not None):
                                cv2.drawContours(img, [cnt], -1, (255, 0,0), 5)
                                for pt in circles[0,:]:
                                    a, b, r = int(pt[0]+x+tile_offset), int(pt[1]+y+tile_offset), pt[2]
    
                                    cv2.circle(img, (a, b), r, (255, 0, 0), 10)
                                    gamestate[tileY][tileX] = "O"
                                    print("circle in ", tileCount)
                            # put a number in the tile
                        

                        else:
                            lines = cv2.HoughLinesP(
                                    tile, # Input edge image
                                    1, # Distance resolution in pixels
                                    np.math.pi/180, # Angle resolution in radians
                                    threshold=9, # Min number of votes for valid line
                                    minLineLength=50, # Min allowed length of line
                                    maxLineGap=10 # Max allowed gap between line for joining them
                                    )
                            if(lines is not None):
                                # # Iterate over points
                                cv2.drawContours(img, [cnt], -1, (255, 0,0), 5)
                                for points in lines:
                                        # Extracted points nested in the list
                                    x1,y1,x2,y2=points[0]
                                        # Draw the lines joing the points
                                        # On the original image
                                    cv2.line(img,(x1+x+tile_offset,y1+y+tile_offset),(x2+x+tile_offset,y2+y+tile_offset),(255,0,0),2)
                                gamestate[tileY][tileX] = "X"
                                print("Cross in ", tileCount)

                        cv2.putText(img, str(tileCount), (x+75, y+300), cv2.FONT_HERSHEY_SIMPLEX, 10, (0,0,255), 20)
                        cv2.circle(img, center, 5, (0, 255, 0))

                        
        if len(contours) > 0:
            
            #print the gamestate
            print("Gamestate:")
            for line in gamestate:
                    linetxt = ""
                    for cel in line:
                            linetxt = linetxt + "|" + cel
                    print(linetxt)

            # resize final image
            res = cv2.resize(img,None,fx=0.5, fy=0.5, interpolation = cv2.INTER_CUBIC)

            # display image and release resources when key is pressed
            cv2.imshow('Result',res)
            cv2.waitKey(0)
            cv2.destroyAllWindows()


def process(img):
    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img_blur = cv2.GaussianBlur(img_gray, (9, 9), 0)
    img_canny = cv2.Canny(img_blur, 0, 100)
    kernel = np.ones((2, 2))
    img_dilate = cv2.dilate(img_canny, kernel, iterations=10)
    return cv2.erode(img_dilate, kernel, iterations=4)

def convex_hull(cnt):
    peri = cv2.arcLength(cnt, True)
    approx = cv2.approxPolyDP(cnt, peri * 0.02, True)
    return cv2.convexHull(approx).squeeze()

def centers(inner, outer):
    c = inner[..., 0].argsort()
    top_lef2, top_rit2 = sorted(inner[c][:2], key=list)
    bot_lef2, bot_rit2 = sorted(inner[c][-2:], key=list)
    c1 = outer[..., 0].argsort()
    c2 = outer[..., 1].argsort()
    top_lef, top_rit = sorted(outer[c1][:2], key=list)
    bot_lef, bot_rit = sorted(outer[c1][-2:], key=list)
    lef_top, lef_bot = sorted(outer[c2][:2], key=list)
    rit_top, rit_bot = sorted(outer[c2][-2:], key=list)
    yield inner.mean(0)
    yield np.mean([top_lef, top_rit, top_lef2, top_rit2], 0)
    yield np.mean([bot_lef, bot_rit, bot_lef2, bot_rit2], 0)
    yield np.mean([lef_top, lef_bot, top_lef2, bot_lef2], 0)
    yield np.mean([rit_top, rit_bot, top_rit2, bot_rit2], 0)
    yield np.mean([top_lef, lef_top], 0)
    yield np.mean([bot_lef, lef_bot], 0)
    yield np.mean([top_rit, rit_top], 0)
    yield np.mean([bot_rit, rit_bot], 0)
    
def _get_center_position_of_rectangle(x1,x2,y1,y2):
        return (x1+int((x2-x1)/2), int(y1+(y2-y1)/2))
    
def detect_game_board(source, debug=0):
        img_g =  cv2.cvtColor(source, cv2.COLOR_BGR2GRAY)
        # img_g = cv2.Canny(img_g, 100, 150)
        # turn into thresholded binary
        ret,image = cv2.threshold(img_g,127,255,cv2.THRESH_BINARY)
        # Defining a kernel length
        kernel_length = np.array(image).shape[1]//8
        # A verticle kernel of (1 X kernel_length), which will detect all the verticle lines from the image.
        verticle_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (1, kernel_length))
        # A horizontal kernel of (kernel_length X 1), which will help to detect all the horizontal line from the image.
        hori_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (kernel_length, 1))
        # A kernel of (3 X 3) ones
        kernel = np.array((
            [1, 1, 1],
            [1, 1, 1],
            [1, 1, 1]), dtype="int")
        # Morphological operation to detect vertical lines from an image
        img_temp1 = cv2.erode(image, verticle_kernel, iterations=1)
        verticle_lines_img = cv2.dilate(img_temp1, verticle_kernel, iterations=1)
        if debug > 3:
            cv2.imshow("vlines", verticle_lines_img)
            cv2.waitKey(0)
        # Morphological operation to detect horizontal lines from an image
        img_temp2 = cv2.erode(image, hori_kernel, iterations=1)
        horizontal_lines_img = cv2.dilate(img_temp2, hori_kernel, iterations=1)
        if debug > 3:
            cv2.imshow("hlines", horizontal_lines_img)
            cv2.waitKey(0)
        intersections = cv2.bitwise_and(verticle_lines_img, horizontal_lines_img)
        if debug > 2:
            cv2.imshow("intersections", intersections)
            cv2.waitKey(0)
        # Create a mask, combine verticle and horizontal lines
        mask = verticle_lines_img + horizontal_lines_img
        # Find contours
        contours, hierarchy = cv2.findContours(intersections, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        # Find center positions, order = bottom left, bottom right, upper left, upper right
        positions = []
        red = (0,0,255)
        blue = (255,0,0)

        for i,cnt in enumerate(contours):
            boardweight = 0.1 # decrease this for finer detection
            approx = cv2.approxPolyDP(cnt, boardweight*cv2.arcLength(cnt, True), True)
            cv2.drawContours(source,[cnt],0,red,-1)
            if debug>3:
                cv2.imshow("Showing game board intersection {0}".format(i+1),source)
                cv2.waitKey(0)
            if len(approx) ==4:
                # get the bounding rect
                x, y, w, h = cv2.boundingRect(cnt)
                cv2.rectangle(source, (x,y), (x+w,y+h), (255,0,0), 1)
                if debug>1:                   
                    cv2.imshow("rectangle", source)
                    cv2.waitKey(0)
                center = _get_center_position_of_rectangle(x, x+w, y, y+h)
                positions.append(center)
            else:
                raise Exception("Unable to detect game board intersections. Try to adjust the weight.")
        if (len(positions) != 4):
            raise Exception("Unable to detect 3x3 game board")

if __name__ == "__main__":
  # image = get_image_as_array("10.30.4.32", 9559)  
        # img = cv2.imread('C:\\Users\\jogehring\\Documents\\Projektarbeit\\naolympics\\vision\\with_borders.jpg')
        temp = cv2.imread('C:\\Users\\jogehring\\Documents\\Projektarbeit\\naolympics\\vision\\with_borders_temp.jpg')
        # lol = cv2.imread('C:\\Users\\jogehring\\Documents\\Projektarbeit\\naolympics\\vision\\lol.png')
        # empty = cv2.imread('C:\\Users\\jogehring\\Documents\\Projektarbeit\\naolympics\\vision\\with_borders_empty.jpg')
        test1_cut = cv2.imread('C:\\Users\\jogehring\\Documents\\Projektarbeit\\naolympics\\vision\\test1_cut.jpg')
        test2_cut = cv2.imread('C:\\Users\\jogehring\\Documents\\Projektarbeit\\naolympics\\vision\\test2_cut.jpg')
        test3_cut = cv2.imread('C:\\Users\\jogehring\\Documents\\Projektarbeit\\naolympics\\vision\\test3_cut.jpg')
        test4_cut = cv2.imread('C:\\Users\\jogehring\\Documents\\Projektarbeit\\naolympics\\vision\\test4_cut.jpg')

        # hand_drawn = cv2.imread('C:\\Users\\jogehring\\Documents\\Projektarbeit\\naolympics\\vision\\filledTicTacToe3.png')
        # detected = template_match(img, temp)
        
        # cv2.imshow('Detected', detected)
        # cv2.waitKey(0)
        # detect_game_board(empty, 4)
        current_approach(img=test4_cut, debug=[] , tile_canny=0)
