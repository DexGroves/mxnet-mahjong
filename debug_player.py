#!/usr/bin/env python2.7

import random
from code.tile import Tile
from code.hand import Hand
from code.mahjong_player import MahjongPlayer


UNICODE_TILES = """
 🀐 🀑 🀒 🀓 🀔 🀕 🀖 🀗 🀘
 🀙 🀚 🀛 🀜 🀝 🀞 🀟 🀠 🀡
 🀇 🀈 🀉 🀊 🀋 🀌 🀍 🀎 🀏
 🀀 🀁 🀂 🀃
 🀆 🀅 🀄
 """.split()


def generate_wall(tileset):
    return random.sample(tileset, len(tileset))


def to_unicode(tile):
    return UNICODE_TILES[tile_labels.index(tile)]

def play_hand(hand, wall):
    print ' '.join([to_unicode(x) for x in sorted(hand[0:13]) + [hand[13]]])
    discard = player.make_discard(hand)
    hand = Hand(hand.remove_tiles([discard]))
    discard_pile.append(discard)
    hand.append(wall.pop(0))
    print to_unicode(discard)
    return hand, wall


tile_labels = ['s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9',
               'p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8', 'p9',
               'm1', 'm2', 'm3', 'm4', 'm5', 'm6', 'm7', 'm8', 'm9',
               'wE', 'wS', 'wW', 'wN',
               'dW', 'dG', 'dR']
unique_tiles = [Tile(x) for x in tile_labels]
tileset = unique_tiles + unique_tiles + unique_tiles


discard_pile = []
wall = generate_wall(tileset)
hand = Hand(wall[0:14])
wall = wall[15:len(wall)]
player = MahjongPlayer()

hand, wall = play_hand(hand, wall)
