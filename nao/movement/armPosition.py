# coding=utf-8

positionR = ["RShoulderPitch", "RShoulderRoll", "RElbowRoll", "RWristYaw", "RElbowYaw"]
positionL = ["LShoulderPitch", "LShoulderRoll", "LElbowRoll", "LWristYaw", "LElbowYaw"]
positionLRange = [-119.5 - 119.5, -75, 9 - 15.0, 2 - 85, (0 - 1), -104.3 - 103.9, -119 - 119]

# position (without the not clickable edge):
#   Left 0 - 4
#   Up 0 - 8
# tablet (including the not clickable edge:
#   wideness: 28.5 cm
#   height: 37.5cm - 56 cm

# standing
# left arm

positionLTabletPreparation = [-10, 0, -85, -20, -90]

positionLStart = [60, 60, -88, 0, 0]

positionLCelebration1 = [10, 0, -85, 0, -90]
positionLCelebration2 = [-80, 5, -2, 0, -90]

positionRCelebration1 = [10, 0, 85, 0, 90]
positionRCelebration2 = [-80, -5, 2, 0, 90]

positionLCelebration3 = [0, -10, -80, 0, 0]
positionLCelebration4 = [-34, -10, -65, 0, 0]
positionLCelebration5 = [-50, 60, 2, 0, 0]

positionRCelebration3 = [0, 10, 80, 0, 0]
positionRCelebration4 = [-34, 10, 65, 0, 0]
positionRCelebration5 = [-50, -60, -2, 0, 0]

# for right arm, use left arm positions with right arm:
#    multiply: ShoulderRoll, ElbowRow, WristYaw and ElbowYaw by (-1) (everything except ShoulderPitch)

positionLUp = [
    [[], [], [], [], [], [], [], [], []],
    [[], [], [], [], [], [], [], [], []],
    [[], [], [], [], [], [], [], [], []],
    [[], [], [], [], [], [], [], [], []],
    [[], [], [], [], [], [], [], [], []],
    [[], [], [], [], [], [], [], [], []],
    [[], [], [], [], [], [], [], [], []],
    [[], [], [], [], [], [], [], [], []],
    [[], [], [], [], [], [], [], [], []],
]

# height 49,5 cm -> upper end of tablet
positionLUp[5][8] = [-40, 23, -31, 0, 0]
positionLUp[4][8] = [-40, 17, -32, 0, 0]  # exactly left up is 4.4
positionLUp[3][8] = [-40, 11, -31, 0, 0]
positionLUp[2][8] = [-40, 2, -27, 0, 0]
positionLUp[1][8] = [-40, -7, -23, 0, 0]
positionLUp[0][8] = [-40, -18, -15, -20, 0]

# height ?? cm
positionLUp[5][7] = [-35, 36, -49, 0, 0]
positionLUp[4][7] = [-35, 31, -51, 0, 0]
positionLUp[3][7] = [-35, 25, -53, 0, 0]
positionLUp[2][7] = [-35, 16, -49, 0, 0]
positionLUp[1][7] = [-35, 5, -43, 0, 0]
positionLUp[0][7] = [-35, -8, -32, 0, 0]

# height ?? cm
positionLUp[5][6] = [-30, 45, -59, 0, 0]
positionLUp[4][6] = [-30, 39, -62, 0, 0]
positionLUp[3][6] = [-30, 33, -64, 0, 0]
positionLUp[2][6] = [-30, 23, -60, 0, 0]
positionLUp[1][6] = [-30, 12, -54, 0, 0]
positionLUp[0][6] = [-30, 0, -46, 0, 0]

# height ?? cm
positionLUp[5][5] = [-25, 51, -66, 0, 0]
positionLUp[4][5] = [-25, 45, -70, 0, 0]
positionLUp[3][5] = [-25, 37, -70, 0, 0]
positionLUp[2][5] = [-25, 28, -68, 0, 0]
positionLUp[1][5] = [-25, 18, -65, 0, 0]
positionLUp[0][5] = [-25, 4, -54, 0, 0]

# height ?? cm -> slightly under middle
positionLUp[5][4] = [-20, 55, -70, 0, 0]
positionLUp[4][4] = [-20, 50, -75, 0, 0]
positionLUp[3][4] = [-20, 42, -76, 0, 0]
positionLUp[2][4] = [-20, 33, -75, 0, 0]
positionLUp[1][4] = [-20, 21, -70, 0, 0]
positionLUp[0][4] = [-20, 8, -62, 0, 0]

# height ?? cm
positionLUp[5][3] = [-15, 58, -72, 0, 0]
positionLUp[4][3] = [-15, 47, -79, 0, 0]
positionLUp[3][3] = [-15, 39, -79, 0, 0]
positionLUp[2][3] = [-15, 30, -77, 0, 0]
positionLUp[1][3] = [-15, 19, -70, 0, 0]
positionLUp[0][3] = [-15, 8, -63, 0, 0]

# height ?? cm
positionLUp[5][2] = [-10, 60, -75, 0, 0]
positionLUp[4][2] = [-10, 50, -82, 0, 0]
positionLUp[3][2] = [-10, 42, -82, 0, 0]
positionLUp[2][2] = [-10, 32, -79, 0, 0]
positionLUp[1][2] = [-10, 21, -74, 0, 0]
positionLUp[0][2] = [-10, 9, -66, 0, 0]

# height ?? cm
positionLUp[5][1] = [-5, 62, -75, 0, 0]
positionLUp[4][1] = [-5, 51, -83, 0, 0]
positionLUp[3][1] = [-5, 44, -83, 0, 0]
positionLUp[2][1] = [-5, 34, -81, 0, 0]
positionLUp[1][1] = [-5, 24, -76, 0, 0]
positionLUp[0][1] = [-5, 11, -68, 0, 0]

# height 39 cm -> the lowest point
positionLUp[5][0] = [0, 62, -76, 0, 0]
positionLUp[4][0] = [0, 53, -84, 0, 0]  # exactly left down is 4.4
positionLUp[3][0] = [0, 45, -84, 0, 0]
positionLUp[2][0] = [0, 35, -81, 0, 0]
positionLUp[1][0] = [0, 23, -76, 0, 0]
positionLUp[0][0] = [0, 10, -67, 0, 0]
