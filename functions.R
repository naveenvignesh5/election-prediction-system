# R script containing all mathematical functions

setupTwitterAPI <- function() {
    setup_twitter_oauth(apiKey,apiSecret,access_token,access_token_secret)
}

setupDatabase <- function() {
    register_mysql_backend(dbname,dbhost,dbuser,dbpass)
}

filterData <- function(terms) {
    
}