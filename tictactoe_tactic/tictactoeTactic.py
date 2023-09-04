# coding=utf-8
import random


# restructure idea: do methods do best move, do good move, do okay move, do bad move
# -> than for every amountOfEmptyFields it is decided depending on how difficult the game should be which move is done

# difficulties: 'i' -> impossible, 'h' -> hard, 'm' -> medium, 'e' -> easy
def nextMove(field, signOwn, signOpponent, signEmpty, difficulty):
    amountEmpty = 0
    for i in range(0, len(field)):
        for j in range(0, len(field[i])):
            if field[i][j] == signEmpty:
                amountEmpty += 1

    if amountEmpty == 9:
        if difficulty == 'i':
            print("play in random corner")
            return getRandomEmptyCorner(field, signEmpty), False
        elif difficulty == 'h':
            print("play middle")
            return 4, False
        elif difficulty == 'm' or difficulty == 'e':
            print("play in random edge")
            return getRandomEmptyEdge(field, signEmpty), False

    if amountEmpty == 8:
        if difficulty == 'e' or difficulty == 'm':
            return getRandomEmptyEdge(field, signEmpty), False

        # if placed in a corner: Play middle
        if field[0][0] == signOpponent or field[0][2] == signOpponent or field[2][0] == signOpponent or field[2][2] == signOpponent:
            if difficulty == 'h':
                print("play random corner")
                return getRandomEmptyCorner(field, signEmpty), False
            if difficulty == 'i':
                print("play middle")
                return 4, False

        return getRandomEmptyCorner(field, signEmpty), False

    if amountEmpty == 0:
        print("error: No empty field left")
        return None

    amountsOwn = amounts(field, signOwn)
    amountsOpponent = amounts(field, signOpponent)

    if amountEmpty == 7:
        if difficulty == 'e':
            return getRandomEmptyEdge(field, signEmpty), False
        if difficulty == 'm':
            for i in range(0, len(amountsOwn)):
                if amountsOwn[i] == 1 and amountsOpponent[i] == 0:
                    print("set mark next to other mark")
                    return getEmptyPlacesIn(field, i, signEmpty)[random.randint(0, 1)], False

        # if placed in a corner + middle: Play opposing corner
        if field[1][1] != signEmpty:
            if field[0][0] != signEmpty:
                print("play in the opposing corner")
                return 8, False
            if field[0][2] != signEmpty:
                print("play in the opposing corner")
                return 6, False
            if field[2][0] != signEmpty:
                print("play in the opposing corner")
                return 2, False
            if field[2][2] != signEmpty:
                print("play in the opposing corner")
                return 0, False

        # if Ecke + gegenüberliegende Ecke -> Dann eine der übrigen Ecken   entspricht 1Diagonale hat sign bei beidem
        for i in range(6, 8):
            if amountsOwn[i] == 1 and amountsOpponent[i] == 1:
                print("play in random empty corner")
                return getRandomEmptyCorner(field, signEmpty), False

        # if Ecke + andereEcke -> gegenüberliegende Ecke                    entspricht Row/Column hat sign bei beidem
        if (field[0][0] != signEmpty or field[2][2] != signEmpty) and (
                field[0][2] != signEmpty or field[2][0] != signEmpty):
            print("play in the opposing corner")
            if field[0][0] != signEmpty:
                return 8, False
            if field[0][2] != signEmpty:
                return 6, False
            if field[2][0] != signEmpty:
                return 2, False
            if field[2][2] != signEmpty:
                return 0, False

        # if Ecke + anliegende Kante -> Mitte/Nicht gegenüberliegende Ecke  entspricht Row/Column hat sign bei beidem
        for i in range(0, 6):
            if amountsOwn[i] == 1 and amountsOpponent[i] == 1:
                if field[1][1] == signEmpty:
                    print("play middle")
                    return 4, False
                else:
                    for j in range(0, len(amountsOwn)):
                        if amountsOwn[j] == 1 and amountsOpponent[j] == 0:
                            print("set mark next to other mark")
                            return getEmptyPlacesIn(field, j, signEmpty)[random.randint(0, 1)], False

        # if Ecke + nichtanliegende Kante -> gegenüberliegende Ecke         entspricht nirgends hat sign bei beidem
        if field[0][0] != signEmpty:
            print("play in the opposing corner")
            return 8, False
        if field[0][2] != signEmpty:
            print("play in the opposing corner")
            return 6, False
        if field[2][0] != signEmpty:
            print("play in the opposing corner")
            return 2, False
        if field[2][2] != signEmpty:
            print("play in the opposing corner")
            return 0, False

        print("Random Empty Corner")
        return getRandomEmptyCorner(field, signEmpty), False

    # check rows
    # check if wining move possible
    for i in range(0, len(amountsOwn)):
        if amountsOwn[i] == 2 and amountsOpponent[i] == 0:
            print("winning move")
            return getEmptyPlacesIn(field, i, signEmpty)[0], True

    # check if you have to defend
    if difficulty == 'i' or difficulty == 'h' or difficulty == 'm':
        for i in range(0, len(amountsOwn)):
            if amountsOpponent[i] == 2 and amountsOwn[i] == 0:
                print("defend")
                return getEmptyPlacesIn(field, i, signEmpty)[0], False

    # set mark where ever you can generate two pairs of two (Zwickmuehle) |
    # see rows with columns, rows with diagonals, columns with diagonals
    if difficulty == 'i' or difficulty == 'h':
        for i in range(0, 3):
            for j in range(3, 6):
                for k in range(6, 8):
                    if amountsOwn[i] == 1 and amountsOpponent[i] == 0 and amountsOwn[j] == 1 and \
                            amountsOpponent[j] == 0:
                        for place1 in getEmptyPlacesIn(field, i, signEmpty):
                            for place2 in getEmptyPlacesIn(field, j, signEmpty):
                                if place1 == place2:
                                    print("Zwickmühle")
                                    return place1, False
                    if amountsOwn[i] == 1 and amountsOpponent[i] == 0 and amountsOwn[k] == 1 and \
                            amountsOpponent[k] == 0:
                        for place1 in getEmptyPlacesIn(field, i, signEmpty):
                            for place2 in getEmptyPlacesIn(field, k, signEmpty):
                                if place1 == place2:
                                    print("Zwickmühle")
                                    return place1, False
                    if amountsOwn[j] == 1 and amountsOpponent[j] == 0 and amountsOwn[k] == 1 and \
                            amountsOpponent[k] == 0:
                        for place1 in getEmptyPlacesIn(field, j, signEmpty):
                            for place2 in getEmptyPlacesIn(field, k, signEmpty):
                                if place1 == place2:
                                    print("Zwickmühle")
                                    return place1, False

    # set mark where you can generate one pair of two
    for i in range(0, len(amountsOwn)):
        if amountsOwn[i] == 1 and amountsOpponent[i] == 0:
            print("set mark next to other mark")
            return getEmptyPlacesIn(field, i, signEmpty)[random.randint(0, 1)], False

    # set mark randomly
    print("mark was set randomly")
    return getRandomEmptyPlace(field, signEmpty), False


