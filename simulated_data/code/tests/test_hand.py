from code.tile import Tile
from code.hand import Hand


chi_pair = Hand([Tile(x) for x in ['s1', 's2', 's3', 'wD', 'wD']])
pon_pair = Hand([Tile(x) for x in ['s1', 's1', 's1', 'wD', 'wD']])

big_mess_pass = Hand([Tile(x) for x in ['s1', 's1', 's1', 's2', 's3',
                                        's3', 's3', 's4']])
big_mess_fail = Hand([Tile(x) for x in ['s1', 's1', 's1', 's2', 's3',
                                        's3', 's3', 's5']])


def test_is_complete_easy():
    """Hand completion boolean method correct for easy cases."""
    assert chi_pair.is_complete() == True
    assert pon_pair.is_complete() == True


def test_is_complete_hard():
    """Hand completion boolean method correct for bigger hands."""
    assert big_mess_pass.is_complete() == True
    assert big_mess_fail.is_complete() == False

