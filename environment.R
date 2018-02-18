#---------------------------TWITTER CREDENTIALS----------------------

apiKey <- 'yAmS3louyR8diGxBwzJtLfgdE'
apiSecret <- 'GY40lRt62X7s8VxcFFeFOsgnKbqYHtJsuh6KAhE4JfnVntoKT5'
access_token <- '2195494530-V7csBiOqiffi69fZuhkZEqMRZO5xqHHWcSiBl9V'
access_token_secret <- 'CQ96GaCgeIFqq2XVPtigJnFVD9momtZqFBEsHpH8n7q3Z'

#--------------------------- INPUT DATA -----------------------------
    
no <- 10000
lang <- "en"

# search keywords belonging to general elections
searchQuery <- c(
   "#bjp",
   "#congress",
   "#modi",
   "#rahul",
   "#rahulgandhi"
)

#search keywords regarding particular parties
bjp <- c('modi','narendra','amitshah','bjp')
congress <- c('rahulgandhi','congress')


# maximum and minimum range of tweet geocodes
lat_min <- ""
long_min <- ""

lat_max <- ""
long_min <- ""

# ------------------------ DATABASE INFO ----------------------
# dbuser <- "naveenvignesh"
# dbpass <- "abcd1234"
dbcollection <- "tweets"
dbhost <- "mongodb://naveenvignesh:abcd1234@ds239097.mlab.com:39097/electiondb"
dbconn <- NULL

# ------------------------ COLOR VARIABLES -----------------------

pos_color <- '#49b21c'
neg_color <- '#ed0909'
neutral_color <- '#02b7ff'

bjp_color <- '#ff9707'
congress_color <- '#87ceeb'