# coding=utf-8
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
                field[i][j] = 'x'
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

        result, winning_move = tictactoe_tactic.next_move(field, signOwn='o', signOpponent='x', signEmpty='_',
                                                          difficulty=4)
        print(result)
        field = set_point_o(field, result)
        print_game_state(field)


def robot_starts():
    field = [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']]
    print_game_state(field)

    while True:
        result, winning_move = tictactoe_tactic.next_move(field, signOwn='o', signOpponent='x', signEmpty='_',
                                                          difficulty=4)
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


def robot_vs_robot():
    field = [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']]
    print_game_state(field)

    while True:
        result, winning_move = tictactoe_tactic.next_move(field, signOwn='o', signOpponent='x', signEmpty='_',
                                                          difficulty=4)
        print(result)
        field = set_point_o(field, result)
        print_game_state(field)

        result, winning_move = tictactoe_tactic.next_move(field, signOwn='x', signOpponent='o', signEmpty='_',
                                                          difficulty=4)
        print(result)
        field = set_point_x(field, result)
        print_game_state(field)


if __name__ == "__main__":
    # playerStarts()
    # robot_starts()
    robot_vs_robot()
