# coding=utf-8
import time
import argparse
from naoqi import ALProxy
import movement.movementControl
from vision import vision
from tictactoe_tactic import tictactoe_tactic
from connect_four_tactic import connect_four_tactic
from movement import movementControl
import random

robotIP = "10.30.4.13"
PORT = 9559


def get_random_nao_name():
    names = ["Julius", "Dieter", "Norbert", "Hugo", "Antonia", "Emil", "Martha", "Theodor", "Rosina", "Franz",
             "Adelheid", "Egon", "Elsa", "Hermann", "Cäcilie", "Oskar", "Karoline", "Rudolph", "Theresa", "Ferdinand",
             "Henriette", "Konrad", "Albertine", "Ludovica", "Leopold", "Henrietta", "Rosa", "Amalie", "Eduard",
             "Sophia", "Eberhard", "Johanna", "Kuno", "Veronika", "Clemens", "Eleonora", "Wilhelmina", "Eugenie",
             "Valentin", "Regina", "Emma", "Fritz", "Johann", "Sophie", "Wilhelm", "Ida", "Heinrich", "Agnes", "Ludwig",
             "Elisabeth", "Friederike", "Paul", "Barbara", "Max", "Clara", "Gustav", "Katharina", "Otto", "Louise",
             "Eduard", "Anna", "Rudolf", "Gertrud", "Georg", "Maria", "Friedrich", "Mathilde", "Hans", "Margarethe",
             "Albert", "Augusta", "Richard", "Helena", "Walter", "Charlotte"]
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


def choose_game_by_voice(asr, memory, tts):
    def on_word_recognized(value):
        print(value)
        recognized_word = value[0]
        print("Recognized:", recognized_word)

        if recognized_word == "Hello":
            tts.say("Hello!")

    asr.setLanguage("German")

    vocabulary = ["tictactoe", "gewinnt", "vier", "ende"]
    asr.setVocabulary(vocabulary, True)
    asr.setParameter("Sensitivity", 0.4)

    asr.subscribe("MySpeechRecognition")
    memory.subscribeToEvent("WordRecognized", "MySpeechRecognition", "on_word_recognized")

    empty_data = ['', 0]
    memory.insertData("WordRecognized", empty_data)

    data = memory.getData("WordRecognized")

    print ("Speech recognition engine started")
    tts.say("Was möchtest du spielen? tictactoe, vier gewinnt oder ende.")

    counter = 0
    while True:
        if 'tictactoe' in data[0]:
            tts.say("Okay lass uns Tictactoe spielen!")
            game = True
            break
        elif 'gewinnt' in data[0] or 'vier' in data[0]:
            tts.say("Okay lass uns 4 gewinnt spielen!")
            game = False
            break
        elif 'ende' in data[0]:
            tts.say("Okay bis zum nächsten Mal!")
            game = None
            break
        counter += 1
        time.sleep(0.2)

    memory.unsubscribeToEvent("WordRecognized", "MySpeechRecognition")
    asr.unsubscribe("MySpeechRecognition")
    return game


def choose_start_player_by_voice(asr, memory, tts):
    def on_word_recognized(value):
        print(value)
        recognized_word = value[0]
        print("Recognized:", recognized_word)

        if recognized_word == "Hello":
            tts.say("Hello!")

    asr.setLanguage("German")

    vocabulary = ["Ich", "Du", "selbst"]
    asr.setVocabulary(vocabulary, True)
    asr.setParameter("Sensitivity", 0.4)

    asr.subscribe("MySpeechRecognition")
    memory.subscribeToEvent("WordRecognized", "MySpeechRecognition", "on_word_recognized")

    empty_data = ['', 0]
    memory.insertData("WordRecognized", empty_data)

    data = memory.getData("WordRecognized")

    print ("Speech recognition engine started")
    tts.say("Wer soll anfangen? Ich, Du oder gegen mich selbst")

    counter = 0
    while True:
        if 'Ich' in data[0]:
            tts.say("Okay, du beginnst.")
            player = 2
            break
        elif 'Du' in data[0]:
            tts.say("Okay, ich beginne.")
            player = 1
            break
        elif 'selbst' in data[0]:
            tts.say("Okay, ich spiele gegen mich selbst. Viel Spaß beim Zuschauen!")
            player = 0
            break
        counter += 1
        time.sleep(0.2)

    memory.unsubscribeToEvent("WordRecognized", "MySpeechRecognition")
    asr.unsubscribe("MySpeechRecognition")
    return player


