# coding=utf-8
import time

import cv2
from naoqi import ALProxy
import movement.movementControl
from vision import vision
from tictactoe_tactic import tictactoeTactic
from connect_four_tactic import connect_four_tactic
from movement import movementControl
import random

# IP address of the NAO
robotIP = "10.30.4.13"

# Port number
PORT = 9559


def choose_game_by_voice():  # returns "tictactoe" or "4 gewinnt" depending on what you say -> after 20 seconds without recognized word returns None
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


def get_random_nao_name():
    names = ["Julius","Dieter", "Norbert", "Hugo", "Antonia", "Emil", "Martha", "Theodor", "Rosina", "Franz", "Adelheid", "Egon", "Elsa", "Hermann", "Cäcilie", "Oskar", "Karoline", "Rudolph", "Theresa", "Ferdinand", "Henriette", "Konrad", "Albertine", "Ludovica", "Leopold", "Henrietta", "Rosa", "Amalie", "Eduard", "Sophia", "Eberhard", "Johanna", "Kuno", "Veronika", "Clemens", "Eleonora", "Wilhelmina", "Eugenie", "Valentin", "Regina","Emma", "Fritz", "Johann", "Sophie", "Wilhelm", "Ida", "Heinrich", "Agnes", "Ludwig", "Elisabeth", "Friederike", "Paul", "Barbara", "Max", "Clara", "Gustav", "Katharina", "Otto", "Louise", "Eduard", "Anna", "Rudolf", "Gertrud", "Georg", "Maria", "Friedrich", "Mathilde", "Hans", "Margarethe", "Albert", "Augusta", "Richard", "Helena", "Walter", "Charlotte"]
    return names[random.randint(0, len(names) - 1)]

def get_difficulty_text(difficulty):
    if difficulty == 1:
        return "Schwierigkeitsstufe leicht"
    elif difficulty == 2:
        return "Schwierigkeitsstufe mittel"
    elif difficulty == 3:
        return "Schwierigkeitsstufe schwer"
    elif difficulty == 4:
        return "Schwierigkeitsstufe unmöglich. Ich werde dich vernichten"


def get_difficulty(difficulty, is_tictactoe):
    if is_tictactoe:
        if difficulty == 1:
            return "e"
        elif difficulty == 2:
            return "m"
        elif difficulty == 3:
            return "h"
        elif difficulty == 4:
            return "i"
    else:
        if difficulty == 1:
            return 10
        elif difficulty == 2:
            return 5
        elif difficulty == 3:
            return 2
        elif difficulty == 4:
            return 0


