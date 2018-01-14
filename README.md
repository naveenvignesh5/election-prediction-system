# Election Prediction using Twitter Data by means of vector modeling.

This is R project that is done to analyse data from twitter to prediction popularity of candidates
for elections.

### What it does
- Extract Raw Data from Twitter and Store it into Mongo DB.
- Process the stored data and filter the data based on following parameter
    * Location of phenomenon
    * Search Terms related to election
    * Number of tweets
    * Time window of the phenomenon
    * User Profile characteristics
- Calculates the following parameters
    * Relative Frequency - Ratio of total tweets per day to no. of tweets of particular party.
    * Positive Negative Ratio - Ratio of positive no. of tweets to that of negative no. of tweets.
    
### Steps to execute the project
- Download / Clone the repository
- Install Mongo DB
- Start Mongo Database in localhost
- Run command mongod.exe --dbpath 'path_to_database_folder'
`Rscript main.R`
- Plots will be generated in a PDF file.

### Modules contained in the project
- function.R -- function module containing the main functions to be used in the project
- environment.R -- contains the global parameters to be used
- packages.R -- contains the list of libraries / R packages to be used in the project
- main.R -- main module where the project runs.
- mine.R -- module that must be executed to mine data from twitter API as needed.

### Database Configurations
- Start Mongo DB server and that's it. You database is ready to be used.