# coding=utf-8
import almath
from naoqi import ALProxy
import time
import armPosition


def newRobotVersion(robotIP, port):
    autonomous_life = ALProxy("ALAutonomousLife", robotIP, port)
    try:
        autonomous_life.getAutonomousAbilitiesStatus()
    except RuntimeError:
        return False
    return True


def crouch(robotIP, port):
    postureProxy = ALProxy("ALRobotPosture", robotIP, port)
    postureProxy.goToPosture("Crouch", 1.0)


def stand(robotIP, port):
    postureProxy = ALProxy("ALRobotPosture", robotIP, port)
    postureProxy.goToPosture("Stand", 1.0)


def disable_autonomous_life(robotIP, port):
    autonomous_life_proxy = ALProxy("ALAutonomousLife", robotIP, port)
    autonomous_life_proxy.setState("disabled")


def tablet_preparation_x_angle(robotIP, port):
    arm_movement(robotIP, port, arm="L", position=armPosition.positionLTabletPreparation, go_back=False)

    arm_movement(robotIP, port, arm="R", position=armPosition.positionLTabletPreparation, go_back=False)


def tablet_position(robotIP, port):
    arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=4.4, up=0), go_back=False)
    arm_movement(robotIP, port, arm="R", position=get_interpolated_position(left=4.4, up=8), go_back=False)

    open_hand(robotIP, port, arm="L")
    open_hand(robotIP, port, arm="R")


def start_position_l(robotIP, port):
    motionProxy = ALProxy("ALMotion", robotIP, port)

    for i in range(0, 5):
        i = 4 - i  # order of movement swapped that the robot won't hit the tablet
        motionProxy.angleInterpolationWithSpeed(armPosition.positionL[i],
                                                armPosition.positionLStart[i] * almath.TO_RAD, 0.2)
        motionProxy.waitUntilMoveIsFinished()
    open_hand(robotIP, port, arm="L")


def start_position_r(robotIP, port):
    motionProxy = ALProxy("ALMotion", robotIP, port)

    for i in range(0, 4):
        i = 4 - i  # order of movement swapped that the robot won't hit the tablet
        motionProxy.angleInterpolationWithSpeed(armPosition.positionR[i],
                                                armPosition.positionLStart[i] * (-1) * almath.TO_RAD, 0.2)
        motionProxy.waitUntilMoveIsFinished()

    motionProxy.angleInterpolationWithSpeed(armPosition.positionR[0],
                                            armPosition.positionLStart[0] * almath.TO_RAD, 0.2)
    motionProxy.waitUntilMoveIsFinished()
    open_hand(robotIP, port, arm="R")


def start_position(robotIP, port):
    motionProxy = ALProxy("ALMotion", robotIP, port)
    motionProxy.setStiffnesses("LLeg", 1.0)
    motionProxy.setStiffnesses("RLeg", 1.0)
    motionProxy.setStiffnesses("Body", 1.0)
    motionProxy.setStiffnesses("LArm", 1.0)
    motionProxy.setStiffnesses("RArm", 1.0)

    # position of head
    motionProxy.angleInterpolationWithSpeed("HeadYaw", 0.0 * almath.TO_RAD, 0.2)
    motionProxy.angleInterpolationWithSpeed("HeadPitch", -10 * almath.TO_RAD, 0.2)
    time.sleep(0.2)
    if newRobotVersion(robotIP, port):
        motionProxy.angleInterpolationWithSpeed("HeadPitch", 16 * almath.TO_RAD, 0.2)
    else:
        motionProxy.angleInterpolationWithSpeed("HeadPitch", 7.5 * almath.TO_RAD, 0.2)
    time.sleep(0.2)

    start_position_l(robotIP, port)
    start_position_r(robotIP, port)


def open_hand(robotIP, port, arm):
    motionProxy = ALProxy("ALMotion", robotIP, port)

    if arm == "R":
        hand_name = "RHand"
    elif arm == "L":
        hand_name = "LHand"
    else:
        print('wrong arm: "L" or "R" possible')
        return

    motionProxy.openHand(hand_name)

    # does the same but without predefined method:
    # angle = math.radians(1) # Fully open position
    # speed = 0.2  # Speed of the movement (range: 0.0 to 1.0)
    # motionProxy.angleInterpolationWithSpeed(hand_name, angle, speed)

    # Wait for the hand movement to complete
    motionProxy.waitUntilMoveIsFinished()


