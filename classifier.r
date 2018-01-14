# Rscript to classify tweets into individual parties

# Things to do 
# 1. Must Find Individual Key terms for each tweet.
# 2. Analyse the terms and then classify them to particular party.

source('environment.R')
source('packages.R')
source('functions.R')

setupMongoDatabase()

tweetData <- getTweets("tweets")

bjp_tweets <- NULL

classifyAndStore(tweetData)