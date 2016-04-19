import copy
import collections


class MahjongPlayer(object):
    """Handle logical deductions on hands for simple 12-tile mahjong."""

    def __init__(self):
        pass

    def make_discard(self, hand):
        c_hand = copy.copy(hand)

        unpaired = self.get_unpaired(c_hand)

        # One unpaired tile? Discard it! Shanpon waits are good (!)
        if len(unpaired) == 1:
            c_hand.remove(unpaired[0])
            return unpaired[0], c_hand

        # Particularly useless unpaired tiles? Discard!
        if 'wS' in unpaired:
            c_hand.remove('wS')
            return 'wS', c_hand
        if 'wE' in unpaired:
            c_hand.remove('wE')
            return 'wE', c_hand
        if 'dW' in unpaired:
            c_hand.remove('dW')
            return 'dW', c_hand

        # Else discard the lowest number. A laughable strategy.
        min_unpaired = sorted(unpaired)[0]
        c_hand.remove(str(min_unpaired))

        return str(min_unpaired), c_hand

    @staticmethod
    def get_unpaired(hand):
        """Return a hand's unpaired tiles."""
        tile_count = collections.Counter(hand).most_common()
        return [name for name, count in tile_count if count == 1]