def choose_game_by_buttons():
    try:
        movementControl.startPosition(robotIP, PORT)
        touch = ALProxy("ALTouch", robotIP, PORT)
        tts = ALProxy("ALTextToSpeech", robotIP, PORT)
        tts.say("Hallo, ich bin"+ get_random_nao_name() + ". Was möchtest du spielen? Für TicTacTo, berühre den Knopf an meiner Stirn! Für "
                "Vier gewinnt, berühre den Knopf an meinem Hinterkopf! Zum Beenden, berühre den Knopf in der Mitte")
        vs_options_text = "Berühre den Knopf an meiner Stirn, dass ich gegen dich starte. " \
                     "Berühre den Knopf an meinem Hinterkopf, dass du gegen mich startest. Berühre den Knopf in " \
                     "der Mitte, dass ich gegen mich selbst spiele!"
        difficulty_setting_text = "Wähle die Schwierigkeitsstufe, indem nur mit den äußeren " \
                                  "Knöpfen wählst und mit der Mitte bestätigst! Gerade bin ich auf leicht eingestellt!"
        tictactoe_mode = False
        connect4_mode = False
        nao_begins = False
        difficulty = 0

        while True:
            status = touch.getStatus()
            counter = 0
            for e in status:
                if e[1]:
                    print "No.", counter, e
                    if counter == 7 and not tictactoe_mode and not connect4_mode and not difficulty:
                        tictactoe_mode = True
                        tts.say("Alles klar, TicTacTo. "+vs_options_text)
                        break

                    if counter == 8 and tictactoe_mode and not difficulty:
                        tts.say("Alles klar, ich spiele gegen mich selbst. Viel Spaß beim zuschauen!")
                        play_tictactoe_against_itself(robotIP, PORT)
                        connect4_mode, difficulty, nao_begins, tictactoe_mode = reset_button_mode_menu(connect4_mode,
                                                                                                       difficulty,
                                                                                                       nao_begins,
                                                                                                       tictactoe_mode, tts)
                        break

                    if counter == 7 and tictactoe_mode and not difficulty:
                        difficulty = 1
                        nao_begins = True

                        tts.say("Alles klar, ich beginne. "+difficulty_setting_text)
                        break

                    if counter == 9 and tictactoe_mode and not difficulty:
                        difficulty = 1
                        tts.say(
                            "Alles klar, du beginnst. "+difficulty_setting_text)
                        break

                    if counter == 7 and difficulty:
                        difficulty += 1
                        if difficulty == 5:
                            difficulty = 1
                        difficulty_text = get_difficulty_text(difficulty)
                        tts.say(difficulty_text)
                        break

                    if counter == 9 and difficulty:
                        difficulty -= 1
                        if difficulty == 0:
                            difficulty = 4
                        difficulty_text = get_difficulty_text(difficulty)
                        tts.say(difficulty_text)
                        break

                    if counter == 8 and difficulty:
                        if tictactoe_mode:
                            tts.say("Okay, ich spiele gegen dich TicTacTo mit" + get_difficulty_text(
                                difficulty) + ". Gutes Spiel!")
                            if nao_begins:
                                play_tictactoe_against_opponent_player1(robotIP, PORT, get_difficulty(difficulty, is_tictactoe=True))
                            else:
                                play_tictactoe_against_opponent_player2(robotIP, PORT, get_difficulty(difficulty, is_tictactoe=True))
                        elif connect4_mode:
                            tts.say("Okay, ich spiele gegen dich Vier gewinnt mit" + get_difficulty_text(
                                difficulty) + ". Gutes Spiel!")
                            if nao_begins:
                                play_connect_four_against_opponent_player1(robotIP, PORT, get_difficulty(difficulty, is_tictactoe=False))
                            else:
                                play_connect_four_against_opponent_player2(robotIP, PORT, get_difficulty(difficulty, is_tictactoe=False))
                        connect4_mode, difficulty, nao_begins, tictactoe_mode = reset_button_mode_menu(connect4_mode,
                                                                                                       difficulty,
                                                                                                       nao_begins,
                                                                                                       tictactoe_mode, tts)
                        break

                    if counter == 8 and not connect4_mode and not tictactoe_mode and not difficulty:
                        tts.say("Bis zum nächsten mal!")
                        return

                    if counter == 9 and not connect4_mode and not tictactoe_mode and not difficulty:
                        connect4_mode = True

                        tts.say("Alles klar, Vier gewinnt. "+vs_options_text)
                        break

                    if counter == 8 and connect4_mode and not difficulty:
                        tts.say("Alles klar, ich spiele gegen mich selbst. Viel Spaß beim zuschauen!")
                        play_connect_four_against_itself(robotIP, PORT)
                        connect4_mode, difficulty, nao_begins, tictactoe_mode = reset_button_mode_menu(connect4_mode,
                                                                                                       difficulty,
                                                                                                       nao_begins,
                                                                                                       tictactoe_mode, tts)
                        break

                    if counter == 7 and connect4_mode and not difficulty:
                        difficulty = 1
                        nao_begins = True
                        tts.say(
                            "Alles klar, ich beginne. "+difficulty_setting_text)
                        break

                    if counter == 9 and connect4_mode and not difficulty:
                        difficulty = 1
                        tts.say(
                            "Alles klar, du beginnst. "+difficulty_setting_text)
                        break

                counter += 1

            print "----"
            time.sleep(0.2)
    except RuntimeError:
        tts = ALProxy("ALTextToSpeech", robotIP, PORT)
        tts.say("Tut mir leid, etwas ist schief gelaufen. Starten wir von vorne!")
        choose_game_by_buttons()


def reset_button_mode_menu(connect4_mode, difficulty, nao_begins, tictactoe_mode, tts):
    movementControl.startPosition(robotIP, PORT)
    tts.say("Das hat Spaß gemacht! Wenn du nochmal spielen möchtest, wähle erneut Stirn für TicTacTo "
            "und Hinterkopf für Vier gewinnt. Zum Beenden, berühre den Knopf in der Mitte")
    tictactoe_mode = False
    connect4_mode = False
    nao_begins = False
    difficulty = 0
    return connect4_mode, difficulty, nao_begins, tictactoe_mode


