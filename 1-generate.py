#!/bin/env python2.7

import random
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
            discard, hand = player.make_discard(hand)
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
max_len = 10


unique_tiles = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'D', 'E', 'S']
tileset = unique_tiles + unique_tiles + unique_tiles

player = MahjongPlayer()

# Spam n_trials ponds and write to csv
f = open('data/ponds.csv', 'w')
for i in xrange(n_trials):
    pond, winning_tile = generate_pond(player, max_len, tileset)

    if winning_tile is not None and winning_tile not in pond:
        pond_ind = tiles_to_numeric_vector(pond, max_len, unique_tiles)
        winning_tile_ind = tiles_to_numeric_vector(
            winning_tile, 1, unique_tiles)

        out_str = ','.join([str(winning_tile_ind[0]),
                           ','.join([str(x) for x in pond_ind])])

        f.write(out_str + '\n')
f.close()
