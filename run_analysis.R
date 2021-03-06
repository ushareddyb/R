######################
## Loading Packages ##
######################
setwd("C:/Users/UshaRani/Documents/Coursera/R")
# Function to check whether package is installed
is.installed <- function(mypkg){
  is.element(mypkg, installed.packages()[,1])
} 

# check if package "data.table is installed
if (!is.installed("data.table")){
  install.packages("data.table")
}
# check if reshape2 package is installed
if (!"reshape2" %in% installed.packages()) {
  install.packages("reshape2")
}
require(data.table)
library("reshape2")


#############################
## Data download and unzip ##
#############################

# string variables for file download
fileName <- "getdata_projectfiles_UCI HAR Dataset.zip"
url <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dir <- "UCI HAR Dataset"

# File download verification. If file does not exist, download to working directory.
if(!file.exists(fileName)){
  download.file(url,fileName, mode = "wb") 
}

# File unzip verification. If the directory does not exist, unzip the downloaded file.
if(!file.exists(dir)){
  unzip("UCIdata.zip", files = NULL, exdir=".")
}

###################################################################
## Merges the training and the test sets to create one data set. ##
###################################################################
x_train <- fread(input = "UCI HAR Dataset/train/X_train.txt")
subject_train <- fread(input = "UCI HAR Dataset/train/subject_train.txt")
names(subject_train)[1] <- 'subject'
label_train <- fread(input = "UCI HAR Dataset/train/y_train.txt")
names(label_train)[1] <- "activity"
x_test <- fread(input = "UCI HAR Dataset/test/X_test.txt")
subject_test <- fread(input = "UCI HAR Dataset/test/subject_test.txt")
names(subject_test)[1] <- "subject"
label_test <- fread(input = "UCI HAR Dataset/test/y_test.txt")
names(label_test)[1] <- "activity"
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")

## merge the files
bind_train <- cbind(subject_train, label_train, x_train)
bind_test <- cbind(subject_test, label_test, x_test)

## 1. Merges the training and the test sets to create one data set.
DT <- rbind(bind_train,bind_test)

#############################################################################################
## Extracts only the measurements on the mean and standard deviation for each measurement. ##
#############################################################################################

## Create a column vector of mean
means <- apply(DT[3:563], 2, mean)

## Create a colum vector of standard deviation
stand_deviation <- apply(DT[3:563], 2, sd)

## Combine both results
extracted_stats <- cbind(means,stand_deviation)

############################################################################
## Uses descriptive activity names to name the activities in the data set ##
############################################################################
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
act_group <- factor(DT$activity)
levels(act_group) <- activity_labels[,2]
DT$activity <- act_group

########################################################################
## Appropriately labels the data set with descriptive variable names. ##
########################################################################

features <- fread(input = "UCI HAR Dataset/features.txt")
# Create vector of "Clean" feature names by getting rid of "()" apply to the dataSet to rename labels.
CleanFeatureNames <- sapply(features[, 2], function(x) {gsub("[()]", "",x)})
names(DT) <- CleanFeatureNames[means]

# combine test and train of subject data and activity data, give descriptive lables
subject <- rbind(subject_train, subject_test)
names(subject) <- 'subject'
activity <- rbind(y_train, y_test)
names(activity) <- 'activity'

# combine subject, activity, and mean and std only data set to create final data set.
DT <- cbind(subject,activity, DT)

####################################################################################################################################################
## From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject. ##
####################################################################################################################################################

secondDataSet <- aggregate( . ~ subject + activity, data = DT, FUN = mean )
# write out tidy Data
write.table( secondDataSet, "tidy_data.txt", row.names = FALSE )
