from naoqi import ALProxy
# import opencv-python
import cv2
# from skimage import filters, feature, io, transform
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
    resolution = 3  # VGA
    colorSpace = 11  # RGB

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
        cv2.drawContours(img, inner_contours, -1, (0, 250, 0), 3)
        imgCopy = cv2.resize(img, None, fx=0.5, fy=0.5, interpolation=cv2.INTER_CUBIC)
        cv2.imshow("inner contours", imgCopy)
        cv2.waitKey(0)
        cv2.destroyAllWindows()
        detect_connect_four_state(img=input_img, debug=debug, minRadius=5, maxRadius=15)
        # print("Contours not detected correctly. Please adjust method parameters or improve image quality")


def detect_connect_four_state(img, debug=[], minRadius=60, maxRadius=120, acc_thresh=15, circle_distance=100,
                              gaussian_kernel_size=7, canny_lower_thresh=0, canny_upper_thresh=70, dilate_iterations=2,
                              erode_iterations=1, white_thresh=250, red_thresh=100):
    gamestate = [["-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-"],
                 ["-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-"],
                 ["-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-"]]
    processed_img = process_image_to_edge_map(img=img, gaussian_kernel_size=gaussian_kernel_size,
                                              canny_lower_thresh=canny_lower_thresh,
                                              canny_upper_thresh=canny_upper_thresh,
                                              dilate_iterations=dilate_iterations, erode_iterations=erode_iterations)
    # edge_img, all_contours, inner_contours = find_board_contours(img, debug)
    if 1 in debug:
        # cv2.drawContours(img, all_contours, -1, (0, 0, 250), 3)
        processedImgRes = cv2.resize(processed_img, None, fx=0.5, fy=0.5, interpolation=cv2.INTER_CUBIC)
        cv2.imshow("Processed image", processedImgRes)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    circles = cv2.HoughCircles(processed_img, cv2.HOUGH_GRADIENT, 1, circle_distance, param1=200,
                               param2=acc_thresh, minRadius=minRadius, maxRadius=maxRadius)
    if circles is not None:
        img_width = float(img.shape[1])
        img_height = float(img.shape[0])
        if 2 in debug:
            for c in circles[0, :]:
                a, b, r = c[0], c[1], c[2]
                cv2.circle(img, (a, b), r, (250, 0, 0), 5)
            imgRes = cv2.resize(img, None, fx=0.5, fy=0.5, interpolation=cv2.INTER_CUBIC)
            cv2.imshow("Processed image", imgRes)
            cv2.waitKey(0)
            cv2.destroyAllWindows()
        circles = np.array(circles[0, :]).astype("int")
        circles = np.array(sorted(circles, key=lambda x: [x[1]]))
        if (len(circles) == 42):
            circles = circles.reshape(6, 7, 3)
            circleCount = 0
            # lower_red = np.array([0, 0, 200], dtype = "uint8")
            # upper_red= np.array([0, 0, 255], dtype = "uint8")
            # lower_yellow = np.array([0, 0, 200], dtype = "uint8")
            # upper_yellow = np.array([0, 0, 255], dtype = "uint8")

            for i, row in enumerate(circles):
                row = np.array(sorted(row, key=lambda x: [x[0]]))
                for j, pt in enumerate(row):
                    circleCount += 1
                    # print("Circle nr: ", circleCount, "X-Pos: ", pt[0], "Y-Pos: ", pt[1])
                    a, b, r = pt[0], pt[1], pt[2]
                    avgColor = np.average(img[b][a])
                    if avgColor < white_thresh:
                        if (img[b][a][2] - red_thresh > img[b][a][1] and img[b][a][2] - red_thresh > img[b][a][0]):
                            gamestate[i][j] = "R"
                        # elif cv2.inRange(img[b,a], lower_yellow, upper_yellow):
                        else:
                            gamestate[i][j] = "Y"
                    cv2.putText(img, str(circleCount), (a, b), cv2.FONT_HERSHEY_SIMPLEX, fontScale=1, color=(250, 0, 0),
                                thickness=2)

                    cv2.circle(img, (a, b), r, (250, 0, 0), 5)
            print("Gamestate:")
            for line in gamestate:
                linetxt = ""
                for cel in line:
                    linetxt = linetxt + "|" + cel
                print(linetxt)
            imgRes = cv2.resize(img, None, fx=0.5, fy=0.5, interpolation=cv2.INTER_CUBIC)
            cv2.imshow("Processed image", imgRes)
            cv2.waitKey(0)
            cv2.destroyAllWindows()
        else:
            print("Field not detected correctly")


