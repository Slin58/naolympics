# coding=utf-8
import time

import cv2
from naoqi import ALProxy

from vision import vision
from tictactoe_tactic import tictactoeTactic
from connect_four_tactic import connect_four_tactic
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


def play_tictactoe_against_opponent(robotIP, PORT, difficulty="m"):
    field_after_move = []
    own_turn = True
    while True:

        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_tictactoe_state(img, minRadius=65, maxRadius=85, acc_thresh=15,
                                              canny_upper_thresh=25, dilate_iterations=8, erode_iterations=4,
                                              gaussian_kernel_size=9)
        time.sleep(0.5)
        field_none_counter = 0
        while field is None:  # while field is None mit counter bis 3
            field_none_counter += 1
            time.sleep(0.5)
            img = vision.get_image_from_nao(ip=robotIP, port=PORT)
            field = vision.detect_tictactoe_state(img, minRadius=65, maxRadius=85, acc_thresh=15,
                                                  canny_upper_thresh=25, dilate_iterations=8, erode_iterations=4,
                                                  gaussian_kernel_size=9)
            if field is None and field_none_counter > 5:
                print("Game over")
                # todo implement if won celebration else disappointment
                return
        if field == field_after_move:
            time.sleep(0.5)
            continue

        print(field)

        # difficulty = 'e' -> easy ,'m' -> medium,'h' -> hard,'i' -> impossible
        result = tictactoeTactic.nextMove(field, signOwn='O', signOpponent='X', signEmpty='-', difficulty=difficulty)
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


def play_connect_four_against_opponent(robotIP, PORT):
    field_after_move = []
    while True:
        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_connect_four_state(img, debug=[], minRadius=40, maxRadius=55, acc_thresh=10,
                                                 circle_distance=120, canny_upper_thresh=30, dilate_iterations=4,
                                                 erode_iterations=1, gaussian_kernel_size=13)
        field_none_counter = 0
        while field is None:  # while field is None mit counter bis 3
            field_none_counter += 1
            time.sleep(0.5)
            img = vision.get_image_from_nao(ip=robotIP, port=PORT)
            field = vision.detect_connect_four_state(img, minRadius=40, maxRadius=55, acc_thresh=10,
                                                     circle_distance=120, canny_upper_thresh=30, dilate_iterations=4,
                                                     erode_iterations=1, gaussian_kernel_size=13)
            if field is None and field_none_counter > 5:
                print("Game over")
                # todo implement if won celebration else disappointment
                return
        if field == field_after_move:
            time.sleep(1)
            continue
        else:
            print("field", field)
            print("field_after_move", field_after_move)
            print("comparison not successful")

        print(field)
        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_connect_four_state(img, minRadius=40, maxRadius=55, acc_thresh=10, circle_distance=120,
                                                 canny_upper_thresh=30, dilate_iterations=4, erode_iterations=1,
                                                 gaussian_kernel_size=13)
        #
        # # difficulty = 'e' -> easy ,'m' -> medium,'h' -> hard,'i' -> impossible
        result = connect_four_tactic.nextMove(field, signOwn='Y', signOpponent='R', signEmpty='-', mistake_factor=0)
        field_after_move = field
        field_after_move = connect_four_tactic.setPointY(field_after_move, -1, result)
        print(result)

        movementControl.clickConnectFour(robotIP, PORT, result)

if __name__ == "__main__":
    # after startup of nao
    # movementControl.disableAutonomousLife(robotIP, PORT)
    # movementControl.stand(robotIP, PORT)

    # tablet positioning
    # use app Bubble Level (or similar to calibrate z-Angle)
    # movementControl.tabletPreparationXAngle(robotIP, PORT)
    # movementControl.tabletPosition(robotIP, PORT) # y-Angle with camera parallel

    # start positions
    # movementControl.startPosition(robotIP, PORT)
    # vision.record_image_from_nao("../230822_faulty_recognition_c4.png", robotIP, PORT)
    # play_tictactoe_against_opponent(robotIP, PORT, difficulty='h')
    play_connect_four_against_opponent(robotIP,   PORT)
    # img = vision.get_image_from_nao(ip=robotIP, port=PORT)
    # field = vision.detect_connect_four_state(img, debug=[], minRadius=30, maxRadius=55, acc_thresh=10,
    #                                          circle_distance=120, canny_upper_thresh=30, dilate_iterations=4,
    #                                          erode_iterations=1, gaussian_kernel_size=13, white_thresh=100)
    # print(field)
    # result = connect_four_tactic.nextMove(field, signOwn='Y', signOpponent='R', signEmpty='-', mistake_factor=0)
    # # result = tictactoeTactic.nextMove(field, signOwn='X', signOpponent='O', signEmpty='-', difficulty='i')
    # # field_after_move = field
    # print(result)
    #
    # movementControl.clickConnectFour(robotIP, PORT, result)
    # vision.detect_connect_four_state(img,

    # field = vision.detect_connect_four_state(img,debug=[1,2,3,4,5], minRadius=30, maxRadius=55,acc_thresh=10,circle_distance=120, canny_upper_thresh=30, dilate_iterations=4, erode_iterations=1, gaussian_kernel_size=13, white_thresh=100)
    # def on_word_recognized(value):
    #     recognized_word = value[0]
    #     print("Recognized:", recognized_word)
    #
    #     if recognized_word == "hallo":
    #         tts.say("Hello!")
    #
    #
    # tts = ALProxy("ALTextToSpeech", robotIP, PORT)
    # asr = ALProxy("ALSpeechRecognition", robotIP, PORT)
    # memory = ALProxy("ALMemory", robotIP, PORT)

    # memory.unsubscribeToEvent("WordRecognized", "on_word_recognized")
    # asr.unsubscribe("MySpeechRecognition")

    # asr.setLanguage("German")
    #
    # # Example: Adds "yes", "no" and "please" to the vocabulary (without wordspotting)
    # vocabulary = ["Ja", "hallo"]
    # asr.setVocabulary(vocabulary, False)
    #
    # # Start the speech recognition engine with user Test_ASR
    # memory.subscribeToEvent("WordRecognized", "MySpeechRecognition", "on_word_recognized")
    #
    # print 'Speech recognition engine started'

    # tts.say("Möchten Sie Tic-Tac-Toe gegen mich spielen?")
#
#     try:
#         while True:
#             pass
#     except KeyboardInterrupt:
#         # Clean up
#         asr.unsubscribe("MySpeechRecognition")
#         memory.unsubscribeToEvent("WordRecognized", "MySpeechRecognition")
#
#
# """    time.sleep(5)
#     if asr.callback("Test_ASR", "Ja", ):
#         tts.say("Juhu lass uns spielen")
#     else:
#         tts.say("Okay dann ein andernmal")
#     asr.unsubscribe("Test_ASR")"""
