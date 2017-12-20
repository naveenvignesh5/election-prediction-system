# main code to set the project running
# Title: Election Prediction Using R


# external modules to be used
source("packages.R")

# packages to be used
source("environment.R")

# setting up twitter API for collection tweets
setup_twitter_oauth(apiKey,apiSecret,access_token,access_token_secret)