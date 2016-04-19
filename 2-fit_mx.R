#!/bin/env Rscript

library("data.table")
library("mxnet")


accuracy <- function(y, u) {
  sum(y == u) / length(y)
}

mv_binomial_deviance <- function(y, U, n_classes = length(unique(y)),
                                 cap = TRUE) {
  binomial_deviance <- function(y, u, w = rep(1, length(y))){
    l <- sum(w[y == 1] * y[y == 1] * log(y[y == 1] / u[y == 1])) +
         sum(w[y == 0] * log(1/(1 - u[y == 0])))
    2 * l
  }

  if (cap) {
    U[U < 0.001] <- 0.001
    U[U > 0.999] <- 0.999

  }

  deviances <- sapply(
    1:n_classes, function(n) binomial_deviance(as.numeric(y == n), U[n, ]))
  sum(deviances)
}

#' Find the most common element of a numeric vector
most_common <- function(y) {
  as.numeric(names(sort(table(y), decreasing = TRUE)))[1]
}

#' Predict the most common element of the train response, unless it
#' exists in the holdout row
common_unless_furiten <- function(holdout_matrix, train_y) {
  common_unless_furiten_row <- function(row, train_common) {
    populated <- which(row != 0)
    remaining_this_row <- train_common[!train_common %in% populated]
    remaining_this_row[1]
  }

  train_common <- as.numeric(names(sort(table(train_y), decreasing = TRUE)))
  apply(holdout_matrix, 1, common_unless_furiten_row,
        train_common = train_common)
}

train_n <- 4000

ponds <- fread("data/ponds.csv")

winning_tiles <- as.numeric(ponds$V1)
discards <- data.matrix(ponds[, -"V1", with = FALSE])

train_y <- winning_tiles[1:train_n]
train_x <- discards[1:train_n, ]

test_y <- winning_tiles[(train_n + 1):length(winning_tiles)]
test_x <- discards[(train_n + 1):length(winning_tiles), ]

storage.mode(train_x) <- "double"
storage.mode(train_y) <- "double"
storage.mode(test_x) <- "double"
storage.mode(test_y) <- "double"

# Fit the net -----------------------------------------------------------------
mx.set.seed(0)
mx_model <- mx.mlp(train_x,
                   train_y,
                   num.round = 250,
                   hidden_node = c(34, 34),
                   activation = "relu",
                   out_activation = "softmax",
                   out_node = 34,
                   array.batch.size = 100,
                   learning.rate = 0.5,
                   momentum = 0.1,
                   array.layout = "rowmajor",
                   initializer = mx.init.uniform(0.05),
                   # initializer = mx.init.normal(1),
                   eval.metric = mx.metric.accuracy)

# Evaluate how bad it is ------------------------------------------------------
prediction_layer_test <- predict(mx_model, test_x)
prediction_test <- max.col(t(prediction_layer_test)) - 1
table(prediction_test)

prediction_layer_train <- predict(mx_model, train_x)
prediction_train <- max.col(t(prediction_layer_train)) - 1

accuracy(train_y, prediction_train)
accuracy(train_y, most_common(train_y))
accuracy(train_y, common_unless_furiten(train_x, train_y))
accuracy(test_y, prediction_test)
accuracy(test_y, most_common(train_y))
accuracy(test_y, common_unless_furiten(test_x, train_y))

mv_binomial_deviance(test_y, prediction_layer_test)

# xgboost to do the same ------------------------------------------------------
library("xgboost")

train_dm <- xgb.DMatrix(train_x, label = train_y)
test_dm <- xgb.DMatrix(test_x, label = test_y)

xg_model <- xgb.train(params = list(eta = 0.01,
                                    max_depth = 3,
                                    min_child_weight = 5,
                                    subsample = 0.75,
                                    colsample_bytree = 0.75,
                                    num_class = 12),
                      objective = "multi:softmax",
                      data = train_dm,
                      nrounds = 100)

test_pred_xgb <- predict(xg_model, newdata = test_dm)
accuracy(test_y, test_pred_xgb)

# Always 6:          0.1996301
# Furiten heuristic: 0.2021912
# PB mxnet:          0.2243882
# PB xgboost:        0.2239613
