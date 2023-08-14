# coding=utf-8
import almath
from naoqi import ALProxy
import time

import armPosition
import tictactoeTactic

# IP address of the NAO robot
robotIP = "10.30.4.13"

# Port number of the ALMotion proxy
PORT = 9559


def crouch():
    postureProxy = ALProxy("ALRobotPosture", robotIP, 9559)
    postureProxy.goToPosture("Crouch", 1.0)


def stand():
    postureProxy = ALProxy("ALRobotPosture", robotIP, 9559)
    postureProxy.goToPosture("Stand", 1.0)


def disableAutonomousLife():
    autonomous_life_proxy = ALProxy("ALAutonomousLife", robotIP, 9559)
    autonomous_life_proxy.setState("disabled")


def tabletPreparationYAngle():
    armMovement(position=armPosition.positionTabletPreparation, arm="L", go_back=False)

    armMovement(position=armPosition.positionTabletPreparation, arm="R", go_back=False)


def tabletPosition():
    armMovement(position=armPosition.positionLUp[4][0], arm="L", go_back=False)

    armMovement(position=armPosition.positionLUp[4][8], arm="R", go_back=False)
    openHand(arm="R")
    openHand(arm="L")

def startPositionL():
    motionProxy = ALProxy("ALMotion", robotIP, PORT)

    for i in range(0, 5):
        i = 4 - i  # order of movement swapped that the robot won't hit the tablet
        motionProxy.angleInterpolationWithSpeed(armPosition.positionL[i],
                                                armPosition.positionStart[i] * almath.TO_RAD, 0.2)
        motionProxy.waitUntilMoveIsFinished()
    openHand(arm="L")


def startPositionR():
    motionProxy = ALProxy("ALMotion", robotIP, PORT)

    for i in range(1, 5):
        i = 4 - i  # order of movement swapped that the robot won't hit the tablet
        motionProxy.angleInterpolationWithSpeed(armPosition.positionR[i],
                                                armPosition.positionStart[i] * (-1) * almath.TO_RAD, 0.2)
        motionProxy.waitUntilMoveIsFinished()

    motionProxy.angleInterpolationWithSpeed(armPosition.positionR[0],
                                            armPosition.positionStart[0] * almath.TO_RAD, 0.2)
    motionProxy.waitUntilMoveIsFinished()
    openHand(arm="R")


def openHand(arm):
    motionProxy = ALProxy("ALMotion", robotIP, PORT)

    if arm == "R":
        hand_name = "RHand"
    elif arm == "L":
        hand_name = "LHand"
    else:
        print('wrong arm: "L" or "R" possible')
        return

    # open hand
    motionProxy.openHand(hand_name)

    # does the same but without predefined method:
    # angle = math.radians(1) # Fully open position
    # speed = 0.2  # Speed of the movement (range: 0.0 to 1.0)
    # motionProxy.angleInterpolationWithSpeed(hand_name, angle, speed)

    # Wait for the hand movement to complete
    motionProxy.waitUntilMoveIsFinished()


def closeHand(arm):
    motionProxy = ALProxy("ALMotion", robotIP, PORT)

    if arm == "R":
        hand_name = "RHand"
    elif arm == "L":
        hand_name = "LHand"
    else:
        print('wrong arm: "L" or "R" possible')
        return

    # close hand
    motionProxy.closeHand(hand_name)

    # Wait for the hand movement to complete
    motionProxy.waitUntilMoveIsFinished()


def clickRHandSpecific():
    motionProxy = ALProxy("ALMotion", robotIP, PORT)

    # Enable the arm control
    motionProxy.setStiffnesses("RArm", 1.0)

    motionProxy.angleInterpolationWithSpeed("RShoulderPitch", 18.4 * almath.TO_RAD, 0.2)
    motionProxy.waitUntilMoveIsFinished()
    motionProxy.angleInterpolationWithSpeed("RShoulderRow", -1.3 * almath.TO_RAD, 0.2)
    motionProxy.waitUntilMoveIsFinished()
    motionProxy.angleInterpolationWithSpeed("RElbowRoll", 27.7 * almath.TO_RAD, 0.2)
    motionProxy.waitUntilMoveIsFinished()
    motionProxy.angleInterpolationWithSpeed("RWristYaw", 5.3 * almath.TO_RAD, 0.2)
    motionProxy.waitUntilMoveIsFinished()
    motionProxy.angleInterpolationWithSpeed("RElbowYaw", 67.1 * almath.TO_RAD, 0.2)
    motionProxy.waitUntilMoveIsFinished()

    # Disable the arm control
    motionProxy.setStiffnesses("RArm", 0.0)

    print("done")


