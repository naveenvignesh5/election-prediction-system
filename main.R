# main code to set the project running
# Title: Election Prediction Using R


# external modules to be used
source("packages.R")

# loading the project configuration and metadata
source("environment.R")

# loading function module to be used
source("functions.R")


#setting up mongo database connection for tweets storage
setupMongoDatabase()

# getting tweets of all parties from database
all_tweets <- getTweets("tweets")

# getting tweets of particular party from election database
bjp_tweets <- getTweets("bjp_tweets")
congress_tweets <- getTweets("congress_tweets")
all_tweets <- getTweets("tweets")

# calculating sentiment scores for the obtained tweets
bjp_scores <- calculateSentiment(bjp_tweets$text)
congress_scores <- calculateSentiment(congress_tweets$text)

# plotting sentiment plots using the obtained data
plotSentiment(bjp_scores,"BJP Sentiment Plot")
plotSentiment(congress_scores,"Congress Sentiment Plot")

# generting the frequency data frame for obtained tweets
bjp_freq <- generateFrequency(bjp_tweets)
congress_freq <- generateFrequency(congress_tweets)
all_freq <- generateFrequency(all_tweets)

frequencyDf <- merge(bjp_freq,congress_freq,by="Date")

colnames(frequencyDf) <- c("Date","BJP","Congress")

plotTweetFrequency(frequencyDf)
plotGeneralTweetFrequency(all_freq)


bjp_rf <- generateRF(all_tweets,bjp_tweets)
congress_rf <- generateRF(all_tweets,congress_tweets)

rf_df <- data.frame(frequencyDf$Date,bjp_rf,congress_rf)
colnames(rf_df) <- c("Date","BJP","Congress")

plotRelativeFrequency(rf_df)

bjp_pnr <- generatePNR(bjp_tweets)
congress_pnr <- generatePNR(congress_tweets)

pnr_df <- merge(bjp_pnr,congress_pnr,by="Date")
colnames(pnr_df) <- c("Date","BJP","Congress")

# print(pnr_df)
plotPNR(pnr_df)