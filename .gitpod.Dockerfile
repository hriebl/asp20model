FROM gitpod/workspace-full

USER gitpod

RUN sudo apt-get update

RUN sudo apt-get install -y \
  r-base \
  r-cran-devtools \
  r-cran-numDeriv \
  r-cran-R6 \
  r-cran-roxygen2 \
  r-cran-testthat

RUN sudo rm -rf /var/lib/apt/lists/*