def play_tictactoe_against_itself(robotIP, PORT):
    circle_turn = True
    while True:
        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_tictactoe_state(img, debug=[], minRadius=75, maxRadius=85, acc_thresh=15,
                                              canny_upper_thresh=25, dilate_iterations=8, erode_iterations=4,
                                              gaussian_kernel_size=9)  # field = [['O', 'O', 'X'], ['X', 'X', '-'], ['-', 'X', 'O']]
        field_none_counter = 0
        while field is None:
            field_none_counter += 1
            time.sleep(0.2)
            img = vision.get_image_from_nao(ip=robotIP, port=PORT)
            field = vision.detect_tictactoe_state(img, minRadius=75, maxRadius=85, acc_thresh=15,
                                                  canny_upper_thresh=25, dilate_iterations=8, erode_iterations=4,
                                                  gaussian_kernel_size=9)
            if field is None and field_none_counter > 5:
                print("Game over")
                return
        if circle_turn:
            result, winning = tictactoeTactic.nextMove(field, signOwn='O', signOpponent='X', signEmpty='-',
                                                       difficulty='i')
        else:
            result, winning = tictactoeTactic.nextMove(field, signOwn='X', signOpponent='O', signEmpty='-',
                                                       difficulty='h')
        circle_turn = not circle_turn
        print(field)
        movementControl.clickTicTacToe(robotIP, PORT, result)
        if winning:
            if random.randint(0, 1):
                movement.movementControl.celebrate1(robotIP, PORT)
            else:
                movement.movementControl.celebrate2(robotIP, PORT)
            return


def play_connect_four_against_itself(robotIP, PORT):
    yellow_turn = True
    while True:
        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_connect_four_state(img, debug=[6], minRadius=55, maxRadius=65, acc_thresh=10,
                                                 circle_distance=120, canny_upper_thresh=30, dilate_iterations=4,
                                                 erode_iterations=1, gaussian_kernel_size=13)
        field_none_counter = 0
        while field is None:
            field_none_counter += 1
            time.sleep(0.2)
            img = vision.get_image_from_nao(ip=robotIP, port=PORT)
            field = vision.detect_connect_four_state(img, debug=[6], minRadius=55, maxRadius=65, acc_thresh=10,
                                                     circle_distance=120, canny_upper_thresh=30, dilate_iterations=4,
                                                     erode_iterations=1, gaussian_kernel_size=13)
            if field is None and field_none_counter > 5:
                print("Game over")
                return
        if yellow_turn:
            result, winning = connect_four_tactic.nextMove(field, signOwn='Y', signOpponent='R', signEmpty='-',
                                                           mistake_factor=0)
        else:
            result, winning = connect_four_tactic.nextMove(field, signOwn='R', signOpponent='Y', signEmpty='-',
                                                           mistake_factor=0)
        yellow_turn = not yellow_turn

        movementControl.clickConnectFour(robotIP, PORT, result)
        if winning:
            if random.randint(0, 1):
                movement.movementControl.celebrate1(robotIP, PORT)
            else:
                movement.movementControl.celebrate2(robotIP, PORT)
            return


def play_tictactoe_against_opponent_player1(robotIP, PORT, difficulty="m"):
    field_after_move = []
    while True:

        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_tictactoe_state(img, minRadius=65, maxRadius=85, acc_thresh=15,
                                              canny_upper_thresh=25, dilate_iterations=8, erode_iterations=4,
                                              gaussian_kernel_size=9)
        field_none_counter = 0
        while field is None:
            field_none_counter += 1
            time.sleep(0.2)
            img = vision.get_image_from_nao(ip=robotIP, port=PORT)
            field = vision.detect_tictactoe_state(img, minRadius=65, maxRadius=85, acc_thresh=15,
                                                  canny_upper_thresh=25, dilate_iterations=8, erode_iterations=4,
                                                  gaussian_kernel_size=9)
            if field is None and field_none_counter > 5:
                print("Game over")
                return
        if field == field_after_move:
            time.sleep(0.2)
            continue

        # difficulty = 'e' -> easy ,'m' -> medium,'h' -> hard,'i' -> impossible
        result, winning = tictactoeTactic.nextMove(field, signOwn='O', signOpponent='X', signEmpty='-',
                                                   difficulty=difficulty)
        print(result)

        field_after_move = tictactoeTactic.get_field_after_move(field, result, 'O')

        movementControl.clickTicTacToe(robotIP, PORT, result)
        if winning:
            if random.randint(0, 1):
                movement.movementControl.celebrate1(robotIP, PORT)
            else:
                movement.movementControl.celebrate2(robotIP, PORT)
            return


