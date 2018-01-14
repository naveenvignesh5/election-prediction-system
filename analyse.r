# Program: Code to analyse the stored tweets
source("packages.R")
source("environment.R")
source("functions.R")

setupMongoDatabase()

tweetData <- getTweets()

tweetDataCopy <- tweetData

print(tweetData)