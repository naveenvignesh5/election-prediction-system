# main code to set the project running
# Title: Election Prediction Using R

# external modules to be used
source("packages.R")

# loading the project configuration and metadata
source("environment.R")

# loading function module to be used
source("functions.R")

# setting up twitter API for collection tweets
setupTwitterAPI()

#setting up mongo database connection for tweets storage
setupMongoDatabase()

#searching tweets from online database
tweets <- searchTweets()

#storing tweets into mongo database
storeTweets(tweets)