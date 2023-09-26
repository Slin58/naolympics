import unittest
from nao.tictactoe_tactic import tictactoe_tactic


class TestTictactoe(unittest.TestCase):

    def test_get_field_after_move(self):
        field = [['x', 'o', '_'], ['_', '_', '_'], ['_', '_', '_']]

        self.assertEqual([['x', 'o', '_'], ['_', 'x', '_'], ['_', '_', '_']],
                         tictactoe_tactic.get_field_after_move(field=field, result=4, ownSign='x'))

    def test_next_move_difficulty_impossible(self):
        field = [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']]

        for i in range(0, 8):
            self.assertEqual(type((2, False)), type((tictactoe_tactic.next_move(field, 'x', 'o', '_', 4))))

    def test_next_move_difficulty_hard(self):
        field = [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']]

        self.assertEqual(type((2, False)), type((tictactoe_tactic.next_move(field, 'x', 'o', '_', 3))))

    def test_next_move_difficulty_medium(self):
        field = [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']]

        self.assertEqual(type((2, False)), type((tictactoe_tactic.next_move(field, 'x', 'o', '_', 2))))

    def test_next_move_difficulty_easy(self):
        field = [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']]

        self.assertEqual(type((2, False)), type((tictactoe_tactic.next_move(field, 'x', 'o', '_', 1))))

    def test_next_move_winning(self):
        field = [['x', 'x', '_'], ['o', 'o', '_'], ['_', '_', '_']]

        self.assertEqual((2, True), tictactoe_tactic.next_move(field, 'x', 'o', '_', 4))

    def test_next_move_defending(self):
        field = [['x', '_', '_'], ['o', 'o', '_'], ['_', 'x', '_']]

        self.assertEqual((5, False), tictactoe_tactic.next_move(field, 'x', 'o', '_', 4))

    def test_next_move_full(self):
        field = [['x', 'o', 'x'], ['o', 'o', 'x'], ['o', 'x', 'x']]

        self.assertIsNone(tictactoe_tactic.next_move(field, 'x', 'o', '_', 4))
