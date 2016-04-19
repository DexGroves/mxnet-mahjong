import collections


class Hand(list):
    """Mahjong hand logic."""

    def is_complete(self):
        """Return True if a hand is complete."""
        # Check if the hand is 3, 2 or 2, 1, 1, 1 or 3, 1, 1
        # Can't be complete if not any of these combinations
        count_trace = self.get_count_trace()
        if count_trace == [3, 2]:
            return True

        if count_trace in [[2, 1, 1, 1], [3, 1, 1]]:
            alleged_set = self.remove_pair(self)
            if self.is_sequence(alleged_set):
                return True

        return False

    def get_count_trace(self):
        """Return a list of sorted counts for tiles in hand."""
        return [counts for _, counts in
                collections.Counter(self).most_common()]

    def get_unpaired(self):
        """Return a hand's unpaired tiles."""
        tile_count = collections.Counter(self).most_common()
        return [name for name, count in tile_count if count == 1]

    @staticmethod
    def is_sequence(tiles):
        numbers = [x.get_rank() for x in tiles if x.is_number_tile()]

        if len(numbers) != 3:
            return False
        if max(numbers)-min(numbers) == 2 and len(set(numbers)) == 3:
            return True

        return False

    @staticmethod
    def remove_pair(hand):
        """Remove the first available pair from a hand."""
        shand = sorted(hand)
        last_tile = '-1'

        for tile in shand:
            if tile == last_tile:
                shand.remove(tile)
                shand.remove(tile)
                return shand
            else:
                last_tile = tile

        raise ValueError("No pair found!")
