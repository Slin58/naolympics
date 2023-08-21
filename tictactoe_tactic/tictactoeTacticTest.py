# coding=utf-8
import tictactoeTactic


def setPointo(field, place):
    counter = 0
    for i in range(0, len(field)):
        for j in range(0, len(field)):
            if counter == place:
                field[i][j] = 'o'
            counter += 1

    return field


def setPointo2(field, i, j):
    field[i][j] = 'o'
    return field


def setPointx(field, place):
    counter = 0
    for i in range(0, len(field)):
        for j in range(0, len(field)):
            if counter == place:
                field[i][j] = 'o'
            counter += 1

    return field


def setPointx2(field, i, j):
    field[i][j] = 'x'
    return field


def ausgabe(field):
    for i in range(0, len(field)):
        for j in range(0, len(field)):
            print (field[i][j]),
        print ("\n")


def playerStarts():
    field = [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']]
    ausgabe(field)

    while True:

        x = input("FeldX: ")
        y = input("FeldY: ")
        while field[x][y] != '_':
            x = input("FeldX: ")
            y = input("FeldY: ")
        field = setPointx2(field, x, y)

        ausgabe(field)

        result = tictactoeTactic.nextMove(field, signOwn='o', signOpponent='x', signEmpty='_', difficulty='i')
        print(result)
        field = setPointo(field, result)
        ausgabe(field)


def robotStarts():
    field = [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']]
    ausgabe(field)

    while True:
        result = tictactoeTactic.nextMove(field, signOwn='o', signOpponent='x', signEmpty='_', difficulty='i')
        print(result)
        field = setPointo(field, result)
        ausgabe(field)

        x = input("FeldX: ")
        y = input("FeldY: ")
        while field[x][y] != '_':
            x = input("FeldX: ")
            y = input("FeldY: ")
        field = setPointx2(field, x, y)

        ausgabe(field)


if __name__ == "__main__":
    # playerStarts()
    robotStarts()

# benötigter Input:
# drei freiwählbare Zeichen benötigt: 1 für noch nicht belegtes Feld, 1 für eigenes Zeichen und 1 für Zeichen des Gegners
# field = [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']] -> aktuelles Feld mit jeweils gesetzten Zeichen (hier '_' als nicht belegtes Feld)
# Schwierigkeitsgrad ist auch wählbar: 'i' -> impossible, 'h' -> hard, 'm' -> medium, 'e' -> easy

# Output:
# Place -> enthält Nummerierung des Felds startet links oben bei 0 und zählt noch links nach rechts Zeilenweise bis nach rechts unten 8
