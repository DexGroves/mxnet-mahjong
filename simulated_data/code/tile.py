class Tile(str):
    """Hold tile information."""

    def rank(self):
        if self[1] in ['1', '2', '3', '4', '5', '6', '7', '8', '9']:
            return int(self[1])
        return -1

    def suit(self):
        return self[0]

    def is_number_tile(self):
        if self.rank() == -1:
            return False
        return True


class Tiles(list):
    """A collection of tiles."""

    def is_pair(self):
        if len(self) == 2 and len(set(self)) == 1:
            return True
        return False

    def is_jun(self):
        nbr_tiles = set([t for t in self if t.rank() != -1])
        suits = set([tile.suit() for tile in self])
        ranks = set([tile.rank() for tile in self])

        if len(self) != 3:
            return False

        if len(suits) != 1 or suits == {'w'} or suits == {'d'}:
            return False

        if len(ranks) != 3:
            return False

        if max(ranks) - min(ranks) == 2:
            return True

        return False

    def remove_tiles(self, tiles):
        return [t for t in self if not t in tiles or tiles.remove(t)]
