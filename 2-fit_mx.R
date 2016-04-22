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

reorder_Xsuits_row <- function(x) {
  s1 <- x[1:9]
  s2 <- x[10:18]

  s1[s1 == 0] <- +Inf
  s2[s2 == 0] <- +Inf

  map <- seq(27)

  suit_first_appeared <- c(min(s1), min(s2))
  order_appeared <- order(suit_first_appeared)

  map[1:27] <- rbind(seq(1, 9), seq(10, 18)) %>%
    {.[order_appeared, ]} %>%
    t %>%
    as.numeric

  x[map]
}

reorder_ysuits_row <- function(X, y) {
  s1 <- X[1:9]
  s2 <- X[10:18]

  s1[s1 == 0] <- +Inf
  s2[s2 == 0] <- +Inf

  map <- seq(27)

  suit_first_appeared <- c(min(s1), min(s2))
  order_appeared <- order(suit_first_appeared)

  map[1:27] <- rbind(seq(1, 9), seq(10, 18)) %>%
    {.[order_appeared, ]} %>%
    t %>%
    as.numeric

  which(map == y) - 1
}

# Program body ---------------------------------------------------------------
train_n <- 500000

ponds <- fread("data/ponds.csv")

y <- as.numeric(ponds$V1)
X <- data.matrix(ponds[, -"V1", with = FALSE])
X <- X[, 1:18]
X <- X[y %in% seq(0, 18), ]
y <- y[y %in% seq(0, 18)]

Xreorder <- t(apply(X, 1, reorder_Xsuits_row))
yreorder <- unlist(sapply(seq_along(y),
                          function(i) reorder_ysuits_row(X[i, ], y[i])))

train_y <- yreorder[1:train_n]
train_x <- Xreorder[1:train_n, ]

test_y <- yreorder[(train_n + 1):length(yreorder)]
test_x <- Xreorder[(train_n + 1):length(yreorder), ]

# Fit the net -----------------------------------------------------------------
mx.set.seed(0)
mx_model <- mx.mlp(device = mx.gpu(1),
                   train_x,
                   train_y,
                   num.round = 200,
                   hidden_node = c(27),
                   activation = "tanh",
                   out_activation = "softmax",
                   out_node = 18,
                   array.batch.size = 100,
                   learning.rate = 0.4,
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
multivariate_auc(test_y, prediction_layer_test)
# 0.6262689 tanh, 200, c(6), 0.4/0.1, 100
# 0.6348107 ^ with reordering

# Methods to score a pond -----------------------------------------------------
tileset <- c("s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9",
             "p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "p9",
             "m1", "m9",
             "wE", "wS", "wW", "wN",
             "dW", "dG", "dR")

tiles_to_vec <- function(pond_char) {
  pond_vec <- sapply(pond_char, function(x) which(x == tileset))
  pond_binary <- rep(0, 26)

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

test_pond <- c("wS", "dR", "s6", "p8", "p9", "m1", "p4", "p4")
test_pond <- c("s6", "m9", "p9", "m1", "m1", "p4")

pond_vec <- tiles_to_vec(test_pond)
pond_vec_reorder <- reorder_Xsuits_row(pond_vec)

pred_dt <- predict(mx_model, t(pond_vec_reorder)) %>%
  {data.table(tile = names(pond_vec_reorder), prob = round(., 3))}

pred_dt[order(prob.V1)]