def detect_tictactoe_state(img, debug=[], tile_offset=20, minRadius=40, maxRadius=80, acc_thresh=15,
                           contour_area_thresh=500, gaussian_kernel_size=7, canny_lower_thresh=0, canny_upper_thresh=70,
                           dilate_iterations=2, erode_iterations=1):
    # create a 2d array to hold the gamestate
    gamestate = [["-", "-", "-"], ["-", "-", "-"], ["-", "-", "-"]]
    edge_img, all_contours, inner_contours = find_board_contours(img, debug, contour_area_thresh=contour_area_thresh,
                                                                 gaussian_kernel_size=gaussian_kernel_size,
                                                                 canny_lower_thresh=canny_lower_thresh,
                                                                 canny_upper_thresh=canny_upper_thresh,
                                                                 dilate_iterations=dilate_iterations,
                                                                 erode_iterations=erode_iterations)
    if len(inner_contours) == 9:
        for cnt in inner_contours:
            # use boundingrect to get coordinates of tile
            x, y, w, h = cv2.boundingRect(cnt)
            # create new image from binary, for further analysis. Trim off the edge that has a line
            tile = edge_img[y + tile_offset:y + h - tile_offset, x + tile_offset:x + w - tile_offset]

            # determine the array indexes of the tile
            tileX = int(round(x / w))
            tileY = int(round(y / h))
            tileCount = 0
            if tileY == 0 and tileX == 0:
                tileCount = 1
            elif (tileY == 1 and tileX == 0):
                tileCount = 4
            elif (tileY == 2 and tileX == 0):
                tileCount = 7
            elif (tileY == 0 and tileX == 1):
                tileCount = 2
            elif (tileY == 1 and tileX == 1):
                tileCount = 5
            elif (tileY == 2 and tileX == 1):
                tileCount = 8
            elif (tileY == 0 and tileX == 2):
                tileCount = 3
            elif (tileY == 1 and tileX == 2):
                tileCount = 6
            elif (tileY == 2 and tileX == 2):
                tileCount = 9
            else:
                print("Undefined tile!")
                tileCount = -1

            if 3 in debug:
                print("tile nr: ", tileCount, " x: ", x, " y: ", y, " width: ", w, " height: ", h, "tileX: ", tileX,
                      " tileY: ", tileY)

            if 4 in debug:
                tileRes = cv2.resize(tile, None, fx=2, fy=2, interpolation=cv2.INTER_CUBIC)
                cv2.imshow(str(tileCount), tileRes)
                cv2.waitKey(0)
                cv2.destroyAllWindows()

            # HoughCircles(image, Method, ratio of accumulator array, minDist between circles, param1 for houghGrad higher canny thres, param2 for houghGrad accumulator array thres)
            if tileCount != -1:
                circles = cv2.HoughCircles(tile, cv2.HOUGH_GRADIENT, 1, 200, param1=200,
                                           param2=acc_thresh, minRadius=minRadius, maxRadius=maxRadius)
                if circles is not None:
                    cv2.drawContours(img, [cnt], -1, (255, 0, 0), 5)
                    for pt in circles[0, :]:
                        a, b, r = int(pt[0] + x + tile_offset), int(pt[1] + y + tile_offset), pt[2]

                        cv2.circle(img, (a, b), r, (255, 0, 0), 10)
                        gamestate[tileY][tileX] = "O"
                        print("circle in ", tileCount)
                # put a number in the tile
                else:
                    lines = cv2.HoughLinesP(
                        tile,  # Input edge image
                        1,  # Distance resolution in pixels
                        np.math.pi / 180,  # Angle resolution in radians
                        threshold=9,  # Min number of votes for valid line
                        minLineLength=50,  # Min allowed length of line
                        maxLineGap=10  # Max allowed gap between line for joining them
                    )
                    if lines is not None:
                        # # Iterate over points
                        cv2.drawContours(img, [cnt], -1, (255, 0, 0), 5)
                        for points in lines:
                            # Extracted points nested in the list
                            x1, y1, x2, y2 = points[0]
                            # Draw the lines joing the points
                            # On the original image
                            cv2.line(img, (x1 + x + tile_offset, y1 + y + tile_offset),
                                     (x2 + x + tile_offset, y2 + y + tile_offset), (255, 0, 0), 2)
                        gamestate[tileY][tileX] = "X"
                        print("Cross in ", tileCount)

                cv2.putText(img, str(tileCount), (x + 10, y + 30), cv2.FONT_HERSHEY_SIMPLEX, fontScale=1,
                            color=(0, 0, 255), thickness=2)
                if 6 in debug:
                    center = _get_center_position_of_rectangle(x, x + w, y, y + h)
                    cv2.circle(img, center, 5, (0, 255, 0))

        #if len(all_contours) > 0:
            # print the gamestate
        print("Gamestate:")
        for line in gamestate:
            linetxt = ""
            for cel in line:
                linetxt = linetxt + "|" + cel
            print(linetxt)
            # resize final image
            #res = cv2.resize(img, None, fx=0.5, fy=0.5, interpolation=cv2.INTER_CUBIC)
            # display image and release resources when key is pressed
            #  cv2.imshow('Result',res)
            #   cv2.waitKey(0)
            #  cv2.destroyAllWindows()
        return gamestate
    else:
        return None


