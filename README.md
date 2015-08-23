# getting_and_cleaning_data__project

Knowing joining tables and grouping will be needed, I firstly load dplyr library.

```{r}
library(dplyr)
```

Then the data was downloaded and unzipped.

```{r}
download.file(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "HAR_dataset.zip")
unzip("HAR_dataset.zip", exdir = "HAR_dataset")
```

Both train and test data sets were downloaded into R. As the data about the 561 observed variables were stored seperately (in X_train/test.txt) from information about subjects (in subject_train/test.txt) and activitis (in y_train/test.txt), it was necessary to combine the information from all these 3 sources to create a complete train/test data set. To name the columns in the dataset appropriately, names "subject", "activity" and variable names found in features.txt were used.

```{r}
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
```

Next step was to merge train and test data sets to create one table.

```{r}
data <- bind_rows(train_data, test_data)
```

As the columns of the complete table were already named appropriately, using grep function only columns containing information about mean ("...mean()...") and standard deviation ("...std()...") could be easily selected and then included in a new table (subset of the previous one).

```{r}
mean_data <- data[,grep("mean\\(\\)",names(data))]
std_data <- data[,grep("std\\(\\)",names(data))]
data_subset <- bind_cols(data[,1:2],mean_data,std_data)
```

Afterwards numbers referring to a certain activity were replaced by the activity names. Names of the variables were also slightly changed in order to be a bit more readable.

```{r}
activity_labels <- read.table ("./HAR_dataset/UCI HAR Dataset/activity_labels.txt")
data_subset$activity <- sapply(data_subset$activity, function(index){activity_labels$V2[index]})
names(data_subset) <- sapply(names(data_subset), function(name){gsub("\\(\\)", "", gsub("-", "_", name))})
```

The last step was to create a data set with the average of each variable for each activity and each subject. This was done using the group_by function from the dplyr library. 

```{r}
tidy_data <- group_by(data_subset, subject, activity) %>% summarise_each(funs(mean))
write.table(tidy_data, "tidy_data.txt", row.names = FALSE)
```

