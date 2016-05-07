#!/usr/bin/env Rscript

library("data.table")
library("mxnet")
library("hacktoolkit") # devtools::install_github("DexGroves/hacktoolkit")


#" Find the most common element of a numeric vector
most_common <- function(y) {
  as.numeric(names(sort(table(y), decreasing = TRUE)))[1]
}

#" Predict the most common element of the train response, unless it
#" exists in the holdout row
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

# Program body ---------------------------------------------------------------
train_n <- 190000

ponds <- fread("data/all_ponds.csv")

y <- as.numeric(ponds$V1)
X <- data.matrix(ponds[, -"V1", with = FALSE])
X <- X[y %in% seq(0, 17), 1:18]
y <- y[y %in% seq(0, 17)]

train_y <- y[1:train_n]
train_x <- X[1:train_n, ]

test_y <- y[(train_n + 1):length(y)]
test_x <- X[(train_n + 1):length(y), ]

# Fit the net -----------------------------------------------------------------
mx.set.seed(0)
mx_model <- mx.mlp(
                   train_x,
                   train_y,
                   num.round = 500,
                   hidden_node = c(18),
                   activation = "tanh",
                   out_activation = "softmax",
                   out_node = 18,
                   array.batch.size = 120,
                   learning.rate = 0.1,
                   dropout = 0.1,
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
multivariate_auc(test_y, t(prediction_layer_test))

# Methods to score a pond -----------------------------------------------------
tileset <- c("s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9",
             "p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "p9")

tiles_to_vec <- function(pond_char) {
  pond_vec <- sapply(pond_char, function(x) which(x == tileset))
  pond_binary <- rep(0, 18)

  n <- 1
  for (tile in pond_vec) {
    if (pond_binary[tile] == 0) {
      pond_binary[tile] <- n
    }
    n <- n + 1
  }
  pond_binary <- t(pond_binary)
  names(pond_binary) <- tileset
  pond_binary
}

test_pond <- c("p8", "s8", "s5", "s6", "s6")
pond_vec <- tiles_to_vec(test_pond)

pred_dt <- predict(mx_model, t(pond_vec)) %>%
  {data.table(tile = names(pond_vec), prob = round(., 3))}

pred_dt[order(prob.V1)]

# xgboost to do the same ------------------------------------------------------
library("xgboost")

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
                   num_class = 18)

xg_model <- xgb.train(params = xgb_params,
                      watchlist = list(train = train_dm, test = test_dm),
                      eval.metric = "mlogloss",
                      objective = "multi:softprob",
                      data = train_dm,
                      nrounds = 470)
#  [2000] 2.416633  depth 1
#  [814]  2.412762  depth 2
#  [472]  2.411656  depth 3

xg_model <- xgb.cv(params = xgb_params,
                   objective = "multi:softprob",
                   eval_metric = "mlogloss",
                   data = train_dm,
                   nrounds = 1000,
                   nfold = 5)

test_pred_xgb <- predict(xg_model, newdata = test_dm)
xgboost_perf(xg_model)

multivariate_auc(test_y, t(matrix(test_pred_xgb, nrow = 18)), n_classes = 18)

pond_vec <- tiles_to_vec(c("s5"))
pred_dt <- predict(xg_model, pond_vec) %>%
  {data.table(tile = names(pond_vec), prob = round(., 3))}

pred_dt[order(prob)]

multivariate_auc(test_y, t(matrix(test_pred_xgb, nrow = 18)))
