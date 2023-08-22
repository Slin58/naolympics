# if 3 own in a row or diagonal -> set 4th
# if 3 opponent in a row or diagonal -> set own on 4th
import connect_four_tactic

# if 2 own in a row or diagonal -> set 3rd
# if 2 opponent in a row -> set own to block

# if none of this happens play: https://www.4-gewinnt.de/sehr_schwer.html#getyourown

field = [['_', '_', '_', '_', '_', '_', '_'],
         ['_', '_', '_', '_', '_', '_', '_'],
         ['_', '_', '_', '_', '_', '_', '_'],
         ['_', '_', '_', '_', '_', '_', '_'],
         ['_', '_', '_', '_', '_', '_', '_'],
         ['_', '_', '_', '_', '_', '_', '_']]


def setPointx(i, j):
    if i < 5 and field[i + 1][j] == '_':
        setPointx(i + 1, j)
    else:
        field[i][j] = 'x'


def setPointo(i, j):
    if i < 5 and field[i + 1][j] == '_':
        setPointo(i + 1, j)
    else:
        field[i][j] = 'o'


def ausgabe():
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
    ausgabe()

    while True:
        y = connect_four_tactic.nextMove(field, 'x', 'o', '_', mistake_factor=0)
        setPointx(-1, y)

        ausgabe()

        y = input("Reihe: ")

        while field[0][y] != '_':
            y = input("Reihe: ")
        setPointo(-1, y)

        ausgabe()
