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

# Program body ---------------------------------------------------------------
train_n <- 200

ponds <- fread("data/2013_head.csv")

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

# Fit a GBM -------------------------------------------------------------------
storage.mode(train_x) <- "double"
storage.mode(train_y) <- "double"
storage.mode(test_x) <- "double"
storage.mode(test_y) <- "double"

train_dm <- xgb.DMatrix(train_x, label = train_y)
test_dm <- xgb.DMatrix(test_x, label = test_y)

xgb_params <- list(eta = 0.05,
                   max_depth = 3,
                   min_child_weight = 10,
                   subsample = 1,
                   colsample_bytree = 1,
                   num_class = 34)

xg_model <- xgb.train(params = xgb_params,
                      watchlist = list(train = train_dm, test = test_dm),
                      eval.metric = "mlogloss",
                      objective = "multi:softprob",
                      data = train_dm,
                      nrounds = 470)

xg_model <- xgb.cv(params = xgb_params,
                   objective = "multi:softprob",
                   eval_metric = "mlogloss",
                   data = train_dm,
                   nrounds = 1000,
                   nfold = 5)
