import random


def nextMove(field, signOwn, signOpponent, signEmpty, mistake_factor):
    priority = [0, 0, 0, 0, 0, 0, 0]
    for row in range(0, 7):
        priority[row] = get_priorities(field, row, signOwn, signOpponent, signEmpty, 0.1, mistake_factor)

    maxPriority = -10000
    bestRow = 3
    for row in range(0, 7):
        if priority[row] > maxPriority:
            maxPriority = priority[row]
            bestRow = row
        elif priority[row] == maxPriority:
            r = random.randint(0, 1)
            if r == 0:
                bestRow = row
    if priority[bestRow] >= 3000:
        print("------------")
        print("winning move")
        print("------------")
        return bestRow, True
    elif priority[bestRow] >= 2000:
        print("defend")
        return bestRow, False
    print("result:", bestRow, priority[bestRow])
    return bestRow, False


def get_priorities(field, j, signOwn, signOpponent, signEmpty, factorForOtherPriorities, mistake_factor):
    i = get_position(field, -1, j, signEmpty)

    if i <= -1:
        print "-9999 no field left"
        return -9999

    prioritiesRow = get_priority(field, i, j, 0, 1, signOwn, signOpponent, signEmpty, mistake_factor)
    prioritiesColumn = get_priority(field, i, j, 1, 0, signOwn, signOpponent, signEmpty, mistake_factor)
    prioritiesDiagonal1 = get_priority(field, i, j, 1, 1, signOwn, signOpponent, signEmpty, mistake_factor)
    prioritiesDiagonal2 = get_priority(field, i, j, 1, -1, signOwn, signOpponent, signEmpty, mistake_factor)
    prioritiesRow_above_opponent = [0, 0]
    prioritiesColumn_above_opponent = [0, 0]
    prioritiesDiagonal1_above_opponent = [0, 0]
    prioritiesDiagonal2_above_opponent = [0, 0]

    if i-1 >= 0:
        prioritiesRow_above_opponent = get_priority(field, i-1, j, 0, 1, signOpponent, signOwn, signEmpty, mistake_factor)
        prioritiesColumn_above_opponent = get_priority(field, i-1, j, 1, 0, signOpponent, signOwn, signEmpty, mistake_factor)
        prioritiesDiagonal1_above_opponent = get_priority(field, i-1, j, 1, 1, signOpponent, signOwn, signEmpty, mistake_factor)
        prioritiesDiagonal2_above_opponent = get_priority(field, i-1, j, 1, -1, signOpponent, signOwn, signEmpty, mistake_factor)

    priority_above_opponent = max(prioritiesRow_above_opponent[0], prioritiesRow_above_opponent[1],
                                  prioritiesColumn_above_opponent[0], prioritiesColumn_above_opponent[1],
                                  prioritiesDiagonal1_above_opponent[0], prioritiesDiagonal1_above_opponent[1],
                                  prioritiesDiagonal2_above_opponent[0], prioritiesDiagonal2_above_opponent[1])
    print(prioritiesRow, prioritiesColumn, prioritiesDiagonal1, prioritiesDiagonal2),
    print(max(prioritiesRow[0], prioritiesRow[1], prioritiesColumn[0], prioritiesColumn[1], prioritiesDiagonal1[0], prioritiesDiagonal1[1], prioritiesDiagonal2[0], prioritiesDiagonal2[1])),
    max_of_offense = max(prioritiesRow[0], prioritiesColumn[0], prioritiesDiagonal1[0], prioritiesDiagonal2[0])
    max_of_defense = max(prioritiesRow[1], prioritiesColumn[1], prioritiesDiagonal1[1], prioritiesDiagonal2[1])
    if max_of_offense == 3000:
        print("winning"),
        print(3000)
        return max_of_offense

    elif max_of_offense > max_of_defense:
        print("offense"),
        print(max(prioritiesRow[0], prioritiesColumn[0], prioritiesDiagonal1[0], prioritiesDiagonal2[0]) \
            + (factorForOtherPriorities * (prioritiesRow[0] + prioritiesColumn[0] + prioritiesDiagonal1[0] + prioritiesDiagonal2[0])) \
            - (0.5 * priority_above_opponent))
        return max(prioritiesRow[0], prioritiesColumn[0], prioritiesDiagonal1[0], prioritiesDiagonal2[0]) \
            + (factorForOtherPriorities * (prioritiesRow[0] + prioritiesColumn[0] + prioritiesDiagonal1[0] + prioritiesDiagonal2[0])) \
            - (0.5 * priority_above_opponent)

    else:
        print("defense"),
        print(max(prioritiesRow[1], prioritiesColumn[1], prioritiesDiagonal1[1], prioritiesDiagonal2[1]) \
            + (factorForOtherPriorities * (prioritiesRow[1] + prioritiesColumn[1] + prioritiesDiagonal1[1] + prioritiesDiagonal2[1])) \
            - (0.5 * priority_above_opponent))
        return max(prioritiesRow[1], prioritiesColumn[1], prioritiesDiagonal1[1], prioritiesDiagonal2[1]) \
            + (factorForOtherPriorities * (prioritiesRow[1] + prioritiesColumn[1] + prioritiesDiagonal1[1] + prioritiesDiagonal2[1])) \
            - (0.5 * priority_above_opponent)


