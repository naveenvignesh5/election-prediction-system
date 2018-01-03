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

### Steps to execute the project
- Download / Clone the repository
- Run command 
`Rscript main.R`
- Plots will be generated in a PDF file.

### Modules contained in the project
- function.R -- function module containing the main functions to be used in the project
- environment.R -- contains the global parameters to be used
- packages.R -- contains the list of libraries / R packages to be used in the project
- main.R -- main module where the project runs.