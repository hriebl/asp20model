FROM gitpod/workspace-full

USER gitpod

RUN sudo apt-get update && \
  sudo apt-get install -y r-base && \
  sudo rm -rf /var/lib/apt/lists/*

RUN mkdir -p ~/R/site-library && \
  echo '.libPaths(c("~/R/site-library", .libPaths()))' >> ~/.Rprofile && \
  R -e 'install.packages(c("devtools", "numDeriv", "R6", "roxygen2", "testthat"))'