def get_priority(field, i, j, up, right, signOwn, signOpponent, signEmpty, mistake_factor):
    priorityWin = 0
    priorityDefend = 0
    restAvailable1 = True
    restAvailable2 = True
    winningMoveDir1 = True
    winningMoveDir2 = True
    defendNecessaryDir1 = True
    defendNecessaryDir2 = True
    winningMove = 0
    defendMove = 0

    # direction1
    if 0 <= i - up <= 5 and 0 <= j - right <= 6:
        if field[i - up][j - right] == signOwn:
            priorityWin = priorityWin + 12
            winningMove += 1

            defendNecessaryDir1 = False
        elif field[i - up][j - right] == signOpponent:
            priorityWin = priorityWin - 12
            winningMoveDir1 = False
            restAvailable1 = False

            priorityDefend = priorityDefend + 12
            defendMove += 1
        elif field[i - up][j - right] == signEmpty:
            priorityWin = priorityWin + 1
            winningMoveDir1 = False

    if 0 <= i - (up+up) <= 5 and 0 <= j - (right+right) <= 6:
        if field[i - (up+up)][j - (right+right)] == signOwn:
            if restAvailable1:
                priorityWin = priorityWin + 9
                if winningMoveDir1:
                    winningMove += 1

            defendNecessaryDir1 = False

        elif field[i - (up+up)][j - (right+right)] == signOpponent:
            priorityWin = priorityWin - 11
            winningMoveDir1 = False
            restAvailable1 = False

            if defendNecessaryDir1:
                priorityDefend = priorityDefend + 9
                defendMove += 1

        elif field[i - (up+up)][j - (right+right)] == signEmpty and restAvailable1:
            priorityWin = priorityWin + 1
            winningMoveDir1 = False

    if 0 <= i - (up+up+up) <= 5 and 0 <= j - (right+right+right) <= 6:
        if field[i - (up+up+up)][j - (right+right+right)] == signOwn and restAvailable1:
            priorityWin = priorityWin + 6
            if winningMoveDir1:
                winningMove += 1

        elif field[i - (up+up+up)][j - (right+right+right)] == signOpponent:
            priorityWin = priorityWin - 10

            if defendNecessaryDir1:
                priorityDefend = priorityDefend + 6
                defendMove += 1

        elif field[i - (up+up+up)][j - (right+right+right)] == signEmpty and restAvailable1:
            priorityWin = priorityWin + 1


    # direction2
    if 0 <= i + up <= 5 and 0 <= j + right <= 6:
        if field[i + up][j + right] == signOwn:
            priorityWin = priorityWin + 12
            winningMove += 1

            defendNecessaryDir2 = False

        elif field[i + up][j + right] == signOpponent:
            priorityWin = priorityWin - 12
            winningMoveDir2 = False
            restAvailable2 = False

            priorityDefend = priorityDefend + 12
            defendMove += 1

        elif field[i + up][j + right] == signEmpty:
            priorityWin = priorityWin + 1
            winningMoveDir2 = False

    if 0 <= i + (up+up) <= 5 and 0 <= j + (right+right) <= 6:
        if field[i + (up+up)][j + (right+right)] == signOwn:
            if restAvailable2:
                priorityWin = priorityWin + 9
                if winningMoveDir2:
                    winningMove += 1

            defendNecessaryDir2 = False

        elif field[i + (up+up)][j + (right+right)] == signOpponent:
            priorityWin = priorityWin - 11
            winningMoveDir2 = False
            restAvailable2 = False

            if defendNecessaryDir2:
                priorityDefend = priorityDefend + 9
                defendMove += 1

        elif field[i + (up+up)][j + (right+right)] == signEmpty and restAvailable2:
            priorityWin = priorityWin + 1
            winningMoveDir2 = False

    if 0 <= i + (up+up+up) <= 5 and 0 <= j + (right+right+right) <= 6:
        if field[i + (up+up+up)][j + (right+right+right)] == signOwn and restAvailable2:
            priorityWin = priorityWin + 6
            if winningMoveDir2:
                winningMove += 1

        elif field[i + (up+up+up)][j + (right+right+right)] == signOpponent:
            priorityWin = priorityWin - 10
            if defendNecessaryDir2:
                priorityDefend = priorityDefend + 6
                defendMove += 1

        elif field[i + (up+up+up)][j + (right+right+right)] == signEmpty and restAvailable2:
            priorityWin = priorityWin + 1

    priorityWin = priorityWin + random.randint(0, mistake_factor)
    priorityDefend = priorityDefend + random.randint(0, mistake_factor)
    if winningMove >= 3:
        return [3000, priorityDefend]
    if defendMove >= 3:
        return [priorityWin, 2000]

    return [priorityWin, priorityDefend]


def setPointY(field, i, j):
    if i < 5 and field[i + 1][j] == '-':
        return setPointY(field, i + 1, j)
    else:
        field[i][j] = 'Y'
        return field


def setPointR(field, i, j):
    if i < 5 and field[i + 1][j] == '-':
        return setPointR(field, i + 1, j)
    else:
        field[i][j] = 'R'
        return field


def get_position(field, i, j, signEmpty):
    if i < 5 and field[i + 1][j] == signEmpty:
        return get_position(field, i + 1, j, signEmpty)
    else:
        return i
