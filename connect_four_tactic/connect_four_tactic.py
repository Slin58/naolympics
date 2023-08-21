import random


def nextMove(field, signOwn, signOpponent, signEmpty, mistake_factor):
    priority = [0, 0, 0, 0, 0, 0, 0]
    for row in range(0, 7):
        priority[row] = get_priorities(field, row, signOwn, signOpponent, signEmpty, 0.15, mistake_factor)

    maxPriority = -99
    bestRow = 3
    for row in range(0, 7):
        if priority[row] > maxPriority:
            maxPriority = priority[row]
            bestRow = row
    print("result:", bestRow, priority[bestRow])
    return bestRow


def get_priorities(field, j, signOwn, signOpponent, signEmpty, factorForOtherPriorities, mistake_factor):
    i = get_position(field, 0, j)

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
    otherPriorities = prioritiesRow[0] + prioritiesRow[1] + prioritiesColumn[0] + prioritiesColumn[1] + prioritiesDiagonal1[0] + prioritiesDiagonal1[1] + prioritiesDiagonal2[0] + prioritiesDiagonal2[1]
    # the main priority is the one which is most import for example already 3 in a row. The others are taken in with the factorForOtherPriorities
    max_of_offense = max(prioritiesRow[0], prioritiesColumn[0], prioritiesDiagonal1[0], prioritiesDiagonal2[0])
    max_of_defense = max(prioritiesRow[1], prioritiesColumn[1], prioritiesDiagonal1[1], prioritiesDiagonal2[1])
    if max_of_offense > max_of_defense:
        print("offense")
    else:
        print("defense")
    return max(prioritiesRow[0], prioritiesRow[1], prioritiesColumn[0], prioritiesColumn[1], prioritiesDiagonal1[0], prioritiesDiagonal1[1], prioritiesDiagonal2[0], prioritiesDiagonal2[1]) + factorForOtherPriorities * otherPriorities - 0.5 * priority_above_opponent


def get_priority(field, i, j, up, right, signOwn, signOpponent, signEmpty, mistake_factor):
    priorityWin = 0
    priorityDefend = 0
    restAvailable1 = True
    restAvailable2 = True
    winningMoveDir1 = True
    winningMoveDir2 = True
    winningMove = 0
    # todo factor fuer andere Felder anpassen bzw. Berechnung noch anpassen siehe beispiel unten

    # direction1
    if 0 <= i - up <= 5 and 0 <= j - right <= 6:
        if field[i - up][j - right] == signOwn:
            priorityWin = priorityWin + 12
            winningMove += 1
        elif field[i - up][j - right] == signOpponent:
            priorityWin = priorityWin - 8
            priorityDefend = priorityDefend + 10
            restAvailable1 = False
            winningMoveDir1 = False
        elif field[i - up][j - right] == signEmpty:
            priorityWin = priorityWin + 2
            winningMoveDir1 = False

    if 0 <= i - (up+up) <= 5 and 0 <= j - (right+right) <= 6:
        if field[i - (up+up)][j - (right+right)] == signOwn and restAvailable1:
            priorityWin = priorityWin + 9
            if winningMoveDir1:
                winningMove += 1
        elif field[i - (up+up)][j - (right+right)] == signOpponent:
            priorityWin = priorityWin - 6
            priorityDefend = priorityDefend + 10
            restAvailable1 = False
            winningMoveDir1 = False
        elif field[i - (up+up)][j - (right+right)] == signEmpty and restAvailable1:
            priorityWin = priorityWin + 2
            winningMoveDir1 = False

    if 0 <= i - (up+up+up) <= 5 and 0 <= j - (right+right+right) <= 6:
        if field[i - (up+up+up)][j - (right+right+right)] == signOwn and restAvailable1:
            priorityWin = priorityWin + 6
            if winningMoveDir1:
                winningMove += 1
        elif field[i - (up+up+up)][j - (right+right+right)] == signOpponent:
            priorityWin = priorityWin - 4
            priorityDefend = priorityDefend + 10
            winningMoveDir2 = False
        elif field[i - (up+up+up)][j - (right+right+right)] == signEmpty and restAvailable1:
            priorityWin = priorityWin + 2
            winningMoveDir2 = False

    # direction2
    if 0 <= i + up <= 5 and 0 <= j + right <= 6:
        if field[i + up][j + right] == signOwn:
            priorityWin = priorityWin + 12
            if winningMoveDir2:
                winningMove += 1
        elif field[i + up][j + right] == signOpponent:
            priorityWin = priorityWin - 20
            priorityDefend = priorityDefend + 10
            restAvailable2 = False
            winningMoveDir2 = False
        elif field[i + up][j + right] == signEmpty:
            priorityWin = priorityWin + 2
            winningMoveDir2 = False

    if 0 <= i + (up+up) <= 5 and 0 <= j + (right+right) <= 6:
        if field[i + (up+up)][j + (right+right)] == signOwn and restAvailable2:
            priorityWin = priorityWin + 11
            if winningMoveDir2:
                winningMove += 1
        elif field[i + (up+up)][j + (right+right)] == signOpponent:
            priorityWin = priorityWin - 10
            priorityDefend = priorityDefend + 9
            restAvailable2 = False
            winningMoveDir2 = False
        elif field[i + (up+up)][j + (right+right)] == signEmpty and restAvailable2:
            priorityWin = priorityWin + 2
            winningMoveDir2 = False

    if 0 <= i + (up+up+up) <= 5 and 0 <= j + (right+right+right) <= 6:
        if field[i + (up+up+up)][j + (right+right+right)] == signOwn and restAvailable2:
            priorityWin = priorityWin + 10
            if winningMoveDir2:
                winningMove += 1
        elif field[i + (up+up+up)][j + (right+right+right)] == signOpponent:
            priorityWin = priorityWin - 5
            priorityDefend = priorityDefend + 8
        elif field[i + (up+up+up)][j + (right+right+right)] == signEmpty and restAvailable2:
            priorityWin = priorityWin + 2

    priorityWin = priorityWin + random.randint(0, mistake_factor)
    priorityDefend = priorityDefend + random.randint(0, mistake_factor)
    if winningMove >= 3:
        return [priorityWin+30, priorityDefend]

    return [priorityWin, priorityDefend]


def get_position(field, i, j):
    if i < 5 and field[i + 1][j] == '_':
        return get_position(field, i + 1, j)
    else:
        return i