def amounts(field, sign):
    result = [0] * 8
    result[0] = amountRow(field, 0, sign)  # sign1FirstRow
    result[1] = amountRow(field, 1, sign)  # sign1SecondRow
    result[2] = amountRow(field, 2, sign)  # sign1ThirdRow
    result[3] = amountColumn(field, 0, sign)  # sign1FirstColumn
    result[4] = amountColumn(field, 1, sign)  # sign1SecondColumn
    result[5] = amountColumn(field, 2, sign)  # sign1ThirdColumn
    result[6] = amountDiagonal1(field, sign)  # sign1FirstDiagonal
    result[7] = amountDiagonal2(field, sign)  # sign1SecondDiagonal
    return result


def amountRow(field, row, sign):
    amount = 0
    for i in range(0, len(field[row])):
        if field[row][i] == sign:
            amount += 1

    return amount


def amountColumn(field, column, sign):
    amount = 0
    for i in range(0, len(field[column])):
        if field[i][column] == sign:
            amount += 1

    return amount


def amountDiagonal1(field, sign):
    amount = 0
    if field[0][0] == sign:
        amount += 1
    if field[1][1] == sign:
        amount += 1
    if field[2][2] == sign:
        amount += 1

    return amount


def amountDiagonal2(field, sign):
    amount = 0
    if field[0][2] == sign:
        amount += 1
    if field[1][1] == sign:
        amount += 1
    if field[2][0] == sign:
        amount += 1

    return amount