def close_hand(robotIP, port, arm):
    motionProxy = ALProxy("ALMotion", robotIP, port)

    if arm == "R":
        hand_name = "RHand"
    elif arm == "L":
        hand_name = "LHand"
    else:
        print('wrong arm: "L" or "R" possible')
        return

    motionProxy.closeHand(hand_name)

    # Wait for the hand movement to complete
    motionProxy.waitUntilMoveIsFinished()


def click_r_hand_specific(robotIP, port):
    motionProxy = ALProxy("ALMotion", robotIP, port)

    motionProxy.setStiffnesses("LLeg", 1.0)
    motionProxy.setStiffnesses("RLeg", 1.0)
    motionProxy.setStiffnesses("Body", 1.0)
    motionProxy.setStiffnesses("LArm", 1.0)
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


def arm_movement(robotIP, port, arm, position, go_back):
    motionProxy = ALProxy("ALMotion", robotIP, port)

    # for stabilization (without it the robot may fall over)
    motionProxy.setStiffnesses("LLeg", 1.0)
    motionProxy.setStiffnesses("RLeg", 1.0)
    motionProxy.setStiffnesses("Body", 1.0)

    if arm == "L":
        motionProxy.setStiffnesses("LArm", 1.0)

        for i in range(0, 5):
            motionProxy.angleInterpolationWithSpeed(armPosition.positionL[i], position[i] * almath.TO_RAD, 0.2)
            motionProxy.waitUntilMoveIsFinished()

        time.sleep(0.15)

        if go_back:
            start_position_l(robotIP, port)

    elif arm == "R":
        # for right arm, use left arm positions with right arm:
        #    multiply: ShoulderRow, ElbowRow, WristYaw and ElbowYaw by (-1) (everything except ShoulderPitch)

        motionProxy.setStiffnesses("RArm", 1.0)

        motionProxy.angleInterpolationWithSpeed(armPosition.positionR[0], position[0] * almath.TO_RAD, 0.2)
        motionProxy.waitUntilMoveIsFinished()
        for i in range(1, 5):
            motionProxy.angleInterpolationWithSpeed(armPosition.positionR[i], (position[i] * (-1)) * almath.TO_RAD, 0.2)
            motionProxy.waitUntilMoveIsFinished()

        time.sleep(0.15)

        if go_back:
            start_position_r(robotIP, port)

    else:
        print('wrong arm: "L" or "R" possible')
        return

    print("done")


# translate comma amounts for Left and Up to the armPosition for the inbetween point of two or four points
def get_interpolated_position(left, up):
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


def click_tic_tac_toe(robotIP, port, positionName):
    if positionName == 0:
        arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=1.1, up=5.6), go_back=True)
    elif positionName == 1:
        arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=0, up=5.6), go_back=True)
    elif positionName == 2:
        arm_movement(robotIP, port, arm="R", position=get_interpolated_position(left=1.1, up=5.6), go_back=True)
    elif positionName == 3:
        arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=1.1, up=4.1), go_back=True)
    elif positionName == 4:
        arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=0, up=4.1), go_back=True)
    elif positionName == 5:
        arm_movement(robotIP, port, arm="R", position=get_interpolated_position(left=1.1, up=4.1), go_back=True)
    elif positionName == 6:
        arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=1.1, up=2.5), go_back=True)
    elif positionName == 7:
        arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=0, up=2.5), go_back=True)
    elif positionName == 8:
        arm_movement(robotIP, port, arm="R", position=get_interpolated_position(left=1.1, up=2.5), go_back=True)


def click_connect_four(robotIP, port, positionName):
    if newRobotVersion(robotIP, port):
        if positionName == 0:
            arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=2.5, up=6), go_back=True)
        elif positionName == 1:
            arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=1.75, up=6), go_back=True)
        elif positionName == 2:
            arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=1, up=6), go_back=True)
        elif positionName == 3:
            arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=0, up=6), go_back=True)
        elif positionName == 4:
            arm_movement(robotIP, port, arm="R", position=get_interpolated_position(left=1, up=6), go_back=True)
        elif positionName == 5:
            arm_movement(robotIP, port, arm="R", position=get_interpolated_position(left=1.75, up=6), go_back=True)
        elif positionName == 6:
            arm_movement(robotIP, port, arm="R", position=get_interpolated_position(left=2.5, up=6), go_back=True)
    else:
        if positionName == 0:
            arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=2.7, up=6), go_back=True)
        elif positionName == 1:
            arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=2.1, up=6), go_back=True)
        elif positionName == 2:
            arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=1, up=6), go_back=True)
        elif positionName == 3:
            arm_movement(robotIP, port, arm="L", position=get_interpolated_position(left=0, up=6), go_back=True)
        elif positionName == 4:
            arm_movement(robotIP, port, arm="R", position=get_interpolated_position(left=0.5, up=6), go_back=True)
        elif positionName == 5:
            arm_movement(robotIP, port, arm="R", position=get_interpolated_position(left=1.3, up=6), go_back=True)
        elif positionName == 6:
            arm_movement(robotIP, port, arm="R", position=get_interpolated_position(left=2, up=6), go_back=True)


