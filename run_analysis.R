# Getting and Cleaning Data Course Project
# Hunter Droegkamp
# 7/10/17

# This run_analysis.R script is designed to perform the following:
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement.
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names.
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.



# Download and prepare files for use in the workspace
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "course3proj.zip")
unzip("course3proj.zip")
setwd("~/Coursera/Course 3/UCI HAR Dataset")

# Read, assign column names, and combine training data
subjectTrain <- read.table("./train/subject_train.txt", header = FALSE)
xTrain <- read.table("./train/x_train.txt", header = FALSE)
yTrain <- read.table("./train/y_train.txt", header = FALSE)
features <- read.table("./features.txt", header = FALSE)
activityLabels <- read.table("./activity_labels.txt", header = FALSE)

colnames(subjectTrain) <- "subjectId"
colnames(xTrain) <- features[,2]
colnames(yTrain) <- "activityId"
colnames(activityLabels) <- c("activityId", "activityType")

trainData <- cbind(yTrain, subjectTrain, xTrain)

# Read, assign column names, and combine test data
subjectTest <- read.table("./test/subject_test.txt", header = FALSE)
xTest <- read.table("./test/x_test.txt", header = FALSE)
yTest <- read.table("./test/y_test.txt", header = FALSE)

colnames(subjectTest) <- "subjectId"
colnames(xTest) <- features[,2]
colnames(yTest) <- "activityId"

testData <- cbind(yTest, subjectTest, xTest)

# Combine training and test sets into one data set
finalData <- rbind(trainData, testData)
finalData <- merge(finalData, activityLabels, by = "activityId", all.x = TRUE)

# Extract only measurements on mean and standard deviation
col <- colnames(finalData)
logical <- (grepl("activity..", col) | grepl("subject..", col) | 
              grepl("-mean..", col) & !grepl("-meanFreq..", col) & 
              !grepl("mean..-", col) | grepl("-std..", col) & 
              !grepl("-std()..-", col))
finalData <- finalData[logical == TRUE]

# Clean up variable names
col <- colnames(finalData)
for (i in 1:length(col))
{
    col[i] <- gsub("\\()", "", col[i])
    col[i] <- gsub("-std$", "StdDev", col[i])
    col[i] <- gsub("-mean", "Mean", col[i])
    col[i] <- gsub("^(t)", "time", col[i])
    col[i] <- gsub("^(f)", "freq", col[i])
    col[i] <- gsub("BodyBody", "Body", col[i])
    col[i] <- gsub("AccMag", "AccMagnitude", col[i])
    col[i] <- gsub("JerkMag", "JerkMagnitude", col[i])
    col[i] <- gsub("GyroMag", "GyroMagnitude", col[i])
}
colnames(finalData) <- col

# Create a second data set with the average of each variable for each activity and subject
finalData2 <- finalData[, names(finalData) != "activityLabels"]
meanData <- aggregate(finalData2[, names(finalData2) != c("activityId", 
                      "subjectId")], by = list(activityId = finalData2$activityId,
                      subjectId = finalData2$subjectId), mean)
meanData <- merge(meanData, activityLabels, by = "activityId", all.x = TRUE)

# Export the final data set
write.table(meanData, "./meanData.txt", row.names = FALSE, sep = "\t")