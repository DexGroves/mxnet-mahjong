from code.tile import Tile
from code.hand import Hand
from code.tile_evaluator import TileEvaluator


te = TileEvaluator()


def test_contains_pair():
    has_pair = Hand([Tile(x) for x in ['s1', 's1', 's3', 's4']])
    no_pair = Hand([Tile(x) for x in ['s1', 's2', 's3', 's4']])

    assert te.contains_pair(has_pair) is True
    assert te.contains_pair(no_pair) is False


def test_is_ryanmen():
    has_ryanmen = Hand([Tile(x) for x in ['s3', 's4']])
    no_ryanmen = Hand([Tile(x) for x in ['s1', 's2']])

    assert te.is_ryanmen(has_ryanmen) is True
    assert te.is_ryanmen(no_ryanmen) is False


def test_is_kanchan():
    has_kanchan = Hand([Tile(x) for x in ['s2', 's4']])
    no_kanchan = Hand([Tile(x) for x in ['s1', 's2']])

    assert te.is_kanchan(has_kanchan) is True
    assert te.is_kanchan(no_kanchan) is False


def test_is_penchan():
    has_penchan = Hand([Tile(x) for x in ['s1', 's2']])
    no_penchan = Hand([Tile(x) for x in ['s2', 's4']])

    assert te.is_penchan(has_penchan) is True
    assert te.is_penchan(no_penchan) is False


def test_is_pair():
    has_pair = Hand([Tile(x) for x in ['s1', 's1']])
    no_pair = Hand([Tile(x) for x in ['s2', 's4']])

    assert te.is_pair(has_pair) is True
    assert te.is_pair(no_pair) is False


def test_get_useless_tiles():
    test_hand = Hand([Tile(x) for x in ['s1', 's1', 's1', 's2', 's3', 's4',
                                        's5', 's7', 'dW', 'wE']])
    useless_tilesets = [sorted(x) for x in te.get_useless_tiles(test_hand)]

    assert ['dW', 's5', 's7', 'wE'] in useless_tilesets
    assert ['dW', 's2', 's7', 'wE'] in useless_tilesets
    assert ['dW', 's1', 's1', 's4', 's5', 's7', 'wE'] in useless_tilesets


def test_is_tenpai():
    tanki_tenpai = Hand([Tile(x) for x in ['s1']])
    ryanmen_tenpai = Hand([Tile(x) for x in ['s1', 's1', 's4', 's5']])
    noten_1 = Hand([Tile(x) for x in ['s1', 's1']])
    noten_2 = Hand([Tile(x) for x in ['s1', 's1', 's4', 'm5']])
    noten_3 = Hand([Tile(x) for x in ['s1', 'm1', 's4', 's5']])

    assert te.is_tenpai(tanki_tenpai) is True
    assert te.is_tenpai(ryanmen_tenpai) is True
    assert te.is_tenpai(noten_1) is False
    assert te.is_tenpai(noten_2) is False
    assert te.is_tenpai(noten_3) is False


def test_score_leftover_group():
    ryanmen_tenpai = Hand([Tile(x) for x in ['s1', 's1', 's4', 's5']])
    tanki_tenpai = Hand([Tile(x) for x in ['s1']])
    good_noten = Hand([Tile(x) for x in ['s1', 's4', 's4', 's5']])

    ryanmen_tenpai_score = te.score_leftover_group(ryanmen_tenpai)
    tanki_tenpai_score = te.score_leftover_group(tanki_tenpai)
    good_noten_score = te.score_leftover_group(good_noten)

    assert ryanmen_tenpai_score > tanki_tenpai_score > good_noten_score


def test_get_optimal_cut_from_leftovers():
    ryanmen_tenpai = Hand([Tile(x) for x in ['s1', 's1', 's4', 's5', 'wD']])
    tanki_tenpai = Hand([Tile(x) for x in ['s1', 'wD']])
    good_noten = Hand([Tile(x) for x in ['s1', 's4', 's4', 's5', 'wD']])

    tile, score = te.get_optimal_cut_from_group(ryanmen_tenpai)
    assert tile == 'wD'
    tile, score = te.get_optimal_cut_from_group(tanki_tenpai)
    assert tile == 'wD'
    tile, score = te.get_optimal_cut_from_group(good_noten)
    assert tile == 'wD'


def test_evaluate_optimal_cut():

    test_hand = Hand([Tile(x) for x in ['s1', 's1', 's1', 's2', 's3', 's4',
                                        's5', 's7', 'dW', 'wE']])
    cut = te.evaluate_optimal_cut(test_hand)

    assert cut in ['dW', 'wE']
