# coding=utf-8
import time

import cv2
from naoqi import ALProxy

from vision import vision
from tictactoe_tactic import tictactoeTactic
from movement import movementControl
import random

# IP address of the NAO
robotIP = "10.30.4.13"

# Port number
PORT = 9559


def game_done():
    i = random.randint(0, 1)
    if i == 0:
        return True
    else:
        return False


def play_against_itself(robotIP, PORT):
    circleTurn = True
    img = vision.get_image_from_nao(ip=robotIP, port=PORT)
    field = vision.detect_tictactoe_state(img, debug=[], minRadius=65, maxRadius=85, acc_thresh=15,
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
        field = vision.detect_tictactoe_state(img, debug=[], minRadius=65, maxRadius=85, acc_thresh=15,
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


def play_against_opponent(robotIP, PORT):
    field_after_move = []
    own_turn = True
    while True:

        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_tictactoe_state(img, minRadius=65, maxRadius=85, acc_thresh=15,
                                              canny_upper_thresh=30, dilate_iterations=6, erode_iterations=4,
                                              gaussian_kernel_size=9)

        field_none_counter = 0
        while field is None:    # while field is None mit counter bis 3
            field_none_counter += 1
            time.sleep(0.5)
            img = vision.get_image_from_nao(ip=robotIP, port=PORT)
            field = vision.detect_tictactoe_state(img, minRadius=65, maxRadius=85, acc_thresh=15,
                                                  canny_upper_thresh=30, dilate_iterations=6, erode_iterations=4,
                                                  gaussian_kernel_size=9)
            if field is None and field_none_counter > 5:
                print("Game over")
                # todo implement if won celebration else disappointment
                break
        if field == field_after_move:
            time.sleep(1)
            continue

        print(field)

        # difficulty = 'e' -> easy ,'m' -> medium,'h' -> hard,'i' -> impossible
        result = tictactoeTactic.nextMove(field, signOwn='O', signOpponent='X', signEmpty='-', difficulty='m')
        # result = tictactoeTactic.nextMove(field, signOwn='X', signOpponent='O', signEmpty='-', difficulty='i')
        field_after_move = field
        print(result)

        if result == 0:
            field_after_move[0][0] = 'O'
        elif result == 1:
            field_after_move[0][1] = 'O'
        elif result == 2:
            field_after_move[0][2] = 'O'
        elif result == 3:
            field_after_move[1][0] = 'O'
        elif result == 4:
            field_after_move[1][1] = 'O'
        elif result == 5:
            field_after_move[1][2] = 'O'
        elif result == 6:
            field_after_move[2][0] = 'O'
        elif result == 7:
            field_after_move[2][1] = 'O'
        else:
            field_after_move[2][2] = 'O'

        movementControl.clickTicTacToe(robotIP, PORT, result)

    # img = vision.get_image_from_nao(ip=robotIP, port=PORT)
    # field = vision.detect_tictactoe_state(img, minRadius=65, maxRadius=85, acc_thresh=15,
    #                                      canny_upper_thresh=30, dilate_iterations=6, erode_iterations=4,
    #                                     gaussian_kernel_size=9)


if __name__ == "__main__":
    # after startup of nao
    #movementControl.disableAutonomousLife(robotIP, PORT)
    #movementControl.stand(robotIP, PORT)

    # tablet positioning
    # use app Bubble Level (or similar to calibrate z-Angle)
    # movementControl.tabletPreparationXAngle(robotIP, PORT)
    # movementControl.tabletPosition(robotIP, PORT) # y-Angle with camera parallel

    # start positions
    # movementControl.startPosition(robotIP, PORT)

    #play_against_opponent(robotIP, PORT)

    tts = ALProxy("ALTextToSpeech", robotIP, PORT)
    asr = ALProxy("ALSpeechRecognition", robotIP, PORT)

    asr.setLanguage("German")

    # Example: Adds "yes", "no" and "please" to the vocabulary (without wordspotting)
    vocabulary = ["Ja", "Okay"]
    asr.setVocabulary(vocabulary, False)

    # Start the speech recognition engine with user Test_ASR
    asr.subscribe("Test_ASR")
    print 'Speech recognition engine started'
    tts.say("Möchten Sie Tic-Tac-Toe gegen mich spielen?")

    time.sleep(5)
    if asr.callback("Test_ASR", "Ja", ):
        tts.say("Juhu lass uns spielen")
    else:
        tts.say("Okay dann ein andernmal")
    asr.unsubscribe("Test_ASR")


