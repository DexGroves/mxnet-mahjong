#!/usr/bin/env Rscript

#' Fit a GBM to predict winning tile of real tenhou houou games from 2013.
#' Scripts to grab data live here: github.com/DexGroves/tenhou_parse


library("data.table")
library("mxnet")
library("xgboost")
library("hacktoolkit") # devtools::install_github("DexGroves/hacktoolkit")

#" Find the most common element of a numeric vector
most_common <- function(y) {
  as.numeric(names(sort(table(y), decreasing = TRUE)))[1]
}

#' Convert value = tile, index = chronology to value = chronology, index = tile
#' Convert 7, 1, 2, 3 -> 2, 3, 4, 0, 0, 0, 1
pond_to_first_appearance <- function(pond) {
  row_to_first_appearance <- function(row) {
    out <- rep(-1, 34)
    for (tile_i in seq_along(row)) {
      if (row[tile_i] == -1) {
        next
      }

      if (out[row[tile_i] + 1] == -1) {
        out[row[tile_i] + 1] <- tile_i
      }
    }
    out
  }
  apply(pond, 1, row_to_first_appearance)
}

# Matrixify -------------------------------------------------------------------
train_n <- 300000

ponds <- fread("data/2013.csv")

y <- as.numeric(ponds$V1)
X_pond <- data.matrix(ponds[, colnames(ponds)[2:19], with = FALSE])
X_tiles <- data.matrix(ponds[, colnames(ponds)[20:53], with = FALSE])

X_pond_remix <- t(pond_to_first_appearance(X_pond))
colnames(X_tiles) <- NULL
X <- cbind(X_pond_remix, X_tiles)

train_y <- y[1:train_n]
train_x <- X[1:train_n, ]

test_y <- y[(train_n + 1):length(y)]
test_x <- X[(train_n + 1):length(y), ]

# Fit the net -----------------------------------------------------------------
mx.set.seed(0)
mx_model <- mx.mlp(device = mx.gpu(7),
                   train_x,
                   train_y,
                   num.round = 500,
                   hidden_node = c(34, 34, 34),
                   activation = "tanh",
                   out_activation = "softmax",
                   out_node = 34,
                   array.batch.size = 120,
                   learning.rate = 0.1,
                   dropout = 0.1,
                   momentum = 0.1,
                   array.layout = "rowmajor",
                   initializer = mx.init.uniform(0.05),
                   eval.metric = mx.metric.accuracy)
