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
