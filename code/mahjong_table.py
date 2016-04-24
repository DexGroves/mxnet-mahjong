import random
from code.hand import Hand
from code.tile import Tile


class MahjongTable(object):
    """Coordinates games of mahjong."""

    def __init__(self, mahjong_player, unique_tiles):
        self.hand_len = 14
        self.mahjong_player = mahjong_player
        self.tileset = self.generate_tileset(unique_tiles)

    def generate_pond(self, max_len):
        """
        Iterate through a game, asking mahjong_player to make new
        discards until max_len is reached or the hand is finished.
        Return the pond and winning tile.
        """

        discard_pile = []
        wall = self.generate_wall()
        hand = Hand(wall[0:self.hand_len])
        wall = wall[(self.hand_len+1):len(wall)]

        while len(discard_pile) < max_len:
            if hand.is_complete():
                return discard_pile, hand[len(hand) - 1]
            else:
                discard = self.mahjong_player.make_discard(hand)
                hand = Hand(hand.remove_tiles([discard]))
                discard_pile.append(discard)
                hand.append(wall.pop(0))

        return discard_pile, None

    def generate_wall(self):
        """Generate a fresh wall from self.tileset."""
        return random.sample(self.tileset, len(self.tileset))

    @staticmethod
    def generate_tileset(unique_tile_str):
        """
        Turn a list of tile strings to a list of four Tile objects.
        """
        unique_tiles = [Tile(x) for x in unique_tile_str]
        return unique_tiles + unique_tiles + unique_tiles + unique_tiles
