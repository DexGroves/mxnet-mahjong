#!/usr/bin/env python2.7

import random
from code.tile import Tile
from code.hand import Hand
from code.mahjong_player import MahjongPlayer


def generate_wall(tileset):
    return random.sample(tileset, len(tileset))


def generate_pond(player, max_len, tileset):
    discard_pile = []
    wall = generate_wall(tileset)
    hand = Hand(wall[0:5])
    wall = wall[6:len(wall)]

    while len(wall) > (len(tileset) - 4 - max_len):
        if hand.is_complete():
            return discard_pile, hand[len(hand) - 1]
        else:
            discard = player.make_discard(hand)
            hand = Hand(hand.remove_tiles([discard]))
            discard_pile.append(discard)
            hand.append(wall.pop(0))

    return discard_pile, None


def tiles_to_numeric_vector(tiles, max_len, tileset):
    """
    Convert a set of tiles to a list of numbers
    corresponding to their index in unique_tiles.
    """
    tile_indices = [tileset.index(x) for x in tiles]

    if len(tile_indices) > max_len:
        raise ValueError("Too many tiles!")
    else:
        remaining_len = max_len - len(tile_indices)
        tile_indices += ([-1] * remaining_len)

    return tile_indices


# Hyperparameters
n_trials = 30000
max_len = 18


tile_labels = ['s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9',
               'p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8', 'p9',
               'm1', 'm2', 'm3', 'm4', 'm5', 'm6', 'm7', 'm8', 'm9',
               'wE', 'wS', 'wW', 'wN',
               'dW', 'dG', 'dR']
unique_tiles = [Tile(x) for x in tile_labels]
tileset = unique_tiles + unique_tiles + unique_tiles

player = MahjongPlayer()

# Spam n_trials ponds and write to csv
f = open('data/ponds.csv', 'w')
for i in xrange(n_trials):
    pond, winning_tile = generate_pond(player, max_len, tileset)

    if winning_tile is not None and winning_tile not in pond:
        pond_ind = tiles_to_numeric_vector(
            pond, max_len, unique_tiles)
        winning_tile_ind = unique_tiles.index(winning_tile)

        out_vec = [0] * len(tile_labels)
        n = 1
        for tile in [x for x in pond_ind if x != -1]:
            if out_vec[tile] == 0:
                out_vec[tile] = n
            n += 1
        out_str = ','.join([str(winning_tile_ind),
                            ','.join([str(x) for x in out_vec])])

        f.write(out_str + '\n')
f.close()
