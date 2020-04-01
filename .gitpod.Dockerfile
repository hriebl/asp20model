FROM gitpod/workspace-full

USER gitpod

RUN brew install R

RUN sudo apt-get update && \
  sudo apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev && \
  sudo rm -rf /var/lib/apt/lists/* && \
  R -e "install.packages(c('devtools', 'numDeriv', 'R6', 'roxygen2', 'testthat'))"
