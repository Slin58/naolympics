import unittest
from connect_four_tactic import connect_four_tactic


class TestConnectFour(unittest.TestCase):

    def test_get_field_after_move_r(self):
        field = [['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-']]

        self.assertEqual([['-', '-', '-', '-', '-', '-', '-'],
                          ['-', '-', '-', '-', '-', '-', '-'],
                          ['-', '-', '-', '-', '-', '-', '-'],
                          ['-', '-', '-', '-', '-', '-', '-'],
                          ['-', '-', '-', '-', '-', '-', '-'],
                          ['-', '-', '-', 'R', '-', '-', '-']],
                         connect_four_tactic.set_point_r(field, -1, 3))

    def test_get_field_after_move_y(self):
        field = [['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-']]
        self.assertEqual([['-', '-', '-', '-', '-', '-', '-'],
                          ['-', '-', '-', '-', '-', '-', '-'],
                          ['-', '-', '-', '-', '-', '-', '-'],
                          ['-', '-', '-', '-', '-', '-', '-'],
                          ['-', '-', '-', '-', '-', '-', '-'],
                          ['-', '-', '-', 'Y', '-', '-', '-']],
                         connect_four_tactic.set_point_y(field, -1, 3))

    def test_get_field_after_move_r2(self):
        field = [['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', 'R', '-', '-', '-'],
                 ['-', '-', '-', 'Y', '-', '-', '-'],
                 ['-', '-', '-', 'R', '-', '-', '-'],
                 ['-', '-', '-', 'Y', '-', '-', '-'],
                 ['-', '-', '-', 'R', '-', '-', '-']]
        self.assertEqual([['-', '-', '-', 'R', '-', '-', '-'],
                          ['-', '-', '-', 'R', '-', '-', '-'],
                          ['-', '-', '-', 'Y', '-', '-', '-'],
                          ['-', '-', '-', 'R', '-', '-', '-'],
                          ['-', '-', '-', 'Y', '-', '-', '-'],
                          ['-', '-', '-', 'R', '-', '-', '-']],
                         connect_four_tactic.set_point_r(field, -1, 3))

    def test_get_field_after_move_y2(self):
        field = [['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', 'R', '-', '-', '-'],
                 ['-', '-', '-', 'Y', '-', '-', '-'],
                 ['-', '-', '-', 'R', '-', '-', '-'],
                 ['-', '-', '-', 'Y', '-', '-', '-'],
                 ['-', '-', '-', 'R', '-', '-', '-']]
        print(connect_four_tactic.set_point_y(field, -1, 3))
        self.assertEqual([['-', '-', '-', 'Y', '-', '-', '-'],
                          ['-', '-', '-', 'R', '-', '-', '-'],
                          ['-', '-', '-', 'Y', '-', '-', '-'],
                          ['-', '-', '-', 'R', '-', '-', '-'],
                          ['-', '-', '-', 'Y', '-', '-', '-'],
                          ['-', '-', '-', 'R', '-', '-', '-']],
                         connect_four_tactic.set_point_r(field, -1, 3))

    def test_next_move_difficulty_impossible(self):
        field = [['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-']]
        for i in range(0, 8):
            self.assertEqual(type((3, False)), type((connect_four_tactic.next_move(field, 'Y', 'R', '-', 'i'))))

    def test_next_move_difficulty_hard(self):
        field = [['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-']]
        self.assertEqual(type((2, False)), type((connect_four_tactic.next_move(field, 'Y', 'R', '-', 'h'))))

    def test_next_move_difficulty_medium(self):
        field = [['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-']]
        self.assertEqual(type((2, False)), type((connect_four_tactic.next_move(field, 'Y', 'R', '-', 'm'))))

    def test_next_move_difficulty_easy(self):
        field = [['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-']]
        self.assertEqual(type((2, False)), type((connect_four_tactic.next_move(field, 'Y', 'R', '-', 'e'))))

    def test_next_move_winning(self):
        field = [['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', 'Y', '-', '-', 'R', '-', '-'],
                 ['-', 'Y', '-', '-', 'R', '-', '-'],
                 ['-', 'Y', '-', '-', 'R', '-', '-']]
        self.assertEqual((1, True), connect_four_tactic.next_move(field, 'Y', 'R', '-', 'i'), )

    def test_next_move_defending(self):
        field = [['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', '-', '-'],
                 ['-', '-', '-', '-', '-', 'R', '-'],
                 ['-', '-', '-', '-', '-', 'R', '-'],
                 ['-', '-', 'Y', 'Y', '-', 'R', 'Y']]
        self.assertEqual((5, False), connect_four_tactic.next_move(field, 'Y', 'R', '-', 'i'))

    def test_next_move_full(self):
        field = [['R', 'R', 'Y', 'y', 'R', 'R', 'Y'],
                 ['Y', 'Y', 'R', 'R', 'Y', 'Y', 'R'],
                 ['R', 'R', 'Y', 'Y', 'R', 'R', 'Y'],
                 ['Y', 'Y', 'R', 'R', 'Y', 'Y', 'R'],
                 ['R', 'R', 'Y', 'Y', 'R', 'R', 'Y'],
                 ['Y', 'Y', 'R', 'R', 'Y', 'Y', 'R']]
        self.assertIsNone(connect_four_tactic.next_move(field, 'R', 'Y', '-', 'i'))
