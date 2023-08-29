# coding=utf-8
import almath
from naoqi import ALProxy
import time

import armPosition


def crouch(robotIP, port):
    postureProxy = ALProxy("ALRobotPosture", robotIP, port)
    postureProxy.goToPosture("Crouch", 1.0)


def stand(robotIP, port):
    postureProxy = ALProxy("ALRobotPosture", robotIP, port)
    postureProxy.goToPosture("Stand", 1.0)


def disableAutonomousLife(robotIP, port):
    autonomous_life_proxy = ALProxy("ALAutonomousLife", robotIP, port)
    autonomous_life_proxy.setState("disabled")


def tabletPreparationXAngle(robotIP, port):
    armMovement(robotIP, port, arm="L", position=armPosition.positionTabletPreparation, go_back=False)

    armMovement(robotIP, port, arm="R", position=armPosition.positionTabletPreparation, go_back=False)


def tabletPosition(robotIP, port):
    armMovement(robotIP, port, arm="L", position=armPosition.positionLUp[4][0], go_back=False)

    armMovement(robotIP, port, arm="R", position=armPosition.positionLUp[4][8], go_back=False)
    openHand(robotIP, port, arm="L")
    openHand(robotIP, port, arm="R")


def startPositionL(robotIP, port):
    motionProxy = ALProxy("ALMotion", robotIP, port)

    for i in range(0, 5):
        i = 4 - i  # order of movement swapped that the robot won't hit the tablet
        motionProxy.angleInterpolationWithSpeed(armPosition.positionL[i],
                                                armPosition.positionStart[i] * almath.TO_RAD, 0.2)
        motionProxy.waitUntilMoveIsFinished()
    openHand(robotIP, port, arm="L")


def startPositionR(robotIP, port):
    motionProxy = ALProxy("ALMotion", robotIP, port)

    for i in range(1, 5):
        i = 4 - i  # order of movement swapped that the robot won't hit the tablet
        motionProxy.angleInterpolationWithSpeed(armPosition.positionR[i],
                                                armPosition.positionStart[i] * (-1) * almath.TO_RAD, 0.2)
        motionProxy.waitUntilMoveIsFinished()

    motionProxy.angleInterpolationWithSpeed(armPosition.positionR[0],
                                            armPosition.positionStart[0] * almath.TO_RAD, 0.2)
    motionProxy.waitUntilMoveIsFinished()
    openHand(robotIP, port, arm="R")


def startPosition(robotIP, port):
    startPositionL(robotIP, port)
    startPositionR(robotIP, port)


def openHand(robotIP, port, arm):
    motionProxy = ALProxy("ALMotion", robotIP, port)

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


def closeHand(robotIP, port, arm):
    motionProxy = ALProxy("ALMotion", robotIP, port)

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


def clickRHandSpecific(robotIP, port):
    motionProxy = ALProxy("ALMotion", robotIP, port)

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

    print("done")


def armMovement(robotIP, port, arm, position, go_back):
    motionProxy = ALProxy("ALMotion", robotIP, port)

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

        time.sleep(0.15)

        if go_back:
            startPositionL(robotIP, port)

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

        time.sleep(0.15)

        if go_back:
            startPositionR(robotIP, port)

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

    return positionResult


def clickTicTacToe(robotIP, port, positionName):
    if positionName == 0:
        armMovement(robotIP, port, arm="L", position=getInterpolatedPosition(left=1.2, up=6), go_back=True)
    elif positionName == 1:
        armMovement(robotIP, port, arm="L", position=getInterpolatedPosition(left=0, up=6), go_back=True)
    elif positionName == 2:
        armMovement(robotIP, port, arm="R", position=getInterpolatedPosition(left=1.2, up=6), go_back=True)
    elif positionName == 3:
        armMovement(robotIP, port, arm="L", position=getInterpolatedPosition(left=1.2, up=4.3), go_back=True)
    elif positionName == 4:
        armMovement(robotIP, port, arm="L", position=getInterpolatedPosition(left=0, up=4.3), go_back=True)
    elif positionName == 5:
        armMovement(robotIP, port, arm="R", position=getInterpolatedPosition(left=1.2, up=4.3), go_back=True)
    elif positionName == 6:
        armMovement(robotIP, port, arm="L", position=getInterpolatedPosition(left=1.2, up=2.5), go_back=True)
    elif positionName == 7:
        armMovement(robotIP, port, arm="L", position=getInterpolatedPosition(left=0, up=2.5), go_back=True)
    elif positionName == 8:
        armMovement(robotIP, port, arm="R", position=getInterpolatedPosition(left=1.2, up=2.5), go_back=True)


def clickConnectFour(robotIP, port, positionName):
    if positionName == 0:
        armMovement(robotIP, port, arm="L", position=getInterpolatedPosition(left=2.25, up=6), go_back=True)
    elif positionName == 1:
        armMovement(robotIP, port, arm="L", position=getInterpolatedPosition(left=1.6, up=6), go_back=True)
    elif positionName == 2:
        armMovement(robotIP, port, arm="L", position=getInterpolatedPosition(left=0.93, up=6), go_back=True)
    elif positionName == 3:
        armMovement(robotIP, port, arm="L", position=getInterpolatedPosition(left=0, up=6), go_back=True)
    elif positionName == 4:
        armMovement(robotIP, port, arm="R", position=getInterpolatedPosition(left=0.23, up=6), go_back=True)
    elif positionName == 5:
        armMovement(robotIP, port, arm="R", position=getInterpolatedPosition(left=0.93, up=6), go_back=True)
    elif positionName == 6:
        armMovement(robotIP, port, arm="R", position=getInterpolatedPosition(left=1.6, up=6), go_back=True)


def celebrate(robotIP, port):
    # todo
    print("not implemented yet")


def disappointment(robotIP, port):
    # todo
    print("not implemented yet")


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
    #startPositionR("10.30.4.13", 9559)

    # openHand(arm="R")
    # openHand(arm="L")

    #armMovement(robotIP="10.30.4.13", port=9559, position=getInterpolatedPosition(left=1.7, up=6), arm="L", go_back=True)
    clickConnectFour("10.30.4.13", 9559, 6)
    # closeHand(arm="L")
