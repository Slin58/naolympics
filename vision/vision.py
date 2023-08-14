from naoqi import ALProxy
#import opencv-python
import cv2
#from skimage import filters, feature, io, transform
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
    return np_im

def detect_game_board(img, debug=[]):
    input_img = np.copy(img)
    edge_img, all_contours, inner_contours = find_board_contours(img, debug)
    if len(inner_contours) == 9:
        detect_tictactoe_state(img=input_img, debug=debug)
    else:
        detect_connect_four_state(img=input_img, debug=debug)
        # print("Contours not detected correctly. Please adjust method parameters or improve image quality")

def detect_connect_four_state(img, debug=[], minRadius=60, maxRadius=120):
        gamestate = [["-","-","-","-","-","-","-"], ["-","-","-","-","-","-","-"], ["-","-","-","-","-","-","-"], ["-","-","-","-","-","-","-"], ["-","-","-","-","-","-","-"], ["-","-","-","-","-","-","-"]]
        processed_img = process_image_to_edge_map(img)
        if 1 in debug:
            processedImgRes = cv2.resize(processed_img,None,fx=0.5, fy=0.5, interpolation = cv2.INTER_CUBIC)
            cv2.imshow("Processed image", processedImgRes)
            cv2.waitKey(0)
            cv2.destroyAllWindows()
        circles = cv2.HoughCircles(processed_img,cv2.HOUGH_GRADIENT, 1, 200, param1 = 200,
                    param2 = 15, minRadius = minRadius, maxRadius = maxRadius)
        if circles is not None:
            img_width = float(img.shape[1])
            img_height = float(img.shape[0])
            circles = np.array(circles[0,:]).astype("int")
            circles = np.array(sorted(circles, key=lambda x: [x[1]]))
            circles = circles.reshape(6,7,3)
            circleCount = 0
            for i,row in enumerate(circles):
                row = np.array(sorted(row, key=lambda x: [x[0]]))
                for j,pt in enumerate(row):
                    circleCount += 1
                    # print("Circle nr: ", circleCount, "X-Pos: ", pt[0], "Y-Pos: ", pt[1])
                    a, b, r = pt[0], pt[1], pt[2]
                    avgColor = np.average(img[b][a])
                    if avgColor < 250:
                        if img[b][a][2] - 100 > img[b][a][1] and img[b][a][2] - 100 > img[b][a][0]:
                            gamestate[i][j] = "R"
                        else:
                            gamestate[i][j] = "Y"
                    cv2.putText(img, str(circleCount), (a, b), cv2.FONT_HERSHEY_SIMPLEX, fontScale=1, color=(250,0,0), thickness=2)

                    cv2.circle(img, (a, b), r, (250, 0, 0), 5)
        print("Gamestate:")
        for line in gamestate:
            linetxt = ""
            for cel in line:
                    linetxt = linetxt + "|" + cel
            print(linetxt)
        imgRes = cv2.resize(img,None,fx=0.5, fy=0.5, interpolation = cv2.INTER_CUBIC)
        cv2.imshow("Processed image", imgRes)
        cv2.waitKey(0)
        cv2.destroyAllWindows()
            
