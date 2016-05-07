import collections
from code.tile_evaluator import TileEvaluator


class MahjongPlayer(object):
    """Handle logical deductions on hands for simple 12-tile mahjong."""

    def __init__(self):
        self.evaluator = TileEvaluator()

    def make_discard(self, hand):
        return self.evaluator.evaluate_optimal_cut(hand)

    @staticmethod
    def get_unpaired(hand):
        """Return a hand's unpaired tiles."""
        tile_count = collections.Counter(hand).most_common()
        return [name for name, count in tile_count if count == 1]
