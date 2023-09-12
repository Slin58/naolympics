from vision import vision


def connect4_error_count(robotIP, PORT, iterations=1000):
    field_after_move = \
        [['-', '-', '-', '-', '-', '-', '-'],
         ['-', '-', '-', '-', '-', '-', '-'],
         ['-', '-', '-', '-', '-', '-', '-'],
         ['-', '-', '-', 'R', '-', '-', '-'],
         ['Y', 'R', 'R', 'Y', 'R', 'Y', '-'],
         ['Y', 'Y', 'R', 'R', 'Y', 'R', 'Y']]
    wrong_count = 0
    for i in range(iterations):
        fail = vision.get_image_from_nao(robotIP, PORT)
        field = vision.detect_connect_four_state(fail, debug=[], minRadius=55, maxRadius=65, acc_thresh=10,
                                                 circle_distance=120, canny_upper_thresh=30, dilate_iterations=4,
                                                 erode_iterations=1, gaussian_kernel_size=13)
        if field != field_after_move:
            print(i)
            if field != None:
                for row in field:
                    print(row)
            wrong_count += 1
    print(wrong_count)


def tictactoe_error_count(robotIP, PORT, iterations=1000):
    field_after_move = [["-", "X", "-"], ["O", "X", "O"], ["X", "O", "O"]]
    wrong_count = 0
    for i in range(iterations):
        fail = vision.get_image_from_nao(robotIP, PORT)
        field = vision.detect_tictactoe_state(fail, minRadius=65, maxRadius=85,
                                              acc_thresh=15,
                                              canny_upper_thresh=25, dilate_iterations=8, erode_iterations=4,
                                              gaussian_kernel_size=9)
        if field != field_after_move:
            print(i)
            if field != None:
                for row in field:
                    print(row)
            wrong_count += 1
    print(wrong_count)


if __name__ == "__main__":
    robotIP = "10.30.4.13"
    PORT = 9559
    connect4_error_count(robotIP, PORT)
