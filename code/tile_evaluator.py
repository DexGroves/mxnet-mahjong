import collections
from code.hand import Hand
from code.tile import Tiles


class TileEvaluator(object):
    """Score the usefulness of each tile for consumption by MahjongPlayer."""

    def __init__(self):
        pass

    def get_useless_tiles(self, hand):
        """
        Get all possible sets of leftover tiles by recursively
        removing sets.
        """
        possible_melds = hand.get_possible_sets()

        if len(possible_melds) == 0:
            return hand

        leftover_sets = []
        for meld in possible_melds:
            remaining_hand = Hand(hand.remove_tiles(meld))
            leftover_sets += [(self.get_useless_tiles(remaining_hand))]
            leftover_sets = [self.unlist(x) for x in leftover_sets]
        return leftover_sets

    def score_tiles_in_leftovers(self, leftovers):
        """
        Score the value add of removing each tile in a set of leftovers.
        """
        tilescores = []
        for tile in leftovers:
            score = self.score_leftover_group(
                sorted(leftovers.remove_tiles([tile])))
            tilescores += tile, score
        return tilescores

    def score_leftover_group(self, leftovers):
        """
        Score the absolute usefulness of a set of leftover tiles.
        Usefulness is encoded as an integer with successively
        decreasing orders of magnitude for less useful properties.
        """

        score = -1e8

        # The most important thing is being able to win
        if self.is_tenpai(leftovers):
            score += 1e7

        # # Having at least one pair is preferable above all else
        # if self.contains_pair(leftovers):
        #     score += 1e6

        # Having ryanmen waits is fantastic
        score += 1e5 * self.count_matches(leftovers, self.is_ryanmen)

        # But we'll take kanchan if we can't get better
        score += 1e4 * self.count_matches(leftovers, self.is_kanchan)

        # Pairs if we have to
        score += 1e3 * self.count_matches(leftovers, self.is_pair)

        # And penchan in a bind
        score += 1e2 * self.count_matches(leftovers, self.is_penchan)

        # Number tiles are more valuable. Especially those closer to 5
        ranks = [t.rank() for t in leftovers if t.rank() != -1]
        for tile in ranks:
            score += abs(5 - tile)

        return score

    def is_tenpai(self, hand):
        if len(hand) not in [1, 4]:
            return False

        if len(hand) == 1 or len(set(hand)) == 2:
            return True

        if not self.contains_pair(hand):
            return False

        unpaired = [t for t, c in collections.Counter(hand).most_common()
                    if c == 1]
        unpaired.sort()

        if len(set([t.suit() for t in unpaired])) > 1:
            return False

        if self.is_ryanmen(unpaired) or \
                self.is_penchan(unpaired) or \
                self.is_kanchan(unpaired):
            return True

        return False

    @staticmethod
    def contains_pair(hand):
        if len(hand) < 2:
            return False

        counts = [c for t, c in collections.Counter(hand).most_common()]
        if max(counts) >= 2:
            return True

        return False

    @staticmethod
    def count_matches(hand, match_fn):
        """
        Count through sorted tiles two at a time and evaluate
        match_fn. Return the number of True results.
        """
        successes = 0
        for i in xrange(len(hand) - 1):
            tile_pair = Tiles(hand[i:(i+2)])
            if match_fn(tile_pair):
                successes += 1
        return successes

    @staticmethod
    def is_ryanmen(tile_pair):
        suits = [tile.suit() for tile in tile_pair]
        ranks = [tile.rank() for tile in tile_pair]

        if suits[0] == suits[1] and suits[0] and \
                ranks in [[2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8]]:
            return True
        return False

    @staticmethod
    def is_kanchan(tile_pair):
        suits = [tile.suit() for tile in tile_pair]
        ranks = [tile.rank() for tile in tile_pair]

        if suits[0] == suits[1] and suits[0] and \
                ranks in [[1, 3], [2, 4], [3, 5], [4, 6],
                          [5, 7], [6, 8], [7, 9]]:
            return True
        return False

    @staticmethod
    def is_penchan(tile_pair):
        suits = [tile.suit() for tile in tile_pair]
        ranks = [tile.rank() for tile in tile_pair]

        if suits[0] == suits[1] and suits[0] and \
                ranks in [[1, 2], [8, 9]]:
            return True
        return False

    @staticmethod
    def is_pair(tile_pair):
        if tile_pair[0] == tile_pair[1]:
            return True
        return False

    @staticmethod
    def unlist(l):
        if type(l) == list:
            return l[0]
        return l

    # @staticmethod
    # def which_in_set(hand, set_fn):
    #     """
    #     Returns boolean vector of whether a tile is returned by set_fn.
    #     """
    #     set_inclusion = np.zeros(len(hand))
    #     for possible_set in set_fn(hand):
    #         set_inclusion = np.vstack([
    #             set_inclusion,
    #             np.array([1 if t in possible_set else 0 for t in hand])
    #         ])

    #     return sum(sum(set_inclusion))

    # @staticmethod
    # def get_possible_ryanmen(hand):
    #     tanyao_tiles = [t for t in hand if t.rank() > 1 and t.rank() < 9]
    #     hand_sort = sorted(hand)

    #     ryanmen_tiles = []
    #     for i in xrange(len(hand_sort) - 1):
    #         tile_pair = Tiles(hand_sort[i:(i+2)])
    #         if tile_pair.is_ryanmen():
    #             ryanmen_tiles += tile_pair

    #     return [1 if t in ryanmen_tiles else 0 for t in hand]

    # @staticmethod
    # def get_possible_ryanmen(hand):
    #     tanyao_tiles = [t for t in hand if t.rank() > 1 and t.rank() < 9]
    #     hand_sort = sorted(hand)

    #     ryanmen_tiles = []
    #     for i in xrange(len(hand_sort) - 1):
    #         tile_pair = Tiles(hand_sort[i:(i+2)])
    #         if tile_pair.is_ryanmen():
    #             ryanmen_tiles += tile_pair

    #     return [1 if t in ryanmen_tiles else 0 for t in hand]

    # @staticmethod
    # def get_possible_penchan(hand):
    #     tanyao_tiles = [t for t in hand if t.rank() > 1 and t.rank() < 9]
    #     hand_sort = sorted(hand)

    #     ryanmen_tiles = []
    #     for i in xrange(len(hand_sort) - 1):
    #         tile_pair = Tiles(hand_sort[i:(i+2)])
    #         if tile_pair.is_ryanmen():
    #             ryanmen_tiles += tile_pair

    #     return [1 if t in ryanmen_tiles else 0 for t in hand]