def getRandomEmptyEdge(field, signEmpty):
    rand = random.choice([1, 3, 5, 7])
    i = 0
    j = 0

    if rand == 1:
        i = 0
        j = 1
    if rand == 3:
        i = 1
        j = 0
    if rand == 5:
        i = 1
        j = 2
    if rand == 7:
        i = 2
        j = 1

    if field[i][j] == signEmpty:
        return rand

    return getRandomEmptyEdge(field, signEmpty)


def getRandomEmptyCorner(field, signEmpty):
    rand = random.choice([0, 2, 6, 8, 4])  # left_upper, right_upper, left_down, right_down, middle
    i = 0
    j = 0

    if rand == 0:
        i = 0
        j = 0
    if rand == 2:
        i = 0
        j = 2
    if rand == 4:
        i = 1
        j = 1
    if rand == 6:
        i = 2
        j = 0
    if rand == 8:
        i = 2
        j = 2

    if field[i][j] == signEmpty:
        return rand

    return getRandomEmptyCorner(field, signEmpty)


def getRandomEmptyPlace(field, signEmpty):
    i = random.randint(0, 2)
    j = random.randint(0, 2)

    if field[i][j] == signEmpty:
        result = getNumberFromCoord(i, j)
        return result

    return getRandomEmptyPlace(field, signEmpty)  # randomPlaceWasntEmpty


def getEmptyPlacesIn(field, i, signEmpty):
    result = list()
    if i in (0, 1, 2):
        for j in range(0, 3):
            if field[i][j] == signEmpty:
                result.append(getNumberFromCoord(i, j))

    if i in (3, 4, 5):
        for j in range(0, 3):
            if field[j][i - 3] == signEmpty:
                result.append(getNumberFromCoord(j, i - 3))
    if i == 6:
        if field[0][0] == signEmpty:
            result.append(getNumberFromCoord(0, 0))
        if field[1][1] == signEmpty:
            result.append(getNumberFromCoord(1, 1))
        if field[2][2] == signEmpty:
            result.append(getNumberFromCoord(2, 2))
    if i == 7:
        if field[0][2] == signEmpty:
            result.append(getNumberFromCoord(0, 2))
        if field[1][1] == signEmpty:
            result.append(getNumberFromCoord(1, 1))
        if field[2][0] == signEmpty:
            result.append(getNumberFromCoord(2, 0))

    return result


def getNumberFromCoord(i, j):
    if i == 0:
        return 0 + j
    if i == 1:
        return 3 + j
    if i == 2:
        return 6 + j
    print("error: no fitting field found")
    return None


def get_field_after_move(field, result, ownSign):
    field_after_move = field
    if result == 0:
        field_after_move[0][0] = ownSign
    elif result == 1:
        field_after_move[0][1] = ownSign
    elif result == 2:
        field_after_move[0][2] = ownSign
    elif result == 3:
        field_after_move[1][0] = ownSign
    elif result == 4:
        field_after_move[1][1] = ownSign
    elif result == 5:
        field_after_move[1][2] = ownSign
    elif result == 6:
        field_after_move[2][0] = ownSign
    elif result == 7:
        field_after_move[2][1] = ownSign
    else:
        field_after_move[2][2] = ownSign
    return field_after_move

# benötigter Input:
# drei freiwählbare Zeichen benötigt: 1 für noch nicht belegtes Feld, 1 für eigenes Zeichen und 1 für Zeichen des Gegners
# field = [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']] -> aktuelles Feld mit jeweils gesetzten Zeichen (hier '_' als nicht belegtes Feld)
# Schwierigkeitsgrad ist auch wählbar: 'i' -> impossible, 'h' -> hard, 'm' -> medium, 'e' -> easy

# Output:
# Place -> enthält Nummerierung des Felds startet links oben bei 0 und zählt noch links nach rechts Zeilenweise bis nach rechts unten 8
