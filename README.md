# mxnet_mahjong
Experimental scripts to train an MLP to predict the winning tile from a set of mahjong discards. 

`simulated_data` contains a mini implementation for simulated data that works alright. Currently working on fitting to 2013's data using with data sourced from arcturus.su and DexGroves/tenhou_parse.

## State of this project
  - It works on tenhou data
  - It beats a GBM
  - I need to write a suite to sanity check the predictions it makes against known ponds 