def play_tictactoe_against_opponent_player2(robotIP, PORT, difficulty="m"):
    field_after_move = \
        [['-', '-', '-'],
         ['-', '-', '-'],
         ['-', '-', '-']]
    while True:

        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_tictactoe_state(img, minRadius=65, maxRadius=85, acc_thresh=15,
                                              canny_upper_thresh=25, dilate_iterations=8, erode_iterations=4,
                                              gaussian_kernel_size=9)
        field_none_counter = 0
        while field is None:
            field_none_counter += 1
            time.sleep(0.2)
            img = vision.get_image_from_nao(ip=robotIP, port=PORT)
            field = vision.detect_tictactoe_state(img, minRadius=65, maxRadius=85, acc_thresh=15,
                                                  canny_upper_thresh=25, dilate_iterations=8, erode_iterations=4,
                                                  gaussian_kernel_size=9)
            if field is None and field_none_counter > 5:
                print("Game over")
                return

        if field == field_after_move:
            time.sleep(0.2)
            continue

        # difficulty = 'e' -> easy ,'m' -> medium,'h' -> hard,'i' -> impossible
        result, winning = tictactoeTactic.nextMove(field, signOwn='X', signOpponent='O', signEmpty='-',
                                                   difficulty=difficulty)
        print(result)

        field_after_move = tictactoeTactic.get_field_after_move(field, result, 'X')
        movementControl.clickTicTacToe(robotIP, PORT, result)
        if winning:
            if random.randint(0, 1):
                movement.movementControl.celebrate1(robotIP, PORT)
            else:
                movement.movementControl.celebrate2(robotIP, PORT)
            return


def play_connect_four_against_opponent_player1(robotIP, PORT, mistake_factor=0):
    field_after_move = []
    while True:
        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_connect_four_state(img, debug=[6], minRadius=55, maxRadius=65, acc_thresh=10,
                                                 circle_distance=120, canny_upper_thresh=30, dilate_iterations=4,
                                                 erode_iterations=1, gaussian_kernel_size=13)
        field_none_counter = 0
        while field is None:  # while field is None mit counter bis 3
            field_none_counter += 1
            time.sleep(0.2)
            img = vision.get_image_from_nao(ip=robotIP, port=PORT)
            field = vision.detect_connect_four_state(img,debug=[6], minRadius=55, maxRadius=65, acc_thresh=10,
                                                     circle_distance=120, canny_upper_thresh=30, dilate_iterations=4,
                                                     erode_iterations=1, gaussian_kernel_size=13)
            if field is None and field_none_counter > 5:
                print("Game over")
                return
        if field == field_after_move:
            time.sleep(0.2)
            continue
        else:
            print("comparison not successful")
        # # difficulty = 'e' -> easy ,'m' -> medium,'h' -> hard,'i' -> impossible
        result, winning = connect_four_tactic.nextMove(field, signOwn='Y', signOpponent='R', signEmpty='-',
                                                       mistake_factor=mistake_factor)
        field_after_move = field
        field_after_move = connect_four_tactic.setPointY(field_after_move, -1, result)
        print(result)

        movementControl.clickConnectFour(robotIP, PORT, result)
        if winning:
            if random.randint(0, 1):
                movement.movementControl.celebrate1(robotIP, PORT)
            else:
                movement.movementControl.celebrate2(robotIP, PORT)
            return


