#!/bin/env Rscript

library("data.table")
library("mxnet")


accuracy <- function(y, u) {
  sum(y == u) / length(y)
}

most_common <- function(y) {
  as.numeric(names(sort(table(y), decreasing = TRUE)))[1]
}

train_n <- 5000

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
                   num.round = 1000,
                   hidden_node = c(13, 6),
                   activation = "relu",
                   out_activation = "softmax",
                   out_node = 12,
                   array.batch.size = 60,
                   learning.rate = 0.02,
                   momentum = 0.1,
                   array.layout = "rowmajor",
                   # initializer = mx.init.normal(1),
                   initializer=mx.init.uniform(0.1),
                   eval.metric = mx.metric.accuracy)

# Evaluate how bad it is ------------------------------------------------------
prediction_layer_test <- predict(mx_model, test_x)
prediction_test <- max.col(t(prediction_layer_test)) - 1
table(prediction_test)

prediction_layer_train <- predict(mx_model, train_x)
prediction_train <- max.col(t(prediction_layer_train)) - 1

accuracy(test_y, prediction_test)
accuracy(test_y, most_common(train_y))
accuracy(train_y, prediction_train)
accuracy(train_y, most_common(train_y))

# xgboost thrashes it ---------------------------------------------------------
library("xgboost")

train_dm <- xgb.DMatrix(train_x, label = train_y)
test_dm <- xgb.DMatrix(test_x, label = test_y)

xg_model <- xgb.train(params = list(eta = 0.1,
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
