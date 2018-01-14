# R script containing all mathematical and logic functions

#------------------------- SETTING UP TWITTER -----------------

setupTwitterAPI <- function() {
    setup_twitter_oauth(apiKey,apiSecret,access_token,access_token_secret)
}

#------------------------TWITTER SEARCH---------------------

searchTweets <- function() {
    tweetQuery <- paste(searchQuery, collapse = " OR ")
    print("Started Getting Tweets")                          
    generalTweets <- searchTwitter(tweetQuery,no,lang) 
    generalTweets <- strip_retweets(generalTweets,strip_manual=TRUE,strip_mt=TRUE)
    print("Finished Getting Tweets")
    return (generalTweets)
}

#------------------------- DATABASE RELATED FUNCTIONS -------------------------------

setupMongoDatabase <- function() {
    dbconn <<- mongo(collection=dbcollection)
}

storeTweets <- function(tweets) {
    print("Started Storage Process")
    df <- twListToDF(tweets)
    df$text <- lapply(df$text,function(x) iconv(x,"latin1","ASCII",sub=""))
    df$text <- lapply(df$text,function(x) gsub('(http\\S+\\s*)|(#)|(@)|(\n)|(")|(&amp)', '',x))
    dbconn$insert(df)
    print("Inserted Tweets to Database")
}

getTweets <- function(coll) {
    conn <- mongo(collection=coll)
    tweets <- conn$find('{}')
    return(tweets)
}

#----------------------- CLEANING THE TWEETS -------------------------

cleanTweets <- function(tweets) {
    tweets.df <- tweets
    # tweets.df$text <- removeEmoticons(tweets.df$text)
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
    tweets.df <- org_tweets_df
    
    # creating document corpuses from data frames
    myCorpus <- Corpus(VectorSource(tweets.df$text))
    
    orgCorpus <- Corpus(VectorSource(corpus$text))

    # vector buffer to store queried tweets
    res = c()

    # linearly searching array for match with query
    for(i in 1:length(corpus)) {

        # splitting sentence into vector of words
        temp <- unlist(strsplit(toString(corpus[[i]]$content),split=" ")) 
        
        if(query %in% temp) {
            res <- c(res,myCorpus[[i]]$content)
        }

    }  

    # removing duplicates from resultant corpus that may be re-tweets
    res <- unique(res)
    return(res)
}

#------------------------- SENTIMENT ANALYSIS -------------------------------

setupPosNeg <- function(posText,negText) {
    # creating file objects from text files containing positive and negative terms 
    posText <- read.delim("positive.txt", header=FALSE, stringsAsFactors=FALSE)
    negText <- read.delim("negative.txt", header=FALSE, stringsAsFactors=FALSE)

    posText <- posText$V1
    negText <- negText$V1

    # creating vector of words contained in files for sampling words for sentiment analysis
    posText <- unlist(lapply(posText, function(x) { str_split(x, "\n") }))

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

# method to generate pnr ratio using sentiment count 
generatePNR <- function(data) {
    data$created <- as.Date(data$created,format='%d%m%y')
    dates <- table(cut(data$created,'day'))
    dates <- data.frame(Date=format(as.Date(names(dates))))
    
    dates <- as.vector(dates$Date)
    ratios <- c()
    for(i in 1:length(dates)) {
        date <- dates[i]
        df <- subset(data,data$created == date)

        scores <- calculateSentiment(df$text)

        positive <- as.numeric(scores$score > 0)
        negative <- as.numeric(scores$score < 0)
        neutral <- as.numeric(scores$score==0)

        pnratio <- sum(positive) / sum(negative)
        ratios <- c(ratios,pnratio)        
    }

    ratios <- round(ratios,digits=2)
    pnr <- data.frame(Date=dates,pnr=ratios)
    return(pnr)
}

# ------------------------------ CLASSIFICATION FUNCTIONS ----------------------------------
 
classifyAndStore <- function(x) {
    bjp <- paste(bjp,collapse='|')
    congress <- paste(congress,collapse='|')
        
    indices <- grep(bjp,x$text)

    con <- mongo(collection="bjp_tweets")
    for(i in indices) {
        con$insert(x[i,])
    }

    indices <- grep(congress,x$text)

    con <- mongo(collection="congress_tweets")
    for(i in indices) con$insert(x[i,])
}

#------------------------------- GENERATE FREQUENCY --------------------------------

generateFrequency <- function(data) {
    data$created <- as.Date(data$created,format='%d%m%y')
    tab <- table(cut(data$created,'day'))
    frequency <- data.frame(Date=format(as.Date(names(tab)),'%d-%m-%y'),Frequency=as.vector(tab))
    return(frequency)
}

# method to generate relative frequency
generateRF <- function(gen,party) {
    gen_freq <- generateFrequency(gen)
    party_freq <- generateFrequency(party)

    pnr <- round((party_freq$Frequency / gen_freq$Frequency),digits=2)
    return(pnr)
}

#------------------------------- PLOTTING FUNCTIONS --------------------------------

plotSentiment <- function(data,plot_title) {
    n <- length(data)
    
    Types <- c("Positive","Negative","Neutral")

    positive <- as.numeric(data$score > 0)
    negative <- as.numeric(data$score < 0)
    neutral <- as.numeric(data$score == 0)

    score <- c(sum(positive),sum(negative),sum(neutral))
    score <- (score / n) * 100 # converting score to percentage
    sentiment <- data.frame(Types,score)

    plot <- ggplot(data=sentiment,aes(x=Types,y=score,fill=Types)) + geom_bar(stat="identity")+theme_minimal()
    plot <- plot + scale_fill_manual(values=c(neg_color,neutral_color,pos_color)) + ggtitle(plot_title)
    plot <- plot + scale_y_continuous(limits = c(0, 100)) + xlab("Sentiment Types") + ylab("% of Sentiment")
    
    return(plot)
}

plotTweetFrequency <- function(freqData) {
    plot <- ggplot(freqData,aes(Date,group=1))
    plot <- plot + geom_line(aes(y=BJP,colour="BJP"))
    plot <- plot + geom_line(aes(y=Congress,colour="Congress"))
    plot <- plot + scale_colour_manual(values=c(bjp_color,congress_color))
    plot <- plot + labs(colour="Parties",y="No. of Tweets") + ggtitle("Frequency of Partywise Tweets")
    return(plot)
}

plotGeneralTweetFrequency <- function(allData) {
    plot <- ggplot(allData,aes(x=Date,y=Frequency,group=1))
    plot <- plot + geom_line(color=neg_color)
    plot <- plot + labs(x="Days",y="No. of Tweets") + ggtitle("Frequency of Election Tweets")
    return(plot)
}

plotRelativeFrequency <- function(rfData) {
    plot <- ggplot(rfData,aes(Date,group=1))
    plot <- plot + geom_line(aes(y=BJP,colour="BJP"))
    plot <- plot + geom_line(aes(y=Congress,colour="Congress"))
    plot <- plot + scale_colour_manual(values=c(bjp_color,congress_color))
    plot <- plot + labs(colour="Parties",y="Relative Frequency") + ggtitle("Relative Frequency of Parties")
    return(plot)
}

plotPNR <- function(pnrData) {
    plot <- ggplot(pnrData,aes(Date,group=1))
    plot <- plot + geom_line(aes(y=BJP,colour="BJP"))
    plot <- plot + geom_line(aes(y=Congress,colour="Congress"))
    plot <- plot + scale_colour_manual(values=c(bjp_color,congress_color))
    plot <- plot + labs(colour="Parties",y="Positive - Negative Ratio") + ggtitle("Positive - Negative Ratio of Parties")
    return(plot)
}