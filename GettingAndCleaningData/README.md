---
title: "README"
author: "Eric Rodriguez"
date: "July 25, 2015"
output: html_document
---

# Download and extract the data
```
if (!file.exists("data")) { dir.create("data") }
data.url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# If on Linux/Mac
#download.file(data.url, destfile = "./data/UCI_HAR_Dataset.zip", method = 'curl')
# If on windows
download.file(data.url, destfile = "./data/UCI_HAR_Dataset.zip")

unzip("./data/UCI_HAR_Dataset.zip", exdir = "./data")
```

# Merges the training and the test sets to create one data set.
First we use the *rea.table* command to read and load the data into R. The defaults of *read.table*; such as one or more spaces, tabs, newlines or carriage returns; are
perfect for these txt files.
```
training <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
testing <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
```

Now we combine the training with the test data set. We will standardize to putting the rows of the training set first, and then the ones of the test set.
```
complete_set <- rbind(training, testing)
```

# Extract only the measurements on the mean and standard deviation for each measurement. 

Its more convenient to perform this step **before** we add the `ACTIVITY` and `SUBJECT` variables so that the columns of features.txt coincide with the ones from our dataset.
First we retrieve the names of each variable/column. The file has 2 columns one for the INDEX of the column and another for the NAME. We name each column accordingly to make
working with them clearer and easier.
```
variables_names <- read.table("./data/UCI HAR Dataset/features.txt", col.names = c("INDEX", "NAME")) 
```

Now we retrieve the index of those columns with "mean()" or "std()" in their names using [regular expresions](http://sux13.github.io/DataScienceSpCourseNotes/3_GETDATA/Getting_and_Cleaning_Data_Course_Notes.html#regular-expressions). We only consider those measurements about the mean and standard deviation of measurements. For the present analysis we will not consider weighted averages so we will exclude variable names similar to "meanFreq()" therefore the 
regular expression will look for those names where "mean" and "std" are immediately followed by "()".
```
means_stds_indexes <- grep('(mean\\(\\)|std\\(\\))', variables_names$NAME)
```

Subset all rows and the columns whose index coincide with those we stored on `means_stds_indexes`.
```
complete_set <- complete_set[,means_stds_indexes]
```

# Appropriately labels the data set with descriptive variable names. 

Since we already have the names for each variable and the index of of the variables anem we are interested in, namely those regarding the "mean()" and "std()", all we have to do is ask for the 'name' of the corresponding index we need. While we're at it, we remove problematic characters such as "(" and ")"
```
colnames(complete_set) <- gsub("\\(|\\)", "", variables_names[means_stds_indexes,"NAME"])
```

# Uses descriptive activity names to name the activities in the data set

First we extract the activities from both the training and testing data sets
```
activities_training <- read.table("./data/UCI HAR Dataset/train/y_train.txt", col.names = "ACTIVITY")
activities_testing <- read.table("./data/UCI HAR Dataset/test/y_test.txt", col.names = "ACTIVITY")
```

Then we combine the rows, to keep the same order as with the main data set, we put the training set rows first and then the ones from the test set.
```
complete_activities <- rbind(activities_training, activities_testing)
```

Now we obtain the list of activity labels with their respectiv code. The first column represent the "code" (1-6), the second is the respective label. We name each column accordingly to facilitate working with this data frame.
```
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt", col.names = c("CODE", "LABEL"))
```

Add the `complete_activities` which contains the code of the activity of each row, as the first column of `complete_set`
```
complete_set <- cbind(complete_activities, complete_set)
```

Since the curent value of activity is the activity code, we can substitute for its respective label using the `activity_labels` data frame by asking for the LABEL column that corresponds to the current value of ACTIVITY
```
complete_set$ACTIVITY <- activity_labels[complete_set$ACTIVITY,"LABEL"]
```

# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

First we need to add the subject column to the data set, so we read it from the respective files.
```
subject_training <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", col.names = "SUBJECT")
subject_testing <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", col.names = "SUBJECT")
```

Per the convention set at the start, we put the rows from the training set first.
```
complete_subjects <- rbind(subject_training, subject_testing)
```

We add them as the first variable of our complete_set, which is finally, truly complete!
```
complete_set <- cbind(complete_subjects, complete_set)
```

Finally we use the dplyr package to group the set by both SUBJECT and ACTIVITY. For this, we sue the `group_by()` function and pass the result to the `summarize_eah()` function
asking the mean for each column and storing the result in a new data set.
```
library(dplyr)
tidy_averages <- group_by(complete_set, SUBJECT, ACTIVITY) %>%
  summarise_each(funs(mean))
```

# Write data set as a txt file
```
write.table(tidy_averages, file="./data/tidy_averages.txt", row.name=FALSE)
```
