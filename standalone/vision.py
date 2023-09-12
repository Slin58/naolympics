from naoqi import ALProxy
import cv2
import numpy as np
import vision_definitions

"""
  First get an image from Nao, then show it on the screen with PIL.
  """


def get_image_from_nao(ip, port):
    foreheadCam = 2
    camProxy = ALProxy("ALVideoDevice", ip, port)
    # camProxy.setParam(vision_definitions.kCameraSelectID, foreheadCam)
    resolution = 3
    colorSpace = 11
    # videoClient = camProxy.subscribe("python_client", resolution, colorSpace, 5)
    videoClient = camProxy.subscribeCamera("my_client", 0, resolution, colorSpace, 5)  # Kamera-ID 0
    image_data = camProxy.getImageRemote(videoClient)
    naoImage = camProxy.getImageRemote(videoClient)
    camProxy.unsubscribe(videoClient)
    imageWidth = naoImage[0]
    imageHeight = naoImage[1]
    array = naoImage[6]
    image_data = np.frombuffer(array, dtype=np.uint8).reshape(imageHeight, imageWidth, 3)
    return image_data


def record_image_from_nao(path, ip, port):
    recorded = get_image_from_nao(ip, port)
    recorded = cv2.cvtColor(recorded, cv2.COLOR_BGR2RGB)
    cv2.imwrite(path, recorded)


def show_image_from_nao(ip, port):
    recorded = get_image_from_nao(ip, port)
    cv2.imshow('Nao POV', recorded)
    cv2.waitKey(0)
    cv2.destroyAllWindows()


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


def get_pixel_color(pixel, white_lower_thresh):
    red_lower = np.array([0, 0, 10], np.uint8)
    red_upper = np.array([100, 100, 255], np.uint8)

    white_lower = np.array([white_lower_thresh, white_lower_thresh, white_lower_thresh], np.uint8)
    white_upper = np.array([255, 255, 255], np.uint8)

    yellow_lower = np.array([0, 100, 50], np.uint8)
    yellow_upper = np.array([100, 255, 255], np.uint8)

    if cv2.inRange(pixel, red_lower, red_upper).all():
        return "R"
    elif cv2.inRange(pixel, yellow_lower, yellow_upper).all():
        return "Y"
    elif cv2.inRange(pixel, white_lower, white_upper).all():
        return "-"
    else:
        return "F"


def detect_connect_four_state(img, debug=[], minRadius=60, maxRadius=120, acc_thresh=15, circle_distance=100,
                              gaussian_kernel_size=7, canny_lower_thresh=0, canny_upper_thresh=70, dilate_iterations=2,
                              erode_iterations=1, white_thresh=250):
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    gamestate = [["-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-"],
                 ["-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-"],
                 ["-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-"]]
    processed_img = process_image_to_edge_map(img=img, gaussian_kernel_size=gaussian_kernel_size,
                                              canny_lower_thresh=canny_lower_thresh,
                                              canny_upper_thresh=canny_upper_thresh,
                                              dilate_iterations=dilate_iterations, erode_iterations=erode_iterations)
    if 1 in debug:
        processedImgRes = cv2.resize(processed_img, None, fx=0.5, fy=0.5, interpolation=cv2.INTER_CUBIC)
        cv2.imshow("Processed image", processedImgRes)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    circles = cv2.HoughCircles(processed_img, cv2.HOUGH_GRADIENT, 1, circle_distance, param1=200,
                               param2=acc_thresh, minRadius=minRadius, maxRadius=maxRadius)
    if circles is not None:
        if 2 in debug:
            for c in circles[0, :]:
                a, b, r = c[0], c[1], c[2]
                cv2.circle(img, (a, b), r, (250, 0, 0), 5)
            imgRes = cv2.resize(img, None, fx=0.5, fy=0.5, interpolation=cv2.INTER_CUBIC)
            cv2.imshow("Circles detected", imgRes)
            cv2.waitKey(0)
            cv2.destroyAllWindows()
        circles = np.array(circles[0, :]).astype("int")
        circles = np.array(sorted(circles, key=lambda x: [x[1]]))
        if len(circles) == 42:
            circles = circles.reshape(6, 7, 3)
            circle_count = 0

            for i, row in enumerate(circles):
                row = np.array(sorted(row, key=lambda x: [x[0]]))
                for j, pt in enumerate(row):
                    circle_count += 1
                    a, b, r = pt[0], pt[1], pt[2]
                    circle_img = np.zeros((img.shape[0], img.shape[1]),
                                          np.uint8)
                    cv2.circle(circle_img, (a, b), r, (255, 255, 255),
                               -1)
                    avg_rgb = np.array(cv2.mean(img, mask=circle_img)[0:3]).astype(np.uint8)
                    gamestate_detected = get_pixel_color(avg_rgb, white_thresh)
                    white_thresh_adjusted = white_thresh
                    while gamestate_detected == "F" and white_thresh_adjusted >= 0:
                        white_thresh_adjusted -= 10
                        gamestate_detected = get_pixel_color(avg_rgb, white_thresh_adjusted)
                    gamestate[i][j] = gamestate_detected
                    cv2.putText(img, str(circle_count), (a, b), cv2.FONT_HERSHEY_SIMPLEX, fontScale=1,
                                color=(250, 0, 0),
                                thickness=2)

                    cv2.circle(img, (a, b), r, (250, 0, 0), 5)
            if 6 in debug:
                print("Gamestate:")
                for line in gamestate:
                    linetxt = ""
                    for cel in line:
                        linetxt = linetxt + "|" + cel
                    print(linetxt)
            if 7 in debug:
                imgRes = cv2.resize(img, None, fx=0.5, fy=0.5, interpolation=cv2.INTER_CUBIC)
                cv2.imshow("Processed image", imgRes)
                cv2.waitKey(0)
                cv2.destroyAllWindows()

            return gamestate
        else:
            print("Field not detected correctly")


