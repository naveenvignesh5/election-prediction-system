# R script containing all mathematical functions

setupTwitterAPI <- function() {
    setup_twitter_oauth(apiKey,apiSecret,access_token,access_token_secret)
}

setupDatabase <- function() {
    # setting up mysql connection
    register_mysql_backend(dbname,dbhost,dbuser,dbpass)
}

#------------------------TWITTER SEARCH---------------------

searchTweets <- function() {
    generalTweets <- searchTwitter(tweetQuery,no,lang)
    return (generalTweets)
}

#----------------------- CLEANING THE TWEETS -------------------------

cleanTweets <- function(tweets) {
    tweets.df <- twListToDF(tweets)
    myCorpus <- Corpus(VectorSource(tweets.df$text)) 
    myCorpus <- cleanCorpus(myCorpus)
    return (myCorpus)
}

cleanCorpus <- function(myCorpus) {
    myCorpus <- tm_map(myCorpus,removePunctuation)
    myCorpus <- tm_map(myCorpus,content_transformer(tolower))
    myCorpus <- tm_map(myCorpus,removeWords,stopwords("english"))
    myCorpus <- tm_map(myCorpus, removeWords, c("like", "video"))
    myCorpus <- tm_map(myCorpus, stripWhitespace)
    myCorpusCopy <- myCorpus
    myCorpus <- tm_map(myCorpus, stemDocument)
    myCorpus <- lapply(myCorpus,specialStem,dictionary=myCorpusCopy)
    return (myCorpus)
}

specialStem <- function(x,dictionary) {
    x <- unlist(strsplit(as.character(x), " "))
    x <- x[x != ""]
    x <- stemCompletion(x, dictionary=dictionary)
    x <- paste(x, sep="", collapse=" ")
    PlainTextDocument(stripWhitespace(x))
}
#----------------------- QUERY TWEETS -------------------------

AddItemNaive <- function(item,arr) {
  arr[[length(.GlobalEnv$Result)+1]] <- item
}

queryTweets <- function(query,corpus) {
    res = c()
    for(i in 1:length(corpus)) {
        temp <- unlist(strsplit(toString(corpus[[i]]$content),split=" "))
        if(query %in% temp) {
            res <- c(res,corpus[[i]]$content)
        }
    }
    res <- unique(res)
    return(res)
}

# ----------------------- REMOVING DUPLICATES ---------------------------

# method to remove near duplicates
shingleVector <- function(vector) {
    
}