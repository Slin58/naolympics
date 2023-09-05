# coding=utf-8
import time

import tictactoe_tactic


def set_point_o(field, place):
    counter = 0
    for i in range(0, len(field)):
        for j in range(0, len(field)):
            if counter == place:
                field[i][j] = 'o'
            counter += 1

    return field


def set_point_o2(field, i, j):
    field[i][j] = 'o'
    return field


def set_point_x(field, place):
    counter = 0
    for i in range(0, len(field)):
        for j in range(0, len(field)):
            if counter == place:
                field[i][j] = 'o'
            counter += 1

    return field


def set_point_x2(field, i, j):
    field[i][j] = 'x'
    return field


def print_game_state(field):
    for i in range(0, len(field)):
        for j in range(0, len(field)):
            print (field[i][j]),
        print ("\n")


def player_starts():
    field = [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']]
    print_game_state(field)

    while True:

        x = input("FeldX: ")
        y = input("FeldY: ")
        while field[x][y] != '_':
            x = input("FeldX: ")
            y = input("FeldY: ")
        field = set_point_x2(field, x, y)

        print_game_state(field)

        result, winning_move = tictactoe_tactic.next_move(field, signOwn='o', signOpponent='x', signEmpty='_', difficulty='i')
        print(result)
        field = set_point_o(field, result)
        print_game_state(field)


def robot_starts():
    field = [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']]
    print_game_state(field)

    while True:
        result, winning_move = tictactoe_tactic.next_move(field, signOwn='o', signOpponent='x', signEmpty='_', difficulty='i')
        print(result)
        field = set_point_o(field, result)
        print_game_state(field)

        x = input("FeldX: ")
        y = input("FeldY: ")
        while field[x][y] != '_':
            x = input("FeldX: ")
            y = input("FeldY: ")
        field = set_point_x2(field, x, y)

        print_game_state(field)


if __name__ == "__main__":
    #playerStarts()
    robot_starts()

# benötigter Input:
# drei freiwählbare Zeichen benötigt: 1 für noch nicht belegtes Feld, 1 für eigenes Zeichen und 1 für Zeichen des Gegners
# field = [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']] -> aktuelles Feld mit jeweils gesetzten Zeichen (hier '_' als nicht belegtes Feld)
# Schwierigkeitsgrad ist auch wählbar: 'i' -> impossible, 'h' -> hard, 'm' -> medium, 'e' -> easy

# Output:
# Place -> enthält Nummerierung des Felds startet links oben bei 0 und zählt noch links nach rechts Zeilenweise bis nach rechts unten 8