def armMovement(position, arm, go_back):
    motionProxy = ALProxy("ALMotion", robotIP, PORT)

    # for stabilization (without it the robot may fall over)
    motionProxy.setStiffnesses("LLeg", 1.0)
    motionProxy.setStiffnesses("RLeg", 1.0)
    motionProxy.setStiffnesses("Body", 1.0)

    # position of head
    motionProxy.angleInterpolationWithSpeed("HeadYaw", 0.0 * almath.TO_RAD, 0.2)
    time.sleep(0.2)
    motionProxy.angleInterpolationWithSpeed("HeadPitch", 8.0 * almath.TO_RAD, 0.2)
    time.sleep(0.2)

    if arm == "L":
        # enable arm control
        motionProxy.setStiffnesses("LArm", 1.0)

        for i in range(0, 5):
            motionProxy.angleInterpolationWithSpeed(armPosition.positionL[i], position[i] * almath.TO_RAD, 0.2)
            motionProxy.waitUntilMoveIsFinished()

        time.sleep(0.2)

        if go_back:
            startPositionL()

    elif arm == "R":
        # for right arm, use left arm positions with right arm:
        #    multiply: ShoulderRow, ElbowRow, WristYaw and ElbowYaw by (-1) (everything except ShoulderPitch)

        # enable arm control
        motionProxy.setStiffnesses("RArm", 1.0)

        motionProxy.angleInterpolationWithSpeed(armPosition.positionR[0], position[0] * almath.TO_RAD, 0.2)
        motionProxy.waitUntilMoveIsFinished()
        for i in range(1, 5):
            motionProxy.angleInterpolationWithSpeed(armPosition.positionR[i], (position[i] * (-1)) * almath.TO_RAD, 0.2)
            motionProxy.waitUntilMoveIsFinished()

        time.sleep(0.2)

        if go_back:
            startPositionR()

    else:
        print('wrong arm: "L" or "R" possible')
        return

    print("done")


def getInterpolatedPosition(left, up):     # translate comma amounts for Left and Up to the inbetween point of two
    if left - int(left) == 0 and up - int(up) == 0:
        return armPosition.positionLUp[left][up]

    if left - int(left) == 0:
        left1 = left
        left2 = left
    else:
        left1 = int(left)
        left2 = int(left) + 1
    if up - int(up) == 0:
        up1 = up
        up2 = up
    else:
        up1 = int(up)
        up2 = int(up) + 1

    print(left1, left2, up1, up2)

    difL = left - int(left)
    difUp = up - int(up)

    positionL1 = [0.0, 0.0, 0.0, 0.0, 0.0]
    for i in range(0, 5):
        positionL1[i] = armPosition.positionLUp[left1][up1][i] * (1 - difUp) \
                        + armPosition.positionLUp[left1][up2][i] * difUp

    positionL2 = [0.0, 0.0, 0.0, 0.0, 0.0]
    for i in range(0, 5):
        positionL2[i] = armPosition.positionLUp[left2][up1][i] * (1 - difUp) \
                        + armPosition.positionLUp[left2][up2][i] * difUp

    positionResult = [0.0, 0.0, 0.0, 0.0, 0.0]
    for i in range(0, 5):
        positionResult[i] = positionL1[i] * (1 - difL) + positionL2[i] * difL

    print("Position1: ", armPosition.positionLUp[left1][up1])
    print("Position2: ", armPosition.positionLUp[left1][up2])
    print("Position3: ", armPosition.positionLUp[left2][up1])
    print("Position4: ", armPosition.positionLUp[left2][up2])
    print("positionL1 :", positionL1)
    print("positionL2 :", positionL2)
    print("positionResult :", positionResult)

    return positionResult


def clickTicTacToe(positionName):
    if positionName == 0:
        armMovement(position=getInterpolatedPosition(left=1, up=6), arm="L", go_back=True)
    elif positionName == 1:
        armMovement(position=getInterpolatedPosition(left=0, up=6), arm="L", go_back=True)
    elif positionName == 2:
        armMovement(position=getInterpolatedPosition(left=1, up=6), arm="R", go_back=True)
    elif positionName == 3:
        armMovement(position=getInterpolatedPosition(left=1, up=4.5), arm="L", go_back=True)
    elif positionName == 4:
        armMovement(position=getInterpolatedPosition(left=0, up=4.5), arm="L", go_back=True)
    elif positionName == 5:
        armMovement(position=getInterpolatedPosition(left=1, up=4.5), arm="R", go_back=True)
    elif positionName == 6:
        armMovement(position=getInterpolatedPosition(left=1, up=2), arm="L", go_back=True)
    elif positionName == 7:
        armMovement(position=getInterpolatedPosition(left=0, up=2), arm="L", go_back=True)
    elif positionName == 8:
        armMovement(position=getInterpolatedPosition(left=1, up=2), arm="R", go_back=True)


def clickConnectFour(positionName):
    # todo
    print("not implemented yet")


if __name__ == "__main__":
    # disableAutonomousLife()
    # stand()

    # tabletPreparationYAngle()
    # tabletPosition()

    # startPositionL()
    # startPositionR()
    # openHand(arm="R")
    # openHand(arm="L")

    """
    # repeating this:  
    field = [['o', 'o', 'x'], ['x', 'x', '_'], ['_', 'x', 'o']] # field = vision()

    result = tictactoeTactic.nextMove(field, signOwn='o', signOpponent='x', signEmpty='_', difficulty='i')

    clickTicTacToe(result)
    """

    armMovement(position=getInterpolatedPosition(left=0.7, up=1.8), arm="L", go_back=True)

    # closeHand(arm="L")
