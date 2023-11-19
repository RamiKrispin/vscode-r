FROM r-base:4.3.1

RUN apt-get update && apt-get install -y --no-install-recommends libxml2-dev

RUN Rscript -e 'install.packages("languageserver")'