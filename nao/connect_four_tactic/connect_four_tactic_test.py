import time
import connect_four_tactic

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
    print
    for i in range(0, len(field)):
        for j in range(0, len(field[i])):
            print(field[i][j]),
        print
    for i in range(0, len(field[0])):
        print(i),
    print


def player_starts():
    print_game_state()

    while True:

        y = input("Reihe: ")
        while field[0][y] != '-':
            y = input("Reihe: ")

        set_point_x(-1, y)
        print_game_state()

        y, winning_move = connect_four_tactic.next_move(field, 'o', 'x', '-', difficulty=4)

        set_point_o(-1, y)
        print_game_state()


def robot_starts():
    print_game_state()

    while True:

        y, winning_move = connect_four_tactic.next_move(field, 'x', 'o', '-', difficulty=4)

        set_point_x(-1, y)
        print_game_state()

        y = input("Reihe: ")
        while field[0][y] != '-':
            y = input("Reihe: ")

        set_point_o(-1, y)
        print_game_state()


def robot_vs_robot():
    print_game_state()

    while True:
        y, winning_move = connect_four_tactic.next_move(field, 'x', 'o', '-', difficulty=4)

        set_point_x(-1, y)
        print_game_state()

        time.sleep(2)

        y, winning_move = connect_four_tactic.next_move(field, 'o', 'x', '-', difficulty=4)

        set_point_o(-1, y)
        print_game_state()


if __name__ == "__main__":
    # player_starts()
    # robot_starts()
    robot_vs_robot()