def choose_difficulty_by_voice(asr, memory, tts):
    def on_word_recognized(value):
        print(value)
        recognized_word = value[0]
        print("Recognized:", recognized_word)

        if recognized_word == "Hello":
            tts.say("Hello!")

    asr.setLanguage("German")

    vocabulary = ["Leicht", "Mittel", "Schwer", "Unmöglich"]
    asr.setVocabulary(vocabulary, True)
    asr.setParameter("Sensitivity", 0.4)

    asr.subscribe("MySpeechRecognition")
    memory.subscribeToEvent("WordRecognized", "MySpeechRecognition", "on_word_recognized")

    empty_data = ['', 0]
    memory.insertData("WordRecognized", empty_data)

    data = memory.getData("WordRecognized")

    print ("Speech recognition engine started")
    tts.say("Welche Schwierigkeitsstufe? Leicht, Mittel, Schwer oder Unmöglich")

    counter = 0
    while True:
        if 'Leicht' in data[0]:
            difficulty = 1
            tts.say("Okay, " + get_difficulty_text(difficulty))
            break
        elif 'Mittel' in data[0]:
            difficulty = 2
            tts.say("Okay, " + get_difficulty_text(difficulty))
            break
        elif 'Schwer' in data[0]:
            difficulty = 3
            tts.say("Okay, " + get_difficulty_text(difficulty))
            break
        elif 'Unmöglich' in data[0]:
            difficulty = 4
            tts.say("Okay, " + get_difficulty_text(difficulty))
            break
        counter += 1
        time.sleep(0.2)

    memory.unsubscribeToEvent("WordRecognized", "MySpeechRecognition")
    asr.unsubscribe("MySpeechRecognition")
    return difficulty


def play_games_by_voice():  # not usable because the robot is moving as soon as it goes into the ALSpeechRecognition -> possible fix: Calibrate the robot again after SpeechRecognition, but not very usable
    try:
        movementControl.start_position(robotIP, PORT)
        asr = ALProxy("ALSpeechRecognition", robotIP, PORT)
        memory = ALProxy("ALMemory", robotIP, PORT)
        tts = ALProxy("ALTextToSpeech", robotIP, PORT)

        tts.say("Hallo, ich bin" + get_random_nao_name())
        while True:
            tictactoe_mode = choose_game_by_voice(asr, memory, tts)
            if tictactoe_mode:
                return

            player = choose_start_player_by_voice(asr, memory, tts)

            difficulty = 0
            if player != 0:
                difficulty = choose_difficulty_by_voice(asr, memory, tts)

            if tictactoe_mode:
                if player == 0:
                    play_tictactoe_against_itself(robotIP, PORT)
                else:
                    tts.say(
                        "Okay, ich spiele gegen dich TicTacTo mit" + get_difficulty_text(difficulty) + ". Gutes Spiel!")
                    play_tictactoe_against_opponent(robotIP, PORT, player, difficulty)
            else:
                if player == 0:
                    play_connect_four_against_itself(robotIP, PORT)
                else:
                    tts.say("Okay, ich spiele gegen dich Vier gewinnt mit" + get_difficulty_text(
                        difficulty) + ". Gutes Spiel!")
                    play_connect_four_against_opponent(robotIP, PORT, player, difficulty)

            tts.say(
                "Das hat Spaß gemacht! Zum Beenden, drücke Mitte. Wenn du nochmal spielen möchtest, wähle vorne Tictacto, hinten Vier gewinnt")

    except RuntimeError as e:
        print(e)
        tts = ALProxy("ALTextToSpeech", robotIP, PORT)
        tts.say("Tut mir leid, etwas ist schief gelaufen. Starten wir von vorne!")
        play_games_by_buttons()


