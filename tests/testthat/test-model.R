library(numDeriv)

set.seed(1337)

n <- 500
x1 <- runif(n)
x2 <- runif(n)
x3 <- runif(n)
y <- rnorm(n, x1 + x3, exp(-3 + x2 + x3))

model <- LocationScaleRegression$new(y ~ x1 + x3, ~ x2 + x3)

f <- function(x) {
  model <- model$clone()
  model$parameters$beta <- x[seq_along(model$parameters$beta)]
  model$parameters$gamma <- x[-seq_along(model$parameters$beta)]
  model$loglik()
}

test_that("gradient works", {
  expect_equivalent(unlist(model$grad()), grad(f, unlist(model$parameters)))
})
