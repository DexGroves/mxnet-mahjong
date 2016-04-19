from code.tile import Tile
from code.hand import Hand
from code.mahjong_player import MahjongPlayer


def test_make_discard():
    mp = MahjongPlayer()
    test_hand = Hand([Tile(x) for x in ['s1', 's1', 's1', 's2', 's3', 's4',
                                        's5', 's5', 's7', 'dW', 'wE']])
    assert mp.make_discard(test_hand) in test_hand
