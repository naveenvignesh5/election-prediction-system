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

# search and storing tweets into election database
tweetData <- searchTweets()
tweetDataCopy <- tweetData
tweetData <- cleanTweets(tweetData)

queryData <- queryTweets(searchQuery,tweetData,tweetDataCopy)

scores <- calculateSentiment(queryData)

scores$positive <- as.numeric(scores$score >0)
scores$negative <- as.numeric(scores$score >0)
scores$neutral <- as.numeric(scores$score==0)

print(sum(scores$positive))