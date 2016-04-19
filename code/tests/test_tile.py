from code.tile import Tile


def test_tile_methods():
    """Tile ID methods behaving."""
    five_sou = Tile('s5')
    haku = Tile('wD')

    assert five_sou.suit() == "s"
    assert five_sou.rank() == 5
    assert five_sou.is_number_tile() == True

    assert haku.suit() == "w"
    assert haku.rank() == -1
    assert haku.is_number_tile() == False

