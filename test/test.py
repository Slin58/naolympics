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


def choose_game_by_voice():    #returns "tictactoe" or "4 gewinnt" depending on what you say -> after 20 seconds without recognized word returns None
    asr = ALProxy("ALSpeechRecognition", robotIP, PORT)
    memory = ALProxy("ALMemory", robotIP, PORT)
    tts = ALProxy("ALTextToSpeech", robotIP, PORT)
    def on_word_recognized(value):
        print(value)
        recognized_word = value[0]
        print("Recognized:", recognized_word)

        if recognized_word == "Hello":
            tts.say("Hello!")


    asr.setLanguage("German")

    vocabulary = ["tictactoe", "Tictactoe", "Gewinnt", "gewinnt", "vier", "Vier"]
    asr.setVocabulary(vocabulary, True)
    asr.setParameter("Sensitivity", 0.3)

    asr.subscribe("MySpeechRecognition")
    memory.subscribeToEvent("WordRecognized", "MySpeechRecognition", "on_word_recognized")

    empty_data = ['', 0]
    memory.insertData("WordRecognized", empty_data)

    # asr.callback("WordRecognized", "Hello", std::string subscriberIdentifier)
    data = memory.getData("WordRecognized")

    print ("Speech recognition engine started")
    tts.say("Was möchtest du spielen?")

    counter = 0
    while True:
        if 'Tictactoe' in data[0] or 'tictactoe' in data[0]:
            tts.say("Okay lass uns Tictactoe spielen!")
            memory.unsubscribeToEvent("WordRecognized", "MySpeechRecognition")
            asr.unsubscribe("MySpeechRecognition")
            return "tictactoe"
        elif 'gewinnt' in data[0] or 'vier' in data[0] and 'Gewinnt' in data[0] and 'Vier' in data[0]:
            tts.say("Okay lass uns 4 gewinnt spielen!")
            memory.unsubscribeToEvent("WordRecognized", "MySpeechRecognition")
            asr.unsubscribe("MySpeechRecognition")
            return "4 gewinnt"
        elif counter > 20:
            tts.say("Ich hab dich leider nicht verstanden")
            memory.unsubscribeToEvent("WordRecognized", "MySpeechRecognition")
            asr.unsubscribe("MySpeechRecognition")
            return None
        counter += 1
        time.sleep(1)

        data = memory.getData("WordRecognized")


def choose_game_by_buttons():
    print("not implemented")    # todo
    return None


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
        time.sleep(1.0)
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


def play_tictactoe_against_opponent(robotIP, PORT, signOwn, signOpponent, signEmpty, difficulty):
    field_after_move = []
    while True:

        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_tictactoe_state(img, minRadius=65, maxRadius=85, acc_thresh=15,
                                              canny_upper_thresh=25, dilate_iterations=8, erode_iterations=4,
                                              gaussian_kernel_size=9)
        time.sleep(0.5)
        field_none_counter = 0
        while field is None:
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

        result = tictactoeTactic.nextMove(field, signOwn, signOpponent, signEmpty, difficulty)
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


def play_connect_four_against_opponent(robotIP, PORT, signOwn, signOpponent, signEmpty, mistake_factor):
    field_after_move = []
    while True:

        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_connect_four_state(img, debug=[1,2,3], minRadius=40, maxRadius=55,acc_thresh=20,circle_distance=120, canny_upper_thresh=30, dilate_iterations=4, erode_iterations=1, gaussian_kernel_size=13, white_thresh=210)

        field_none_counter = 0
        while field is None:
            field_none_counter += 1
            time.sleep(0.5)
            img = vision.get_image_from_nao(ip=robotIP, port=PORT)
            field = vision.detect_connect_four_state(img, minRadius=40, maxRadius=55,acc_thresh=20,circle_distance=120, canny_upper_thresh=30, dilate_iterations=4, erode_iterations=1, gaussian_kernel_size=13, white_thresh=210)
            if field is None and field_none_counter > 5:
                print("Game over")
                # todo implement if won celebration else disappointment
                break
        if field == field_after_move:
            time.sleep(1)
            continue

        print(field)
        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_connect_four_state(img, minRadius=40, maxRadius=55, acc_thresh=20, circle_distance=120,
                                                 canny_upper_thresh=30, dilate_iterations=4, erode_iterations=1,
                                                 gaussian_kernel_size=13, white_thresh=210)

        result = connect_four_tactic.nextMove(field, signOwn, signOpponent, signEmpty, mistake_factor)
        field_after_move = field
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

    # play_tictactoe_against_opponent(robotIP, PORT, signOwn='O', signOpponent='X', signEmpty='-', difficulty='m')    # difficulty = 'e' -> easy ,'m' -> medium,'h' -> hard,'i' -> impossible

    # play_connect_four_against_opponent(robotIP, PORT, signOwn='Y', signOpponent='R', signEmpty='-', mistake_factor=0)   # higher mistake factor equals lower difficulty

    play_against_itself(robotIP, PORT)