def choose_game_by_buttons(touch, tts):
    tts.say("Vorne Tictacto, Hinten Vier gewinnt, Mitte Beenden")
    while True:
        status = touch.getStatus()

        if status[0][1]:
            print status[7], status[8], status[9]

            if status[7][1]:  # front -> tictactoe
                tts.say("Alles klar, TicTacTo.")
                return True
            if status[8][1]:  # middle -> end
                tts.say("Bis zum nächsten mal!")
                return None
            if status[9][1]:  # rear -> connectfour
                tts.say("Alles klar, Vier gewinnt.")
                return False
        time.sleep(0.2)


def choose_start_player_by_buttons(touch, tts):
    tts.say("Vorne: Ich starte. Hinten: Du startest. Mitte: Ich spiele gegen mich selbst")
    while True:
        status = touch.getStatus()

        if status[0][1]:
            print status[7], status[8], status[9]
            if status[7][1]:  # front -> is player1
                tts.say("Alles klar, ich beginne.")
                return 1
            if status[8][1]:  # middle -> play against itself
                tts.say("Alles klar, ich spiele gegen mich selbst. Viel Spaß beim Zuschauen!")
                return 0
            if status[9][1]:  # rear -> is player2
                tts.say("Alles klar, du beginnst.")
                return 2
        time.sleep(0.2)


def choose_difficulty_by_buttons(touch, tts):
    tts.say(
        "Wähle die Schwierigkeitsstufe. Navigiere mit vorne und hinten und bestätige mit Mitte! Gerade bin ich auf leicht eingestellt!")
    difficulty = 1

    while True:  # Auswahl Schwierigkeitsstufe
        status = touch.getStatus()

        if status[0][1]:
            print status[7], status[8], status[9]

            if status[7][1]:  # front -> higher difficulty
                if difficulty >= 4:
                    difficulty = 1
                else:
                    difficulty += 1
            if status[8][1]:  # middle -> end
                return difficulty
            if status[9][1]:  # rear -> lower difficulty
                if difficulty <= 1:
                    difficulty = 4
                else:
                    difficulty -= 1
            tts.say(get_difficulty_text(difficulty))
            time.sleep(0.2)


def play_games_by_buttons():
    try:
        movementControl.start_position(robotIP, PORT)
        touch = ALProxy("ALTouch", robotIP, PORT)
        tts = ALProxy("ALTextToSpeech", robotIP, PORT)

        tts.say(
            "Hallo, ich bin" + get_random_nao_name() + ". Was möchtest du spielen? Navigiere mit den Knöpfen auf meinem Kopf.")
        while True:
            tictactoe_mode = choose_game_by_buttons(touch, tts)
            if tictactoe_mode is None:
                return

            player = choose_start_player_by_buttons(touch, tts)

            difficulty = 0
            if player != 0:
                difficulty = choose_difficulty_by_buttons(touch, tts)

            if tictactoe_mode:
                if player == 0:
                    play_tictactoe_against_itself(robotIP, PORT)
                else:
                    tts.say(
                        "Okay, ich spiele gegen dich TicTacTo mit" + get_difficulty_text(difficulty) + ". Gutes Spiel!")
                    play_tictactoe_against_opponent(robotIP, PORT, player, difficulty)
            else:
                if player == 0:
                    play_connect_four_against_itself(robotIP, PORT)
                else:
                    tts.say("Okay, ich spiele gegen dich Vier gewinnt mit" + get_difficulty_text(
                        difficulty) + ". Gutes Spiel!")
                    play_connect_four_against_opponent(robotIP, PORT, player, difficulty)

            tts.say("Das hat Spaß gemacht! Möchtest du nochmal spielen?")

    except RuntimeError:
        tts = ALProxy("ALTextToSpeech", robotIP, PORT)
        tts.say("Tut mir leid, etwas ist schief gelaufen. Starten wir von vorne!")
        play_games_by_buttons()


