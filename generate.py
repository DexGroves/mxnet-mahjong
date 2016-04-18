import random
from code.hand import Hand
from code.mahjong_player import MahjongPlayer


tileset = ['1', '1', '1',
           '2', '2', '2',
           '3', '3', '3',
           '4', '4', '4',
           '5', '5', '5',
           '6', '6', '6',
           '7', '7', '7',
           '8', '8', '8',
           '9', '9', '9',
           'D', 'D', 'D',
           'E', 'E', 'E',
           'S', 'S', 'S']


def generate_wall(tileset):
    return random.sample(tileset, len(tileset))


player = MahjongPlayer()

discard_pile = []
wall = generate_wall(tileset)
hand = Hand(wall[0:5])
wall = wall[6:len(wall)]

if hand.is_complete():
    print 'Tsumo!'
    print ', '.join(hand)
else:
    discard, hand = player.make_discard(hand)
    discard_pile.append(discard)
    hand.append(wall.pop(0))
    print ', '.join(discard_pile)
