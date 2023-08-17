import cv2

from vision import vision
from tictactoe_tactic import tictactoeTactic
from movement import movementControl
import time

# IP address of the NAO robot
robotIP = "10.30.4.13"

# Port number of the ALMotion proxy
PORT = 9559


def play_against_itself(robotIP, PORT):
    circleTurn = True
    img = vision.get_image_from_nao(ip=robotIP, port=PORT)
    field = vision.detect_tictactoe_state(img,debug=[], minRadius=65, maxRadius=85, acc_thresh=15,
                                          canny_upper_thresh=30, dilate_iterations=6, erode_iterations=4,
                                     gaussian_kernel_size=9)
    result = None
    if field is not None:
        result = tictactoeTactic.nextMove(field, signOwn='X', signOpponent='O', signEmpty='-', difficulty='i')
        print(result)
        movementControl.clickTicTacToe(robotIP, PORT, result)
    else:
        print("field none!")

    while True:
        time.sleep(6.0)
        circleTurn = not circleTurn
        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_tictactoe_state(img,debug=[], minRadius=65, maxRadius=85, acc_thresh=15,
                                          canny_upper_thresh=30, dilate_iterations=6, erode_iterations=4,
                                     gaussian_kernel_size=9)  # field = [['O', 'O', 'X'], ['X', 'X', '-'], ['-', 'X', 'O']]

        if circleTurn and field is not None:
            result = tictactoeTactic.nextMove(field, signOwn='O', signOpponent='X', signEmpty='-', difficulty='i')
        elif field is not None:
            result = tictactoeTactic.nextMove(field, signOwn='X', signOpponent='O', signEmpty='-', difficulty='h')
        else:
            break
        print(field)
        movementControl.clickTicTacToe(robotIP, PORT, result)


if __name__ == "__main__":
    # after startup of nao
    #movementControl.disableAutonomousLife(robotIP, PORT)
    #movementControl.stand(robotIP, PORT)

    # tablet positioning
    # use app Bubble Level (or similar to calibrate z-Angle)
    # movementControl.tabletPreparationXAngle(robotIP, PORT)
    # movementControl.tabletPosition(robotIP, PORT) # y-Angle

    # start positions
    # movementControl.startPositionL(robotIP, PORT)
    # movementControl.startPositionR(robotIP, PORT)
    #img = vision.get_image_from_nao(ip=robotIP, port=PORT)
    #img = cv2.imread("test.png")
    #field = vision.detect_tictactoe_state(img, debug=[1,2,3], minRadius=65, maxRadius=85, acc_thresh=15,
         #                                 canny_upper_thresh=30, dilate_iterations=6, erode_iterations=4,
          #                           gaussian_kernel_size=9)

    # repeating this:

    play_against_itself(robotIP, PORT)
    #vision.record_image_from_nao("test.png", robotIP, PORT)
    # difficulty = e -> easy ,m -> medium,h -> hard,i -> impossible
    # result = tictactoeTactic.nextMove(field, signOwn='X', signOpponent='O', signEmpty='-', difficulty='i')
    # print(result)

    # todo implement if won celebration else disappointment

    # closeHand(robotIP, PORT, arm="L")