def play_tictactoe_against_itself(robotIP, PORT):
    circle_turn = True
    while True:
        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_tictactoe_state(img, debug=[], minRadius=75, maxRadius=95, acc_thresh=15,
                                              canny_upper_thresh=25, dilate_iterations=8, erode_iterations=4,
                                              gaussian_kernel_size=9)
        field_none_counter = 0
        while field is None:
            field_none_counter += 1
            time.sleep(0.2)
            img = vision.get_image_from_nao(ip=robotIP, port=PORT)
            field = vision.detect_tictactoe_state(img, minRadius=75, maxRadius=95, acc_thresh=15,
                                                  canny_upper_thresh=25, dilate_iterations=8, erode_iterations=4,
                                                  gaussian_kernel_size=9)
            if field is None and field_none_counter > 5:
                print("Game over")
                return
        if circle_turn:
            result, winning = tictactoe_tactic.next_move(field, signOwn='O', signOpponent='X', signEmpty='-',
                                                         difficulty=4)
        else:
            result, winning = tictactoe_tactic.next_move(field, signOwn='X', signOpponent='O', signEmpty='-',
                                                         difficulty=3)
        circle_turn = not circle_turn
        print(field)
        movementControl.click_tic_tac_toe(robotIP, PORT, result)
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
            result, winning = connect_four_tactic.next_move(field, signOwn='Y', signOpponent='R', signEmpty='-',
                                                            difficulty=4)
        else:
            result, winning = connect_four_tactic.next_move(field, signOwn='R', signOpponent='Y', signEmpty='-',
                                                            difficulty=4)
        yellow_turn = not yellow_turn

        movementControl.click_connect_four(robotIP, PORT, result)
        if winning:
            if random.randint(0, 1):
                movement.movementControl.celebrate1(robotIP, PORT)
            else:
                movement.movementControl.celebrate2(robotIP, PORT)
            return


def play_tictactoe_against_opponent(robotIP, PORT, player=1, difficulty=2):
    if player == 1:
        field_after_move = []
        signOwn = 'O'
        signOpponent = 'X'
    else:
        field_after_move = \
            [['-', '-', '-'],
             ['-', '-', '-'],
             ['-', '-', '-']]
        signOwn = 'X'
        signOpponent = 'O'
    while True:

        img = vision.get_image_from_nao(ip=robotIP, port=PORT)
        field = vision.detect_tictactoe_state(img, minRadius=75, maxRadius=95, acc_thresh=15,
                                              canny_upper_thresh=25, dilate_iterations=8, erode_iterations=4,
                                              gaussian_kernel_size=9)
        field_none_counter = 0
        while field is None:
            field_none_counter += 1
            time.sleep(0.2)
            img = vision.get_image_from_nao(ip=robotIP, port=PORT)
            field = vision.detect_tictactoe_state(img, minRadius=75, maxRadius=95, acc_thresh=15,
                                                  canny_upper_thresh=25, dilate_iterations=8, erode_iterations=4,
                                                  gaussian_kernel_size=9)
            if field is None and field_none_counter > 5:
                print("Game over")
                return
        if field == field_after_move or field is None:
            time.sleep(0.2)
            continue

        # difficulty = 1 -> easy ,2 -> medium,3 -> hard,4 -> impossible
        result, winning = tictactoe_tactic.next_move(field, signOwn=signOwn, signOpponent=signOpponent, signEmpty='-',
                                                     difficulty=difficulty)
        print(result)

        field_after_move = tictactoe_tactic.get_field_after_move(field, result, signOwn)

        movementControl.click_tic_tac_toe(robotIP, PORT, result)
        if winning:
            if random.randint(0, 1):
                movement.movementControl.celebrate1(robotIP, PORT)
            else:
                movement.movementControl.celebrate2(robotIP, PORT)
            return


