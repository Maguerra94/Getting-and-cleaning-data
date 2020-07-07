#setup working directory
getwd()

# test if file directory exist and download files
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(Url,destfile="./Getting-and-cleaning-data/Dataset.zip")
unzip(zipfile="./Getting-and-cleaning-data/Dataset.zip",exdir="./Getting-and-cleaning-data")
donde <- file.path("./Getting-and-cleaning-data" , "UCI HAR Dataset")
archivo<-list.files(donde, recursive=TRUE)
archivo

#Read Activity files
ActivityTest  <- read.table(file.path(donde, "test" , "y_test.txt" ),header = FALSE)
ActivityTrain <- read.table(file.path(donde, "train", "y_train.txt"),header = FALSE)

#Read Subject files
SubjectTest  <- read.table(file.path(donde, "test" , "subject_test.txt"),header = FALSE)
SubjectTrain <- read.table(file.path(donde, "train", "subject_train.txt"),header = FALSE)

#Read Features files
FeaturesTest  <- read.table(file.path(donde, "test" , "X_test.txt" ),header = FALSE)
FeaturesTrain <- read.table(file.path(donde, "train", "X_train.txt"),header = FALSE)

#Read Activity labels
activityLabels <- read.table(file.path(donde, "activity_labels.txt"),header = FALSE)
names(activityLabels)<- c("activity", "Description")

#Verify variables
str(ActivityTest)
str(ActivityTrain)
str(SubjectTrain)
str(SubjectTest)
str(FeaturesTest)
str(FeaturesTrain)

#1. merge training and test sets
Subject <- rbind(SubjectTrain, SubjectTest)
names(Subject)<-c("Subject")

Activity<- rbind(ActivityTrain, ActivityTest)
names(Activity)<- c("activity")

Features<- rbind(FeaturesTrain, FeaturesTest)
FeaturesNames <- read.table(file.path(donde, "features.txt"),head=FALSE)
names(Features)<- FeaturesNames$V2

Combine <- cbind(Subject, Activity)
Data <- cbind(Combine, Features)

#2.Extract the measurements on the mean and standard deviation for each measurement.
library(dplyr)
library(tidyr)

Data2<- Data %>% select(Subject, Activity, contains("mean"), contains("std"))
str(Data2)

#3. Use descriptive activity names to name the activities in the data set
Data2$Activity<-activityLabels[Data2$Activity,2]

#4. Appropriately labels the data set with descriptive variable names.
names(Data2)<-gsub("Acc", "Accelerometer", names(Data2))
names(Data2)<-gsub("Gyro", "Gyroscope", names(Data2))
names(Data2)<-gsub("BodyBody", "Body", names(Data2))
names(Data2)<-gsub("Mag", "Magnitude", names(Data2))
names(Data2)<-gsub("^t", "Time", names(Data2))
names(Data2)<-gsub("^f", "Frequency", names(Data2))
names(Data2)<-gsub("tBody", "TimeBody", names(Data2))
names(Data2)<-gsub("-mean()", "Mean", names(Data2), ignore.case = TRUE)
names(Data2)<-gsub("-std()", "STD", names(Data2), ignore.case = TRUE)
names(Data2)<-gsub("-freq()", "Frequency", names(Data2), ignore.case = TRUE)
names(Data2)<-gsub("angle", "Angle", names(Data2))
names(Data2)<-gsub("gravity", "Gravity", names(Data2))

## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
New_Data<- group_by(Data2,Subject, Activity)
New_Data<- summarise_all(New_Data, mean)
write.table(New_Data, "Tidydata.txt", row.name=FALSE)


