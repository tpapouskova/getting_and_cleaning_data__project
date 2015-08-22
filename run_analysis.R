library(dplyr)

# download data and unzip it 

download.file(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "HAR_dataset.zip")
unzip("HAR_dataset.zip", exdir = "HAR_dataset")

# load both train and test data into R; create seperate train and test tables containing subject IDs, activity labels and measurements and name columns appropriately
variable_names <- read.table("./HAR_dataset/UCI HAR Dataset/features.txt")

train_set <- read.table("./HAR_dataset/UCI HAR Dataset/train/X_train.txt")
names(train_set) <- variable_names$V2
train_labels <- read.table("./HAR_dataset/UCI HAR Dataset/train/y_train.txt", col.names = "activity")
train_subjects <- read.table("./HAR_dataset/UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
train_data <- bind_cols(train_subjects, train_labels, train_set)

test_set <- read.table("./HAR_dataset/UCI HAR Dataset/test/X_test.txt")
names(test_set) <- variable_names$V2
test_labels <- read.table("./HAR_dataset/UCI HAR Dataset/test/y_test.txt", col.names = "activity")
test_subjects <- read.table("./HAR_dataset/UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
test_data <- bind_cols(test_subjects, test_labels, test_set)

# merge train and test data in one table

data <- bind_rows(train_data, test_data)

# extract only measurements on the mean and standard deviation

mean_data <- data[,grep("mean\\(\\)",names(data))]
std_data <- data[,grep("std\\(\\)",names(data))]
data_subset <- bind_cols(data[,1:2],mean_data,std_data)

# name activities accordingly (use a label instead of a number)

activity_labels <- read.table ("./HAR_dataset/UCI HAR Dataset/activity_labels.txt")
data_subset$activity <- sapply(data_subset$activity, function(index){activity_labels$V2[index]})

# label the data set with descriptive variable names

names(data_subset) <- sapply(names(data_subset), function(name){gsub("\\(\\)", "", gsub("-", "_", name))})

# create tidy data set with the average of each variable for each activity and each subject

tidy_data <- group_by(data_subset, subject, activity) %>% summarise_each(funs(mean))

write.table("tidy_data.txt", row.names = FALSE)
