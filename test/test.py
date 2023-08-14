from vision import vision
from tictactoe_tactic import tictactoeTactic
from movement import armPosition, movementControl

if __name__ == "__main__":

    # movement_control.disableAutonomousLife()
    # movement_control.stand()

    # wasserwaage
    #movement_control.tabletPreparationYAngle()
    # movement_control.tabletPosition()

    #movement_control.startPositionL()
    #movement_control.startPositionR()


    # repeating this:  
   # field = [['o', 'o', 'x'], ['x', 'x', '_'], ['_', 'x', 'o']] # field = vision()

    img = vision.get_image_from_nao(ip="10.30.4.13", port=9559)
    field = vision.detect_tictactoe_state(img)
    print(field)

    result = tictactoeTactic.nextMove(field, signOwn='X', signOpponent='O', signEmpty='-', difficulty='e')
    print(result)

    movementControl.clickTicTacToe(result)


    #movement_control.armMovement(position=getInterpolatedPosition(left=0.7, up=1.8), arm="L", go_back=True)

    # closeHand(arm="L")