def detect_tictactoe_state(img, debug=[], tile_offset=20, minRadius=40, maxRadius=80, acc_thresh=15,
                           contour_area_thresh=500, gaussian_kernel_size=7, canny_lower_thresh=0, canny_upper_thresh=70,
                           dilate_iterations=2, erode_iterations=1):
    gamestate = [["-", "-", "-"], ["-", "-", "-"], ["-", "-", "-"]]
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    edge_img, outer_contours, inner_contours = find_board_contours(img, debug, contour_area_thresh=contour_area_thresh,
                                                                   gaussian_kernel_size=gaussian_kernel_size,
                                                                   canny_lower_thresh=canny_lower_thresh,
                                                                   canny_upper_thresh=canny_upper_thresh,
                                                                   dilate_iterations=dilate_iterations,
                                                                   erode_iterations=erode_iterations)
    if len(inner_contours) == 9:
        inner_contours = np.array(sorted(inner_contours, key=lambda x: [cv2.boundingRect(x)[1]]))
        inner_contours = np.reshape(inner_contours, (3, 3))
        tileCount = 0
        for i, row in enumerate(inner_contours):
            row = np.array(sorted(row, key=lambda x: [cv2.boundingRect(x)[0]]))
            for j, cnt in enumerate(row):
                tileCount += 1
                x, y, w, h = cv2.boundingRect(cnt)
                tile = edge_img[y + tile_offset:y + h - tile_offset, x + tile_offset:x + w - tile_offset]
                if 4 in debug:
                    tileRes = cv2.resize(tile, None, fx=2, fy=2, interpolation=cv2.INTER_CUBIC)
                    cv2.imshow(str(tileCount), tileRes)
                    cv2.waitKey(0)
                    cv2.destroyAllWindows()
                if tileCount != -1:
                    circles = cv2.HoughCircles(tile, 3L, 1, 200, param1=200,
                                               param2=acc_thresh, minRadius=minRadius, maxRadius=maxRadius)
                    if circles is not None:
                        cv2.drawContours(img, [cnt], -1, (255, 0, 0), 5)
                        for pt in circles[0, :]:
                            a, b, r = int(pt[0] + x + tile_offset), int(pt[1] + y + tile_offset), pt[2]

                            cv2.circle(img, (a, b), r, (255, 0, 0), 10)
                            gamestate[i][j] = "O"
                            print("circle in ", tileCount)
                    # put a number in the tile
                    else:
                        lines = cv2.HoughLinesP(
                            tile,
                            1,
                            np.math.pi / 180,
                            threshold=9,
                            minLineLength=50,
                            maxLineGap=10
                        )
                        if lines is not None:
                            # # Iterate over points
                            cv2.drawContours(img, [cnt], -1, (255, 0, 0), 5)
                            for points in lines:
                                x1, y1, x2, y2 = points[0]
                                cv2.line(img, (x1 + x + tile_offset, y1 + y + tile_offset),
                                         (x2 + x + tile_offset, y2 + y + tile_offset), (255, 0, 0), 2)
                            gamestate[i][j] = "X"
                            print("Cross in ", tileCount)

                    cv2.putText(img, str(tileCount), (x + 10, y + 30), cv2.FONT_HERSHEY_SIMPLEX, fontScale=1,
                                color=(0, 0, 255), thickness=2)
                    if 6 in debug:
                        center = _get_center_position_of_rectangle(x, x + w, y, y + h)
                        cv2.circle(img, center, 5, (0, 255, 0))
        print("Gamestate:")
        for line in gamestate:
            linetxt = ""
            for cel in line:
                linetxt = linetxt + "|" + cel
            print(linetxt)
        if 6 in debug:
            res = cv2.resize(img, None, fx=0.5, fy=0.5, interpolation=cv2.INTER_CUBIC)
            cv2.imshow('Result', res)
            cv2.waitKey(0)
            cv2.destroyAllWindows()
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

    _, all_contours, hierarchy = cv2.findContours(copy, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    if all_contours is None:
        print("Error with contours")
        exit(1)
    inner_contours = []
    outer_contours = []
    print(len(all_contours), len(hierarchy[0]))
    for i in range(len(all_contours)):
        h = hierarchy[0][i]
        if h[3] == 0 and cv2.contourArea(all_contours[i]) > contour_area_thresh:
            inner_contours.append(all_contours[i])
        if h[3] == -1:
            outer_contours.append(all_contours[i])
    cv2.drawContours(img, inner_contours, -1, (0, 255, 0), 3)
    if 5 in debug:
        cv2.imshow("inner contours", img)
        cv2.waitKey(0)
        cv2.destroyAllWindows()
    print("inner contours size: ", len(inner_contours))
    return processed_img, outer_contours, inner_contours


def process_image_to_edge_map(img, gaussian_kernel_size=7, canny_lower_thresh=0, canny_upper_thresh=70,
                              dilate_iterations=2, erode_iterations=1):
    img_gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
    img_blur = cv2.GaussianBlur(img_gray, (gaussian_kernel_size, gaussian_kernel_size), 0)
    img_canny = cv2.Canny(img_blur, canny_lower_thresh, canny_upper_thresh)
    kernel = np.ones((2, 2))
    img_dilate = cv2.dilate(img_canny, kernel, iterations=dilate_iterations)
    return cv2.erode(img_dilate, kernel, iterations=erode_iterations)


def _get_center_position_of_rectangle(x1, x2, y1, y2):
    return x1 + int((x2 - x1) / 2), int(y1 + (y2 - y1) / 2)
