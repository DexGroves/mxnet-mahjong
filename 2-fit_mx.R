#!/usr/bin/env Rscript

library("data.table")
library("mxnet")
library("hacktoolkit") # devtools::install_github("DexGroves/hacktoolkit")


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

reorder_Xsuits_row <- function(x) {
  s1 <- x[1:9]
  s2 <- x[10:18]
  s3 <- x[19:27]

  s1[s1 == 0] <- +Inf
  s2[s2 == 0] <- +Inf
  s3[s3 == 0] <- +Inf

  map <- seq(34)

  suit_first_appeared <- c(min(s1), min(s2), min(s3))
  order_appeared <- order(suit_first_appeared)

  map[1:27] <- rbind(seq(1, 9), seq(10, 18), seq(19, 27)) %>%
    {.[order_appeared, ]} %>%
    t %>%
    as.numeric

  x[map]
}

reorder_ysuits_row <- function(X, y) {
  s1 <- X[1:9]
  s2 <- X[10:18]
  s3 <- X[19:27]

  s1[s1 == 0] <- +Inf
  s2[s2 == 0] <- +Inf
  s3[s3 == 0] <- +Inf

  map <- seq(34)

  suit_first_appeared <- c(min(s1), min(s2), min(s3))
  order_appeared <- order(suit_first_appeared)

  map[1:27] <- rbind(seq(1, 9), seq(10, 18), seq(19, 27)) %>%
    {.[order_appeared, ]} %>%
    t %>%
    as.numeric

  which(map == y)
}

# Program body ---------------------------------------------------------------
train_n <- 2000

ponds <- fread("data/ponds.csv")

y <- as.numeric(ponds$V1)
X <- data.matrix(ponds[, -"V1", with = FALSE])

Xreorder <- t(apply(X, 1, reorder_Xsuits_row))
yreorder <- unlist(sapply(seq_along(y),
                          function(i) reorder_ysuits_row(X[i, ], y[i])))

# Xreorder <- X
# yreorder <- y
#
train_y <- yreorder[1:train_n]
train_x <- Xreorder[1:train_n, ]

test_y <- yreorder[(train_n + 1):length(yreorder)]
test_x <- Xreorder[(train_n + 1):length(yreorder), ]

storage.mode(train_x) <- "double"
storage.mode(train_y) <- "double"
storage.mode(test_x) <- "double"
storage.mode(test_y) <- "double"

# Fit the net -----------------------------------------------------------------
mx.set.seed(0)
mx_model <- mx.mlp(train_x,
                   train_y,
                   num.round = 500,
                   hidden_node = c(6, 6),
                   activation = "tanh",
                   out_activation = "softmax",
                   out_node = 34,
                   array.batch.size = 50,
                   learning.rate = 0.05,
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

accuracy(test_y, prediction_test)
accuracy(test_y, most_common(train_y))
accuracy(test_y, common_unless_furiten(test_x, train_y))

mv_binomial_deviance(test_y, prediction_layer_test)
multivariate_auc(test_y, prediction_layer_test)
# 0.6262689 tanh, 200, c(6), 0.4/0.1, 100
# 0.6348107 ^ with reordering

# xgboost to do the same ------------------------------------------------------
library("xgboost")

train_dm <- xgb.DMatrix(train_x, label = train_y)
test_dm <- xgb.DMatrix(test_x, label = test_y)

xg_model <- xgb.train(params = list(eta = 0.01,
                                    max_depth = 3,
                                    min_child_weight = 5,
                                    subsample = 0.75,
                                    colsample_bytree = 0.75,
                                    num_class = 34),
                      objective = "multi:softmax",
                      data = train_dm,
                      nrounds = 100)

test_pred_xgb <- predict(xg_model, newdata = test_dm)
accuracy(test_y, test_pred_xgb)
