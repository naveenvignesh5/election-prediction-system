# R script containing all mathematical and logic functions

#------------------------- SETTING UP TWITTER -----------------

setupTwitterAPI <- function() {
    setup_twitter_oauth(apiKey,apiSecret,access_token,access_token_secret)
}


#------------------------TWITTER SEARCH---------------------

searchTweets <- function() {
    generalTweets <- searchTwitter(tweetQuery,no,lang)
    return (generalTweets)
}

#------------------------- DATABASE RELATED FUNCTIONS -------------------------------

setupMongoDatabase <- function() {
    dbconn <- mongo(collection=dbcollection)
}

storeTweets <- function(tweets,collection) {
    df <- twListToDF(tweets)
    con <- mongo(collection)
    con$insert(df)
}

getTweets <- function(collection) {
    con <- mongo(collection)
    tweets <- con$find('{}')
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

queryTweets <- function(query,corpus,org_tweets_df) {
    # converting raw tweets into document corpus containing only raw text details about the tweet
    tweets.df <- twListToDF(org_tweets_df)
    tweets.df[[0]]
    myCorpus <- Corpus(VectorSource(tweets.df$text))

    # vector buffer to store queried tweets
    res = c()

    # linearly searching array for match with query
    for(i in 1:length(corpus)) {
        temp <- unlist(strsplit(toString(corpus[[i]]$content),split=" "))
        if(query %in% temp) {
            res <- c(res,myCorpus[[i]]$content)
        }
    }  

    # binary search alternative - for increasing performance
    # first <- 0
    # last <- length(corpus)
    # middle <- (first + last) / 2

    # while(first <= last) {
    #     if()
    # }
    # removing duplicate items from vector and storing back to buffer
    res <- unique(res)
    return(res)
}

# ----------------------- REMOVING DUPLICATES ---------------------------

# method to remove near duplicates
# shingleVector <- function(vector) {
    
# }

#------------------------- SENTIMENT ANALYSIS -------------------------------

# return vector of positive and negative words
setupPosNeg <- function(posText,negText) {
    posText <- read.delim("positive.txt", header=FALSE, stringsAsFactors=FALSE)
    posText <- posText$V1
    posText <- unlist(lapply(posText, function(x) { str_split(x, "\n") }))
    negText <- read.delim("negative.txt", header=FALSE, stringsAsFactors=FALSE)
    negText <- negText$V1
    negText <- unlist(lapply(negText, function(x) { str_split(x, "\n") }))
    pos.words = c(posText, 'upgrade')
    neg.words = c(negText, 'wtf', 'wait', 'waiting','epicfail', 'mechanical')
    return(list("pos"=pos.words,"neg"=neg.words))
}

score.sentiment = function(sentences, pos.words, neg.words, .progress='none')
{
# Parameters
# sentences: vector of text to score
# pos.words: vector of words of positive sentiment
# neg.words: vector of words of negative sentiment
# .progress: passed to laply() to control of progress bar
# create a simple array of scores with laply
    scores = laply(sentences, function(sentence, pos.words, neg.words) {
        # remove punctuation
        sentence = gsub("[[:punct:]]", "", sentence)
        # remove control characters
        sentence = gsub("[[:cntrl:]]", "", sentence)
        # remove digits?
        sentence = gsub('\\d+', '', sentence)
        # define error handling function when trying tolower
        tryTolower = function(x)
        {
            # create missing value
            y = NA
            # tryCatch error
            try_error = tryCatch(tolower(x), error=function(e) e)
            # if not an error
            if (!inherits(try_error, "error"))
            y = tolower(x)
            # result
            return(y)
        }
        # use tryTolower with sapply 
        sentence = sapply(sentence, tryTolower)
        # split sentence into words with str_split (stringr package)
        word.list = str_split(sentence, "\\s+")
        words = unlist(word.list)
        # compare words to the dictionaries of positive & negative terms
        pos.matches = match(words, pos.words)
        neg.matches = match(words, neg.words)
        # get the position of the matched term or NA
        # we just want a TRUE/FALSE
        pos.matches = !is.na(pos.matches)
        neg.matches = !is.na(neg.matches)
        # final score
        score = sum(pos.matches) - sum(neg.matches)
        return(score)
        }, pos.words, neg.words, .progress=.progress )
    
    # data frame with scores for each sentence
    scores.df = data.frame(text=sentences, score=scores)
    return(scores.df)
}

calculateSentiment <- function(tweets) {
    sample <- setupPosNeg()
    score <- score.sentiment(tweets,sample$pos,sample$neg,.progress="none")
    return(score)
}