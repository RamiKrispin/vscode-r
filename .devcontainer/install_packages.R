# ---- Description
# This file installs the required R packages on the Docker image during the build time. 
# The list of packages and their versions is set on the packages.json file
# ---- Dependencies
# To parse the json jq must be installed on the docker image. 
# See: https://stedolan.github.io/jq/
# ---- Code starts here 
# Set the working directory
setwd("./settings/")
# Required the remotes package
install.packages("remotes", repos = "http://cran.rstudio.com/")
#---- Load list of packages
# Set the jq query
jq_command <- 'jq -r ".packages[] |  [.package, .version] | @tsv" packages.json'
# Debug mode
# jq_command <- 'jq -r ".package_dev[] |  [.package, .version] | @tsv" packages.json'

# Parse the json file with the list of package
raw <- system(command = jq_command, intern = TRUE)

package_list <- lapply(raw, function(i){
  x <- unlist(strsplit(x = i, split = "\t"))
  data.frame(package = x[1], version = x[2], stringsAsFactors = FALSE)
})
# Transform the list into a data.frame
packages_df <- as.data.frame(t(matrix(unlist(package_list), nrow = 2)),
                         stringsAsFactors = FALSE)
names(packages_df) <- c("package", "version")
packages_df$success <- FALSE

# ---- Install the packages

for(i in 1:nrow(packages_df)){
  if(!packages_df$package[i] %in% rownames(installed.packages()) ||
     (packages_df$package[i] %in% rownames(installed.packages()) &&
      packageVersion(packages_df$package[i]) != packages_df$version[i])){
    cat("\033[0;92m", paste("Installing", packages_df$package[i]), "\033[0m\n", sep = "")

    remotes::install_version(package = packages_df$package[i],
                             version = packages_df$version[i],
                             dependencies = c("Depends", "Imports"),
                             upgrade = FALSE,
                             verbose = FALSE,
                             quiet = FALSE,
                             repos = "http://cran.rstudio.com/")
  }

  if(!packages_df$package[i] %in% rownames(installed.packages()) ||
     (packages_df$package[i] %in% rownames(installed.packages()) &&
      packageVersion(packages_df$package[i]) != packages_df$version[i])){
    packages_df$success[i] <- FALSE
  } else {
    packages_df$success[i] <- TRUE
  }
}

for(i in 1:nrow(packages_df)){
    if(packages_df$success[i]){
         cat("\033[0;92m",packages_df$package[i], "...OK", "\033[0m\n")
    } else{
         cat("\033[0;91m",packages_df$package[i], "...Fail", "\033[0m\n")
    }
}


for(i in sort(c(packages_df$package))){
  if(!i %in% rownames(installed.packages())){
    f <- TRUE
    cat("...Failed\n")
  } else{
    cat("...OK\n")
  }
}

if(!any(packages_df$success)){
  stop("One or more packages are missing...")
}