FROM gitpod/workspace-full

USER gitpod

RUN brew install R && \
  echo 'options(repos = c(CRAN = "https://cloud.r-project.org/"))' >> ~/.Rprofile && \
  R -e 'install.packages(c("devtools", "numDeriv", "R6", "roxygen2", "testthat"))'
