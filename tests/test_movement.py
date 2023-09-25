import unittest
from movement import movementControl
from movement import armPosition


class TestMovement(unittest.TestCase):

    def test_get_interpolated_position(self):
        self.assertEqual(armPosition.positionLUp[0][0], movementControl.get_interpolated_position(0, 0))

    def test_get_interpolated_position1(self):
        result = [0, 0, 0, 0, 0]
        for i in range(len(result)):
            result[i] = (armPosition.positionLUp[0][0][i] + armPosition.positionLUp[1][0][i]) / 2.0

        self.assertEqual(result, movementControl.get_interpolated_position(0.5, 0))

    def test_get_interpolated_position2(self):
        result = [0, 0, 0, 0, 0]
        for i in range(len(result)):
            result[i] = (armPosition.positionLUp[0][0][i] + armPosition.positionLUp[0][1][i]) / 2.0

        self.assertEqual(result, movementControl.get_interpolated_position(0, 0.5))

    def test_get_interpolated_position3(self):
        result1 = [0, 0, 0, 0, 0]
        result2 = [0, 0, 0, 0, 0]
        result = [0, 0, 0, 0, 0]
        for i in range(len(result)):
            result1[i] = (armPosition.positionLUp[0][0][i] + armPosition.positionLUp[1][0][i]) / 2.0
            result2[i] = (armPosition.positionLUp[0][1][i] + armPosition.positionLUp[1][1][i]) / 2.0
            result[i] = (result1[i] + result2[i]) / 2

        self.assertEqual(result, movementControl.get_interpolated_position(0.5, 0.5))

    def test_get_interpolated_position4(self):
        result1 = [0, 0, 0, 0, 0]
        result2 = [0, 0, 0, 0, 0]
        result = [0, 0, 0, 0, 0]
        for i in range(len(result)):
            result1[i] = (armPosition.positionLUp[0][0][i] + armPosition.positionLUp[0][1][i]) / 2.0
            result2[i] = (armPosition.positionLUp[1][0][i] + armPosition.positionLUp[1][1][i]) / 2.0
            result[i] = (result1[i] + result2[i]) / 2

        self.assertNotEqual(result, movementControl.get_interpolated_position(0.6, 0.5))