def celebrate1(robotIP, port):
    motionProxy = ALProxy("ALMotion", robotIP, port)

    motionProxy.setStiffnesses("LLeg", 1.0)
    motionProxy.setStiffnesses("RLeg", 1.0)
    motionProxy.setStiffnesses("Body", 1.0)
    motionProxy.setStiffnesses("LArm", 1.0)
    motionProxy.setStiffnesses("RArm", 1.0)

    tts = ALProxy("ALTextToSpeech", robotIP, port)
    tts.say("Juhu, ich habe gewonnen! LOL!")

    for i in range(0, 3):
        motionProxy.setAngles(armPosition.positionL, [i * almath.TO_RAD for i in armPosition.positionLCelebration1],
                              0.2)
        motionProxy.setAngles(armPosition.positionR, [i * almath.TO_RAD for i in armPosition.positionRCelebration1],
                              0.2)
        time.sleep(1)

        motionProxy.setAngles(armPosition.positionL, [i * almath.TO_RAD for i in armPosition.positionLCelebration2],
                              0.2)
        motionProxy.setAngles(armPosition.positionR, [i * almath.TO_RAD for i in armPosition.positionRCelebration2],
                              0.2)
        time.sleep(1)

    start_position(robotIP, port)


def celebrate2(robotIP, port):
    motionProxy = ALProxy("ALMotion", robotIP, port)

    motionProxy.setStiffnesses("LLeg", 1.0)
    motionProxy.setStiffnesses("RLeg", 1.0)
    motionProxy.setStiffnesses("Body", 1.0)
    motionProxy.setStiffnesses("LArm", 1.0)
    motionProxy.setStiffnesses("RArm", 1.0)

    tts = ALProxy("ALTextToSpeech", robotIP, port)
    tts.say("Juhu, ich habe gewonnen! LOL!")

    # position of head
    motionProxy.angleInterpolationWithSpeed("HeadYaw", 30.0 * almath.TO_RAD, 0.2)
    time.sleep(0.2)
    motionProxy.angleInterpolationWithSpeed("HeadPitch", 15.0 * almath.TO_RAD, 0.2)
    time.sleep(0.2)

    motionProxy.setAngles(armPosition.positionL, [i * almath.TO_RAD for i in armPosition.positionLCelebration3], 0.2)
    time.sleep(0.8)
    motionProxy.setAngles(armPosition.positionL, [i * almath.TO_RAD for i in armPosition.positionLCelebration4], 0.2)

    motionProxy.setAngles(armPosition.positionR, [i * almath.TO_RAD for i in armPosition.positionRCelebration5], 0.2)
    time.sleep(2)

    start_position(robotIP, port)


def test_angles_head(robotIP, PORT):
    motionProxy = ALProxy("ALMotion", robotIP, PORT)

    angles1 = motionProxy.getAngles("Head", False)
    print "Eingestellte Winkel:"
    for x in angles1:
        print(str(x * almath.TO_DEG)),
    print("")
    angles2 = motionProxy.getAngles("Head", True)
    print "Tatsaechliche Winkel:"
    for x in angles2:
        print(str(x * almath.TO_DEG)),
    print("")


def test_angles_l_arm(robotIP, PORT):
    motionProxy = ALProxy("ALMotion", robotIP, PORT)

    angles1 = motionProxy.getAngles("LArm", False)
    print "Eingestellte Winkel:"
    for x in angles1:
        print(str(x * almath.TO_DEG)),
    print("")

    angles2 = motionProxy.getAngles("LArm", True)
    print "Tatsaechliche Winkel:"
    for x in angles2:
        print(str(x * almath.TO_DEG)),
    print("")


def test_angles_r_arm(robotIP, PORT):
    motionProxy = ALProxy("ALMotion", robotIP, PORT)

    angles1 = motionProxy.getAngles("RArm", False)
    print "Eingestellte Winkel:"
    for x in angles1:
        print(str(x * almath.TO_DEG)),
    print("")

    angles2 = motionProxy.getAngles("RArm", True)
    print "Tatsaechliche Winkel:"
    for x in angles2:
        print(str(x * almath.TO_DEG)),
    print("")
