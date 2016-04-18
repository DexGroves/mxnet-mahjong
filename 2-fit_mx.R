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


mx.set.seed(0)
mx_model <- mx.mlp(train_x,
                   train_y,
                   num.round = 2000,
                   hidden_node = c(13),
                   activation = "relu",
                   out_activation = "softmax",
                   out_node = 12,
                   array.batch.size = 100,
                   learning.rate = 0.01,
                   momentum = 0.1,
                   array.layout = "rowmajor",
                   # initializer = mx.init.normal(1),
                   initializer=mx.init.uniform(0.07),
                   eval.metric = mx.metric.accuracy)


prediction_layer <- predict(mx_model, test_x)
prediction <- max.col(t(prediction_layer)) - 1
table(prediction)

prediction_layer_train <- predict(mx_model, train_x)
prediction_train <- max.col(t(prediction_layer_train)) - 1

accuracy(test_y, prediction)
accuracy(test_y, most_common(train_y))
accuracy(train_y, prediction_train)
accuracy(train_y, most_common(train_y))

# Dragons below ---------------------------------------------------------------
# data <- mx.symbol.Variable("data")
# fc1 <- mx.symbol.FullyConnected(data, name="fc1", num_hidden=128)
# act1 <- mx.symbol.Activation(fc1, name="relu1", act_type="relu")
# fc2 <- mx.symbol.FullyConnected(act1, name="fc2", num_hidden=64)
# act2 <- mx.symbol.Activation(fc2, name="relu2", act_type="relu")
# fc3 <- mx.symbol.FullyConnected(act2, name="fc3", num_hidden=10)
# softmax <- mx.symbol.SoftmaxOutput(fc3, name="sm")
# devices <- mx.cpu()

# mx.set.seed(0)
# model <- mx.model.FeedForward.create(softmax, X=train.x, y=train.y,
#                                      ctx=devices, num.round=10, array.batch.size=100,
#                                      learning.rate=0.07, momentum=0.9,  eval.metric=mx.metric.accuracy,
#                                      initializer=mx.init.uniform(0.07),
#                                      epoch.end.callback=mx.callback.log.train.metric(100))

# preds <- predict(model, test)
# dim(preds)

# pred.label <- max.col(t(preds)) - 1
# table(pred.label)
