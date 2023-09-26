import random
import numpy


def get_mistake_factor(difficulty):
    if difficulty == 1:
        return 10
    elif difficulty == 2:
        return 5
    elif difficulty == 3:
        return 2
    elif difficulty == 4:
        return 0
    else:
        print "not allowed difficulty"
        return None


def next_move(field, signOwn, signOpponent, signEmpty, difficulty):
    factor_other_priorities = 0.1
    factor_priority_above = 0.4
    print "(priority_column = max_priority +", factor_other_priorities, "* influence other priorities -",
    print factor_priority_above, "* priority_above)"

    priority = [0, 0, 0, 0, 0, 0, 0]
    for row in range(0, 7):
        priority[row] = get_priorities(field, row, signOwn, signOpponent, signEmpty, factor_other_priorities,
                                       factor_priority_above) + random.randint(0, get_mistake_factor(difficulty))

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
    elif priority[bestRow] == -9999:
        print("no field left")
        return None
    print("result:", bestRow, priority[bestRow])
    return bestRow, False


def get_priorities(field, j, signOwn, signOpponent, signEmpty, factor_other_priorities, factor_priority_above,
                   iteration=0):
    i = get_position(field, -1, j, signEmpty)

    if i <= -1:
        if iteration == 0:
            print "-9999 no field left"
        else:
            print "fatal error in game_logic"
        return -9999

    priorities_row_off = get_priority(field, i, j, 0, 1, signOwn, signOpponent, signEmpty, True)
    priorities_row_def = get_priority(field, i, j, 0, 1, signOpponent, signOwn, signEmpty, False)
    priorities_column_off = get_priority(field, i, j, 1, 0, signOwn, signOpponent, signEmpty, True)
    priorities_column_def = get_priority(field, i, j, 1, 0, signOpponent, signOwn, signEmpty, False)
    priorities_diagonal1_off = get_priority(field, i, j, 1, 1, signOwn, signOpponent, signEmpty, True)
    priorities_diagonal1_def = get_priority(field, i, j, 1, 1, signOpponent, signOwn, signEmpty, False)
    priorities_diagonal2_off = get_priority(field, i, j, 1, -1, signOwn, signOpponent, signEmpty, True)
    priorities_diagonal2_def = get_priority(field, i, j, 1, -1, signOpponent, signOwn, signEmpty, False)

    if iteration == 0:
        print(priorities_row_off, priorities_row_def, priorities_column_off, priorities_column_def,
              priorities_diagonal1_off, priorities_diagonal1_def, priorities_diagonal2_off, priorities_diagonal2_def),

    # calculates the priority of the opponent for the field above -> a higher priority for the opponent means a lower priority for the field
    priority_above = 0
    if i > 0:
        above_field = numpy.copy(field)
        above_field[i][j] = signOwn

        priority_above = factor_priority_above * get_priorities(above_field, j, signOpponent, signOwn, signEmpty,
                                                                factor_other_priorities,
                                                                factor_priority_above=factor_priority_above / 2,
                                                                iteration=iteration + 1)

    max_offense = max(priorities_row_off, priorities_column_off, priorities_diagonal1_off, priorities_diagonal2_off)
    max_defense = max(priorities_row_def, priorities_column_def, priorities_diagonal1_def, priorities_diagonal2_def)
    if max_offense == 3000:
        if iteration == 0:
            print("winning"),
            print(3000)
        return max_offense

    elif max_offense > max_defense:
        other_priorities = (factor_other_priorities * (
                priorities_row_off + priorities_column_off + priorities_diagonal1_off + priorities_diagonal2_off))
        result = max_offense + other_priorities - priority_above

        if iteration == 0:
            print"offense:", result, "(=", max_offense, "+", other_priorities, "-", priority_above, ")"
        return result

    else:
        other_priorities = factor_other_priorities * (
                priorities_row_def + priorities_column_def + priorities_diagonal1_def + priorities_diagonal2_def)
        result = max_defense + other_priorities - priority_above

        if iteration == 0:
            print"defense:", result, "(=", max_defense, "+", other_priorities, "-", priority_above, ")"
        return result


def get_priority(field, i, j, up, right, sign_own, sign_opponent, sign_empty, off):
    amount_own = 0
    amount_empty = 0

    # direction1
    if 0 <= i - up <= 5 and 0 <= j - right <= 6:
        if field[i - up][j - right] == sign_own:
            amount_own += 1
        if field[i - up][j - right] == sign_empty:
            amount_empty += 1

    if 0 <= i - (up + up) <= 5 and 0 <= j - (right + right) <= 6 and field[i - up][j - right] != sign_opponent:
        if field[i - (up + up)][j - (right + right)] == sign_own:
            amount_own += 1
        if field[i - (up + up)][j - (right + right)] == sign_empty:
            amount_empty += 1

    if 0 <= i - (up + up + up) <= 5 and 0 <= j - (right + right + right) <= 6 and field[i - up][
        j - right] != sign_opponent and field[i - (up + up)][j - (right + right)] != sign_opponent:
        if field[i - (up + up + up)][j - (right + right + right)] == sign_own:
            amount_own += 1
        if field[i - (up + up + up)][j - (right + right + right)] == sign_empty:
            amount_empty += 1

    # direction2
    if 0 <= i + up <= 5 and 0 <= j + right <= 6:
        if field[i + up][j + right] == sign_own:
            amount_own += 1
        if field[i + up][j + right] == sign_empty:
            amount_empty += 1

    if 0 <= i + (up + up) <= 5 and 0 <= j + (right + right) <= 6 and field[i + up][j + right] != sign_opponent:
        if field[i + (up + up)][j + (right + right)] == sign_own:
            amount_own += 1
        if field[i + (up + up)][j + (right + right)] == sign_empty:
            amount_empty += 1

    if 0 <= i + (up + up + up) <= 5 and 0 <= j + (right + right + right) <= 6 and field[i + up][
        j + right] != sign_opponent and field[i + (up + up)][j + (right + right)] != sign_opponent:
        if field[i + (up + up + up)][j + (right + right + right)] == sign_own:
            amount_own += 1
        if field[i + (up + up + up)][j + (right + right + right)] == sign_empty:
            amount_empty += 1

    priority_win = 0
    if amount_own >= 3:
        priority_win = 3000
    elif amount_own == 2 and amount_empty >= 1:
        priority_win = 20 + amount_empty * 1
    elif amount_own == 1 and amount_empty >= 2:
        priority_win = 10 + amount_empty * 1
    elif amount_own == 0 and amount_empty >= 3:
        priority_win = amount_empty * 1

    if off:  # it is possible to prioritize the offensive or defensive by multiplying the value returned by a factor
        return priority_win
    else:
        return priority_win * 0.9


def set_point_y(field, i, j):
    if i < 5 and field[i + 1][j] == '-':
        return set_point_y(field, i + 1, j)
    else:
        field[i][j] = 'Y'
        return field


def set_point_r(field, i, j):
    if i < 5 and field[i + 1][j] == '-':
        return set_point_r(field, i + 1, j)
    else:
        field[i][j] = 'R'
        return field


def get_position(field, i, j, signEmpty):
    if i < 5 and field[i + 1][j] == signEmpty:
        return get_position(field, i + 1, j, signEmpty)
    else:
        return i