def play_connect_four_against_opponent_player2(robotIP, PORT, mistake_factor=0):
    field_after_move = \
        [['-', '-', '-', '-', '-', '-', '-'],
         ['-', '-', '-', '-', '-', '-', '-'],
         ['-', '-', '-', '-', '-', '-', '-'],
         ['-', '-', '-', '-', '-', '-', '-'],
         ['-', '-', '-', '-', '-', '-', '-'],
         ['-', '-', '-', '-', '-', '-', '-']]
    while True:
        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_connect_four_state(img, debug=[6], minRadius=55, maxRadius=65, acc_thresh=10,
                                                 circle_distance=120, canny_upper_thresh=30, dilate_iterations=4,
                                                 erode_iterations=1, gaussian_kernel_size=13)
        field_none_counter = 0
        while field is None:  # while field is None mit counter bis 3
            field_none_counter += 1
            time.sleep(0.5)
            img = vision.get_image_from_nao(ip=robotIP, port=PORT)
            field = vision.detect_connect_four_state(img,debug=[6], minRadius=55, maxRadius=65, acc_thresh=10,
                                                     circle_distance=120, canny_upper_thresh=30, dilate_iterations=4,
                                                     erode_iterations=1, gaussian_kernel_size=13)
            if field is None and field_none_counter > 5:
                print("Game over")
                return
        if field == field_after_move:
            time.sleep(0.2)
            continue
        else:
            print("comparison not successful")

        # # difficulty = 'e' -> easy ,'m' -> medium,'h' -> hard,'i' -> impossible
        result, winning = connect_four_tactic.nextMove(field, signOwn='R', signOpponent='Y', signEmpty='-',
                                                       mistake_factor=mistake_factor)
        field_after_move = field
        field_after_move = connect_four_tactic.setPointR(field_after_move, -1, result)
        print(result)

        movementControl.clickConnectFour(robotIP, PORT, result)
        if winning:
            if random.randint(0, 1):
                movement.movementControl.celebrate1(robotIP, PORT)
            else:
                movement.movementControl.celebrate2(robotIP, PORT)
            return


def calibrate(modes=["disable_autonomous", "z_angle", "x_angle", "y_angle", "vision_check", "start_position"]):
    # disable autonomous mode
    if "disable_autonomous" in modes:
        print("Disabling autonomous life...")
        movementControl.disableAutonomousLife(robotIP, PORT)
        movementControl.stand(robotIP, PORT)
        raw_input("Press Enter to continue...")

    if "z_angle" in modes:
        print("use app Bubble Level (or similar) to calibrate z-Angle")
        raw_input("Press Enter to continue...")

    if "x_angle" in modes:
        print("Preparing for x-Angle calibration. Please watch NAOs movement to avoid damage to tablet and itself")
        movementControl.tabletPreparationXAngle(robotIP, PORT)
        raw_input("Press Enter to continue...")

    if "y_angle" in modes:
        print("Preparing for y-Angle calibration. Please watch NAOs movement to avoid damage to tablet and itself")
        movementControl.tabletPosition(robotIP, PORT)
        raw_input("Press Enter to continue...")

    if "vision_check" in modes:
        print("Recording image of NAOs current vision")
        vision.show_image_from_nao(robotIP, PORT)

    if "start_position" in modes:
        print("Getting ready to rumble")
        movementControl.startPosition(robotIP, PORT)
        raw_input("Press Enter to continue...")


if __name__ == "__main__":
    # after startup of nao
    # calibrate(["y_angle", "vision_check", "start_position"])
    choose_game_by_buttons()
    # field_after_move = \
    #     [['-', '-', '-', '-', 'R', 'Y', '-'],
    #      ['Y', 'R', '-', 'R', 'Y', 'R', 'R'],
    #      ['Y', 'R', 'Y', 'R', 'Y', 'Y', 'Y'],
    #      ['R', 'Y', 'Y', 'R', 'R', 'Y', 'Y'],
    #      ['Y', 'R', 'R', 'Y', 'R', 'Y', 'R'],
    #      ['Y', 'R', 'R', 'Y', 'Y', 'R', 'R']]
    # wrong_count = 0
    # fail = vision.get_image_from_nao(robotIP, PORT)
    # field = vision.detect_connect_four_state(fail, debug=[1,2,3,4,5,6,7], minRadius=55, maxRadius=65)
    # if field == field_after_move:
    #     print("huge success")
    # for i in range(100):
    #     fail = vision.get_image_from_nao(robotIP, PORT)
    #     field = vision.detect_connect_four_state(fail, debug=[])
    #     if field != field_after_move:
    #         print(i)
    #         for row in field:
    #             print(row)
    #         wrong_count += 1
    # print(wrong_count)
    # play_tictactoe_against_itself(robotIP, PORT)
    # play_tictactoe_against_opponent_player1(robotIP, PORT, difficulty='h')
    # play_tictactoe_against_opponent_player2(robotIP, PORT, difficulty='h')
    # play_connect_four_against_itself(robotIP, PORT)
    # play_connect_four_against_opponent_player1(robotIP, PORT, mistake_factor = 1)
    # play_connect_four_against_opponent_player2(robotIP, PORT, mistake_factor = 1)



    # false_count = 0
    # for i in range(1000):
    #     new_field = vision.detect_connect_four_state(fail)
    #     if new_field != field:
    #         false_count +=1
    # print(float(false_count)/1000)#
    # result: 0.0 ??