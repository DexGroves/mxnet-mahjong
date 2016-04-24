#!/usr/bin/env python2.7

import random
from code.tile import Tile
from code.hand import Hand
from code.mahjong_player import MahjongPlayer
from code.mahjong_table import MahjongTable


def format_output(pond, max_len, tile_labels):
    """Reformat ponds for stronger affinity to modelling."""
    pond_ind = tiles_to_numeric_vector(
                pond, max_len, tile_labels)
    winning_tile_ind = tile_labels.index(winning_tile)

    out_vec = [0] * len(tile_labels)
    n = 1
    for tile in [x for x in pond_ind if x != -1]:
        if out_vec[tile] == 0:
            out_vec[tile] = n
        n += 1
    out_str = ','.join([str(winning_tile_ind),
                        ','.join([str(x) for x in out_vec])])

    return out_str


def tiles_to_numeric_vector(tiles, max_len, tile_labels):
    """
    Convert a set of tiles to a list of numbers
    corresponding to their index in tile_labels.
    """
    tile_indices = [tile_labels.index(x) for x in tiles]

    if len(tile_indices) > max_len:
        raise ValueError("Too many tiles!")
    else:
        remaining_len = max_len - len(tile_indices)
        tile_indices += ([-1] * remaining_len)

    return tile_indices


# Hyperparameters
n_trials = 300
max_len = 18

tile_labels = ['s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9',
               'p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8', 'p9',
               'm1', 'm9',
               'wE', 'wS', 'wW', 'wN',
               'dW', 'dG', 'dR']

player = MahjongPlayer()
table = MahjongTable(player, tile_labels)


# Spam n_trials ponds and write to csv
f = open('data/ponds.csv', 'a')
for i in xrange(n_trials):
    if i % 10 == 0:
        print i

    pond, winning_tile = table.generate_pond(max_len)

    if winning_tile is not None and winning_tile not in pond:
        out_str = format_output(pond, max_len, tile_labels)
        f.write(out_str + '\n')

f.close()

