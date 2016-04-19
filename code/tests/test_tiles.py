from code.tile import Tile, Tiles


sou_1 = Tile('s1')
sou_2 = Tile('s2')
sou_3 = Tile('s3')
haku  = Tile('dW')


def test_is_jun():
    a_jun = Tiles([sou_1, sou_2, sou_3])
    not_a_jun = Tiles([sou_1, sou_3, haku])

    assert a_jun.is_jun() == True
    assert not_a_jun.is_jun() == False


def test_is_pair():
    a_pair = Tiles([sou_1, sou_1])
    not_a_pair = Tiles([sou_1, sou_2])

    assert a_pair.is_pair() == True
    assert not_a_pair.is_pair() == False
