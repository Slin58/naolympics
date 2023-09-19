# if 3 own in a row or diagonal -> set 4th
# if 3 opponent in a row or diagonal -> set own on 4th
import time

import connect_four_tactic

# if 2 own in a row or diagonal -> set 3rd
# if 2 opponent in a row -> set own to block

# if none of this happens play: https://www.4-gewinnt.de/sehr_schwer.html#getyourown

field = [['-', '-', '-', '-', '-', '-', '-'],
         ['-', '-', '-', '-', '-', '-', '-'],
         ['-', '-', '-', '-', '-', '-', '-'],
         ['-', '-', '-', '-', '-', '-', '-'],
         ['-', '-', '-', '-', '-', '-', '-'],
         ['-', '-', '-', '-', '-', '-', '-']]


def set_point_x(i, j):
    if i < 5 and field[i + 1][j] == '-':
        set_point_x(i + 1, j)
    else:
        field[i][j] = 'x'


def set_point_o(i, j):
    if i < 5 and field[i + 1][j] == '-':
        set_point_o(i + 1, j)
    else:
        field[i][j] = 'o'


def print_game_state():
    for i in range(0, len(field[0])):
        print(i),
    print("")
    for i in range(0, len(field)):
        for j in range(0, len(field[i])):
            print(field[i][j]),
        print("")
    for i in range(0, len(field[0])):
        print(i),
    print("")


if __name__ == "__main__":
    print_game_state()

    while True:

        y = input("Reihe: ")
        while field[0][y] != '-':
            y = input("Reihe: ")

        # y, winning_move = connect_four_tactic.next_move(field, 'x', 'o', '-', difficulty='e')

        set_point_x(-1, y)
        print_game_state()

        # time.sleep(2)

        # y = input("Reihe: ")
        # while field[0][y] != '-':
        #     y = input("Reihe: ")

        y, winning_move = connect_four_tactic.next_move(field, 'o', 'x', '-', difficulty=4)

        set_point_o(-1, y)
        print_game_state()
