#' R6 class for location-scale regression models
#'
#' This model class assumes a normally distributed response variable with one
#' linear predictor for the mean and one for the standard deviation. The linear
#' predictors for the mean and the standard deviation are called \eqn{X\beta}
#' and \eqn{Z\gamma} respectively. The standard deviation uses a log link.
#'
#' @field parameters A named list of the `beta` and `gamma` parameters.
#'
#' @importFrom R6 R6Class
#' @export

LocationScaleRegression <- R6Class(
  classname = "LocationScaleRegression",
  public = list(
    parameters = list(
      beta = numeric(),
      gamma = numeric()
    ),

    #' @details
    #' Create a new `LocationScaleRegression` object.
    #'
    #' @param mformula A two-sided formula with the response variable on the
    #'                 LHS and the predictor for the mean on the RHS.
    #' @param sformula A one-sided formula with the predictor for the standard
    #'                 deviation.
    #' @param data A data frame (or list or environment) in which to evaluate
    #'             the formulas.
    #' @param ... Passed on to [stats::model.matrix()].
    #'
    #' @return
    #' A `LocationScaleRegression` object.
    #'
    #' @examples
    #' y <- rnorm(30)
    #' LocationScaleRegression$new(y ~ 1)
    #'
    #' @importFrom stats model.matrix

    initialize = function(mformula,
                          sformula = ~1,
                          data = environment(mformula),
                          ...) {
      private$y <- eval(mformula[[2]], data, environment(mformula))
      private$X <- model.matrix(mformula, data, ...)

      sformula <- update(sformula, paste(mformula[[2]], "~ ."))
      private$Z <- model.matrix(sformula, data, ...)

      self$parameters$beta <- rep.int(0, ncol(private$X))
      self$parameters$gamma <- rep.int(0, ncol(private$Z))

      invisible(self)
    },

    #' @details
    #' Returns the log-likelihood of a `LocationScaleRegression` object at the
    #' current parameter values.
    #'
    #' @return
    #' A single number.
    #'
    #' @examples
    #' y <- rnorm(30)
    #' model <- LocationScaleRegression$new(y ~ 1)
    #' model$loglik()
    #'
    #' @importFrom stats dnorm

    loglik = function() {
      mean <- drop(private$X %*% self$parameters$beta)
      sd <- exp(drop(private$Z %*% self$parameters$gamma))
      sum(dnorm(private$y, mean, sd, log = TRUE))
    },

    #' @details
    #' Returns the gradient of the log-likelihood of a
    #' `LocationScaleRegression` object at the current parameter values.
    #'
    #' @param parameters The names of the parameter blocks with respect to
    #'                   which the gradient should be computed. Either `"beta"`
    #'                   or `"gamma"` or both.
    #'
    #' @return
    #' A named list of numeric vectors.
    #'
    #' @examples
    #' y <- rnorm(30)
    #' model <- LocationScaleRegression$new(y ~ 1)
    #' model$grad()

    grad = function(parameters = c("beta", "gamma")) {
      y <- private$y
      X <- private$X
      Z <- private$Z
      beta <- self$parameters$beta
      gamma <- self$parameters$gamma

      mean <- drop(X %*% beta)
      sd <- exp(drop(Z %*% gamma))
      y0 <- y - mean

      out <- lapply(parameters, function(parameter) {
        if (parameter == "beta") {
          drop((y0 / sd^2) %*% X)
        } else if (parameter == "gamma") {
          drop(((y0 / sd)^2 - 1) %*% Z)
        } else {
          NA
        }
      })

      names(out) <- parameters

      out
    }
  ),
  private = list(
    y = numeric(),
    X = numeric(),
    Z = numeric()
  )
)


#' Gradient descent for the `LocationScaleRegression` model class
#'
#' This function optimizes the log-likelihood of the given location-scale
#' regression model by gradient descent. It has a side effect on the `model`
#' object.
#'
#' @param model A [`LocationScaleRegression`] object.
#' @param stepsize The scaling factor of the gradient.
#' @param maxit The maximum number of iterations.
#' @param abstol The absolute convergence tolerance. The algorithm stops if the
#'               absolute value of the gradient drops below this value.
#' @param verbose Whether to print the progress of the algorithm.
#'
#' @return
#' The updated model, invisibly.
#'
#' @examples
#' y <- rnorm(30)
#' model <- LocationScaleRegression$new(y ~ 1)
#' gradient_descent(model)
#'
#' @export

gradient_descent <- function(model,
                             stepsize = 0.001,
                             maxit = 1000,
                             abstol = 0.001,
                             verbose = FALSE) {
  grad <- model$grad()

  for (i in seq_len(maxit)) {
    for (p in seq_along(model$parameters)) {
      model$parameters[[p]] <- model$parameters[[p]] + stepsize * grad[[p]]
    }

    grad <- model$grad()

    if (verbose) {
      par_msg <- unlist(model$parameters)
      par_msg <- format(par_msg, trim = TRUE, digits = 3)
      par_msg <- paste(par_msg, collapse = " ")

      grad_msg <- unlist(grad)
      grad_msg <- format(grad_msg, trim = TRUE, digits = 3)
      grad_msg <- paste(grad_msg, collapse = " ")

      loglik_msg <- format(model$loglik(), digits = 3)

      message(
        "Iteration:      ", i, "\n",
        "Parameters:     ", par_msg, "\n",
        "Gradient:       ", grad_msg, "\n",
        "Log-likelihood: ", loglik_msg, "\n",
        "==============="
      )
    }

    if (all(abs(unlist(grad)) <= abstol)) break
  }

  message("Finishing after ", i, " iterations")
  invisible(model)
}
