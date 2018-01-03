#---------------------------TWITTER CREDENTIALS----------------------

apiKey <- 'yAmS3louyR8diGxBwzJtLfgdE'
apiSecret <- 'GY40lRt62X7s8VxcFFeFOsgnKbqYHtJsuh6KAhE4JfnVntoKT5'
access_token <- '2195494530-V7csBiOqiffi69fZuhkZEqMRZO5xqHHWcSiBl9V'
access_token_secret <- 'CQ96GaCgeIFqq2XVPtigJnFVD9momtZqFBEsHpH8n7q3Z'


#--------------------------- INPUT DATA -----------------------------

tweetQuery <- c(
    "#bjp"
)

no <- 1000
lang <- "en"

# search keywords belonging to particular party
searchQuery <- c(
   "modi"
)

# maximum and minimum range of tweet geocodes
lat_min <- ""
long_min <- ""

lat_max <- ""
long_min <- ""

# ------------------------------ DATABASE INFO --------------
dbname <- "naveenvignesh"
dbpass <- "abcd1234"
dbcollection <- "tweets"
dbhost <- "mongodb://<dbuser>:<dbpassword>@ds239097.mlab.com:39097/electiondb"