def play_connect_four_against_opponent(robotIP, PORT, player=1, difficulty=2):
    if player == 1:
        field_after_move = []
        signOwn = 'Y'
        signOpponent = 'R'
    else:
        field_after_move = \
            [['-', '-', '-', '-', '-', '-', '-'],
             ['-', '-', '-', '-', '-', '-', '-'],
             ['-', '-', '-', '-', '-', '-', '-'],
             ['-', '-', '-', '-', '-', '-', '-'],
             ['-', '-', '-', '-', '-', '-', '-'],
             ['-', '-', '-', '-', '-', '-', '-']]
        signOwn = 'R'
        signOpponent = 'Y'

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
            field = vision.detect_connect_four_state(img, debug=[6], minRadius=55, maxRadius=65, acc_thresh=10,
                                                     circle_distance=120, canny_upper_thresh=30, dilate_iterations=4,
                                                     erode_iterations=1, gaussian_kernel_size=13)
            if field is None and field_none_counter > 5:
                print("Game over")
                return
        if field == field_after_move or field is None:
            time.sleep(0.2)
            continue
        else:
            print("comparison not successful")
        # difficulty = 1 -> easy ,2 -> medium,3 -> hard,4 -> impossible
        result, winning = connect_four_tactic.next_move(field, signOwn=signOwn, signOpponent=signOpponent,
                                                        signEmpty='-',
                                                        difficulty=difficulty)
        field_after_move = field
        if player == 1:
            field_after_move = connect_four_tactic.set_point_y(field_after_move, -1, result)
        else:
            field_after_move = connect_four_tactic.set_point_r(field_after_move, -1, result)
        print(result)

        movementControl.click_connect_four(robotIP, PORT, result)
        if winning:
            if random.randint(0, 1):
                movement.movementControl.celebrate1(robotIP, PORT)
            else:
                movement.movementControl.celebrate2(robotIP, PORT)
            return


def calibrate(modes=None):
    if modes is None:
        modes = ["disable_autonomous", "z_angle", "x_angle", "y_angle", "vision_check", "start_position"]

    if "disable_autonomous" in modes:
        print("Disabling autonomous life...")
        movementControl.disable_autonomous_life(robotIP, PORT)
        movementControl.stand(robotIP, PORT)
        raw_input("Press Enter to continue...")

    if "stand" in modes:
        movementControl.stand(robotIP, PORT)
        raw_input("Press Enter to continue...")

    if "z_angle" in modes:
        print("use app Bubble Level (or similar) to calibrate z-Angle")
        raw_input("Press Enter to continue...")

    if "x_angle" in modes:
        print("Preparing for x-Angle calibration. Please watch NAOs movement to avoid damage to tablet and itself")
        movementControl.tablet_preparation_x_angle(robotIP, PORT)
        raw_input("Press Enter to continue...")

    if "y_angle" in modes:
        print("Preparing for y-Angle calibration. Please watch NAOs movement to avoid damage to tablet and itself")
        movementControl.tablet_position(robotIP, PORT)
        raw_input("Press Enter to continue...")

    if "vision_check" in modes:
        print("Recording image of NAOs current vision")
        vision.show_image_from_nao(robotIP, PORT)

    if "start_position" in modes:
        print("Getting ready to rumble")
        movementControl.start_position(robotIP, PORT)
        raw_input("Press Enter to continue...")


if __name__ == "__main__":

    argParser = argparse.ArgumentParser()
    argParser.add_argument("-i", "--ip", type=str, help="robot IP address")
    argParser.add_argument("-p", "--port", type=int, help="robot Port")
    args = argParser.parse_args()
    if args.ip:
        robotIP = args.ip
    if args.port:
        PORT = args.port

    # calibrate(["stand", "x_angle", "y_angle"])

    play_games_by_buttons()
