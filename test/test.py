from vision import vision
from tictactoe_tactic import tictactoeTactic
from movement import movementControl

# IP address of the NAO robot
robotIP = "10.30.4.13"

# Port number of the ALMotion proxy
PORT = 9559

if __name__ == "__main__":
    # after startup of nao
    # movementControl.disableAutonomousLife(robotIP, PORT)
    # movementControl.stand(robotIP, PORT)

    # tablet positioning
    # use app Bubble Level (or similar to calibrate z-Angle)
    # movementControl.tabletPreparationXAngle(robotIP, PORT)
    # movementControl.tabletPosition(robotIP, PORT) # y-Angle

    # start positions
    # movementControl.startPositionL(robotIP, PORT)
    # movementControl.startPositionR(robotIP, PORT)

    # repeating this:
    img = vision.get_image_from_nao(ip=robotIP, port=PORT)
    field = vision.detect_tictactoe_state(img)  # field = [['O', 'O', 'X'], ['X', 'X', '-'], ['-', 'X', 'O']]
    print(field)

    # difficulty = e -> easy ,m -> medium,h -> hard,i -> impossible
    result = tictactoeTactic.nextMove(field, signOwn='X', signOpponent='O', signEmpty='-', difficulty='i')
    print(result)

    movementControl.clickTicTacToe(robotIP, PORT, result)

    # todo implement if won celebration else disappointment

    # closeHand(robotIP, PORT, arm="L")
