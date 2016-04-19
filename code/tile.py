class Tile(str):
    """Hold tile information."""

    def get_rank(self):
        if self[0] in ['1', '2', '3', '4', '5', '6', '7', '8', '9']:
            return int(self[0])
        return -1

    def get_suit(self):
        return self[1]

    def is_number_tile(self):
        if self.get_rank() == -1:
            return False
        return True
