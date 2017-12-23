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

#setting up mysql database for tweets storage
# setupDatabase()

# search and storing tweets into election database
tweetData <- searchTweets()

tweetData <- cleanTweets(tweetData)

queryTweets(searchQuery,tweetData)

# print(queryData)