def detect_tictactoe_state(img, debug=[], tile_offset=20, minRadius=40, maxRadius=80):
        #create a 2d array to hold the gamestate
        gamestate = [["-","-","-"],["-","-","-"],["-","-","-"]]
        edge_img, all_contours, inner_contours = find_board_contours(img, debug)

        for cnt in inner_contours:
                        # use boundingrect to get coordinates of tile
                        x,y,w,h = cv2.boundingRect(cnt)
                        # create new image from binary, for further analysis. Trim off the edge that has a line
                        tile = edge_img[y+tile_offset:y+h-tile_offset,x+tile_offset:x+w-tile_offset]

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
                             tileCount = -1
                        
                        if 3 in debug:
                            print("tile nr: ", tileCount, " x: ",x, " y: ",y," width: ",w, " height: ",h,"tileX: ",tileX," tileY: ",tileY)  
                            
                        if 4 in debug:
                            tileRes = cv2.resize(tile,None,fx=2, fy=2, interpolation = cv2.INTER_CUBIC)
                            cv2.imshow(str(tileCount), tileRes)
                            cv2.waitKey(0)
                            cv2.destroyAllWindows()
                            
                        #HoughCircles(image, Method, ratio of accumulator array, minDist between circles, param1 for houghGrad higher canny thres, param2 for houghGrad accumulator array thres)
                        if tileCount != -1:
                            circles = cv2.HoughCircles(tile,cv2.HOUGH_GRADIENT, 1, 200, param1 = 200,
                    param2 = 25, minRadius = minRadius, maxRadius = maxRadius)
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

                            cv2.putText(img, str(tileCount), (x+10, y+30), cv2.FONT_HERSHEY_SIMPLEX, fontScale=1, color=(0,0,255), thickness=2)
                            if 6 in debug:
                                center = _get_center_position_of_rectangle(x,x+w, y, y+h)
                                cv2.circle(img, center, 5, (0, 255, 0))

        if len(all_contours) > 0:
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
          #  cv2.imshow('Result',res)
         #   cv2.waitKey(0)
          #  cv2.destroyAllWindows()
            return gamestate

def find_board_contours(img, debug):
    if 1 in debug:
        imgRes = cv2.resize(img,None,fx=0.5, fy=0.5, interpolation = cv2.INTER_CUBIC)
        cv2.imshow("Input image", imgRes)
        cv2.waitKey(0)
        cv2.destroyAllWindows()
        
    processed_img = process_image_to_edge_map(img)

    if 2 in debug:
        threshRes = cv2.resize(processed_img,None,fx=0.5, fy=0.5, interpolation = cv2.INTER_CUBIC)
        cv2.imshow("Processed image", threshRes)
        cv2.waitKey(0)
        cv2.destroyAllWindows()
                
    all_contours, hierarchy = cv2.findContours(processed_img, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    if all_contours is None:
        print("Error with contours")
        exit(1)
    inner_contours = []
    print(len(all_contours), len(hierarchy[0]))
    for i in range(len(all_contours)):
        h = hierarchy[0][i]
        if h[3] == 0 and cv2.contourArea(all_contours[i]) > 500:
                inner_contours.append(all_contours[i])
    cv2.drawContours(img, inner_contours, -1, (0, 255, 0), 3)
    if 5 in debug:
        cv2.imshow("inner contours", img)
        cv2.waitKey(0)
        cv2.destroyAllWindows()
    print("inner contours size: ", len(inner_contours))
    return processed_img,all_contours,inner_contours


def process_image_to_edge_map(img):
    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img_blur = cv2.GaussianBlur(img_gray, (7, 7), 0)
    img_canny = cv2.Canny(img_blur, 0, 100)
    kernel = np.ones((2, 2))
    img_dilate = cv2.dilate(img_canny, kernel, iterations=8)
    return cv2.erode(img_dilate, kernel, iterations=4)
     
def _get_center_position_of_rectangle(x1,x2,y1,y2):
        return (x1+int((x2-x1)/2), int(y1+(y2-y1)/2))

def record_image_from_nao(path, ip, port):
    recorded = get_image_from_nao(ip, port) 
    cv2.imshow('Detected', recorded)
    cv2.waitKey(0)
    cv2.imwrite(path, recorded)

if __name__ == "__main__":
        # test1_cut = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\vision\\test1_cut.jpg')
        # test2_cut = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\vision\\test2_cut.jpg')
        # test3_cut = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\vision\\test3_cut.jpg')
        # test4_cut = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\vision\\test4_cut.jpg')
        recorded = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\vision\\recorded_cut.png')
        connect4_filled = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\vision\\connect_four_filled_cut.png')
        detect_connect_four_state(img=connect4_filled, debug=[1])
        # detect_tictactoe_state(img=recorded)
        
