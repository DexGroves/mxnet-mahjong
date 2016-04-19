import collections
import numpy as np
from code.tile import Tiles


class Hand(Tiles):
    """A mahjong hand."""

    def is_complete(self):
        """
        Recurse over self, removing possible sets, and test if any
        of the paths end in a pair.
        """

        if self.is_pair():
            return True

        for possible_set in self.get_possible_sets():
            remaining_hand = Hand(self.remove_tiles(possible_set))
            if remaining_hand.is_complete():
                return True

        return False

    def get_possible_sets(self):
        return self.get_possible_ankou() + self.get_possible_jun()

    def get_possible_ankou(self):
        tile_counter = collections.Counter(self).most_common()
        return [[t]*3 for t, count in tile_counter if count > 2]

    def get_possible_jun(self):
        num_tiles = Tiles(set([t for t in self if t.is_number_tile()]))

        output_jun = []
        for i in xrange(len(num_tiles) - 2):
            possible_jun = Tiles(num_tiles[i:(i+3)])
            if possible_jun.is_jun():
                output_jun += [possible_jun]

        return output_jun