def find_board_contours(img, debug, contour_area_thresh=500, gaussian_kernel_size=7, canny_lower_thresh=0,
                        canny_upper_thresh=70, dilate_iterations=2, erode_iterations=1):
    if 1 in debug:
        imgRes = cv2.resize(img, None, fx=0.5, fy=0.5, interpolation=cv2.INTER_CUBIC)
        cv2.imshow("Input image", imgRes)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    processed_img = process_image_to_edge_map(img=img, gaussian_kernel_size=gaussian_kernel_size,
                                              canny_lower_thresh=canny_lower_thresh,
                                              canny_upper_thresh=canny_upper_thresh,
                                              dilate_iterations=dilate_iterations, erode_iterations=erode_iterations)
    copy = np.copy(processed_img)
    if 2 in debug:
        threshRes = cv2.resize(processed_img, None, fx=0.5, fy=0.5, interpolation=cv2.INTER_CUBIC)
        cv2.imshow("Processed image", threshRes)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    all_contours, hierarchy = cv2.findContours(copy, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    if all_contours is None:
        print("Error with contours")
        exit(1)
    inner_contours = []
    print(len(all_contours), len(hierarchy[0]))
    for i in range(len(all_contours)):
        h = hierarchy[0][i]
        if h[3] == 0 and cv2.contourArea(all_contours[i]) > contour_area_thresh:
            inner_contours.append(all_contours[i])
    cv2.drawContours(img, inner_contours, -1, (0, 255, 0), 3)
    if 5 in debug:
        cv2.imshow("inner contours", img)
        cv2.waitKey(0)
        cv2.destroyAllWindows()
    print("inner contours size: ", len(inner_contours))
    return processed_img, all_contours, inner_contours


def process_image_to_edge_map(img, gaussian_kernel_size=7, canny_lower_thresh=0, canny_upper_thresh=70,
                              dilate_iterations=2, erode_iterations=1):
    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img_blur = cv2.GaussianBlur(img_gray, (gaussian_kernel_size, gaussian_kernel_size), 0)
    # threshRes = cv2.resize(img_blur,None,fx=0.5, fy=0.5, interpolation = cv2.INTER_CUBIC)
    # cv2.imshow("Processed image", threshRes)
    # cv2.waitKey(0)
    # cv2.destroyAllWindows()
    img_canny = cv2.Canny(img_blur, canny_lower_thresh, canny_upper_thresh)
    kernel = np.ones((2, 2))
    img_dilate = cv2.dilate(img_canny, kernel, iterations=dilate_iterations)
    return cv2.erode(img_dilate, kernel, iterations=erode_iterations)


def _get_center_position_of_rectangle(x1, x2, y1, y2):
    return (x1 + int((x2 - x1) / 2), int(y1 + (y2 - y1) / 2))


def record_image_from_nao(path, ip, port):
    recorded = get_image_from_nao(ip, port)
    recorded = cv2.cvtColor(recorded, cv2.COLOR_BGR2RGB)
    # cv2.imshow('Detected', recorded)
    # cv2.waitKey(0)
    cv2.imwrite(path, recorded)


if __name__ == "__main__":
    # test1_cut = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\vision\\test1_cut.jpg')
    # test2_cut = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\vision\\test2_cut.jpg')
    # test3_cut = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\vision\\test3_cut.jpg')
    # test4_cut = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\vision\\test4_cut.jpg')
    # recorded = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\vision\\recorded2_cut.png')
    # connect4_filled = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\vision\\connect_four_filled_cut.png')
    # connect4_recorded = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\vision\\connect4_recorded_glare.png')
    connect4_recorded = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\connect4_rims_filled.png')
    test = cv2.imread('C:\\Users\\jogehring\\Documents\\GitHub\\naolympics\\tic_tac_toe.png')

    # detect_connect_four_state(img=connect4_recorded, debug=[2], minRadius=40, maxRadius=55,acc_thresh=20,circle_distance=120, canny_upper_thresh=30, dilate_iterations=4, erode_iterations=1, gaussian_kernel_size=13, white_thresh=210)
    detect_tictactoe_state(img=test, debug=[2], minRadius=75, maxRadius=85, acc_thresh=20, canny_upper_thresh=30,
                           dilate_iterations=8, erode_iterations=4, gaussian_kernel_size=7)
    # detect_game_board(connect4_recorded, debug=[1])
    # record_image_from_nao(path=".\\tic_tac_toe.png", ip="10.30.4.13", port=9559)

    """
            Fuer real life images:

        
            TICTACTOE:
            - Canny: ca. 20-40 upper, bestes Ergebnis bisher 30
            - Gauss: ca. 5-9, bestes Ergebnis bisher 7
            - Dilate: ca. 8-12, bestes Ergebnis bisher 8
            - Erode: ca. 2-8, bestes Ergebnis bisher 4
            - Hough Radius Range: bestes Ergebnis bisher 75-80
            - Circle Acc Thresh: So hoch wie moeglich, so niedrig wie noetig. Bestes Ergebnis bisher 20
            
            - Wenn acc_thresh hoeher -> erode muss niedriger werden
            
            CONNECT4:
            - Canny: ca. 20-40 upper, bestes Ergebnis bisher 30
            - Gauss: ca. 9-15, bestes Ergebnis bisher 13
            - Dilate: ca. 0-4, bestes Ergebnis bisher 4
            - Erode: ca. 0-2, bestes Ergebnis bisher 1
            - Hough Radius Range: bestes Ergebnis bisher 40-55
            - Circle Acc Thresh: So hoch wie moeglich, so niedrig wie noetig. Bestes Ergebnis bisher 20
            - white_thresh: So hoch wie moeglich, so niedrig wie noetig. Bestes Ergebnis bisher 210
            - red_thresh: So hoch wie moeglich, so niedrig wie noetig. Bestes Ergebnis bisher 100
        """
