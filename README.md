# mxnet_mahjong
Experimental scripts to train an MLP to predict the winning tile from a set of mahjong discards. Grand master plan is to train on actual tenhou.net data. For now it fits on simulated data.

### What
`1-generate.py` generates a bunch of completed riichi mahjong hands, and outputs the pond and winning tile as a numeric vector. It does not output any hands which won on a tile in their pond.

`2*fit_mx*.R` fits an MLP to this data.

### Details
The mahjong mechanical turk moves predictably towards a completed hand and prefers multi-sided waits. It does not care about hand value.

Discards are encoded like this:
```
# 1s 2s 3s 4s ... Rd Wd Gd
   2  1  0  0     15  0  4
```

Where the value indicates the turn on which a tile was discarded and the column indicates what the tile actually was. This is transformed to be suit-agnostic so that the first 9 entries indicate the first discarded suit, entries 10-18 the second and so forth. 
