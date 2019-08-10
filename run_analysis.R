library(data.table)
library(dplyr)

download_dataset <- function() {
  dataset_url = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
  dest = 'data/dataset.zip'

  download.file(dataset_url, dest)
  unzip(dest, exdir = 'data/')

  file.remove(dest)
}

# This function takes care of getting the column for the human readable activities.
# This is invoked for both datasets, and takes care of step 3.
get_human_readable_activities <- function(set) {
  # Get the human readable activity labels
  label_codes = read.table('data/UCI HAR Dataset/activity_labels.txt', sep = " ", header = F, col.names = c("number", "name"))

  # Read the activity data
  label_file = file(paste0('data/UCI HAR Dataset/', set, '/y_', set, '.txt'))
  labels = readLines(label_file)

  # Close file connection
  close(label_file)

  # Make activities human readable.
  factor(labels, levels = label_codes$number, labels = label_codes$name)
}

get_subjects <- function(set) {
  # Read the subject data
  subject_file = file(paste0('data/UCI HAR Dataset/', set, '/subject_', set, '.txt'))
  subjects = readLines(subject_file)

  # Close file connection
  close(subject_file)

  subjects = factor(subjects, levels = 1:30, labels = 1:30)

  subjects
}

# Make the feature names more human readable.
make_fancy_feature_names <- function(feature_names) {
  gsub('()', '',
    gsub('std', 'Standard Deviation ',
      gsub('Mag', 'Magnitude ',
        gsub('Jerk', 'Jerk ',
          gsub('Gyro', 'Gyroscope ',
            gsub('Acc', 'Accelerometer ',
              gsub('fBody', 'Fourier Body ',
                gsub('tBody', 'Time Body ',
                  gsub('BodyBody', 'Body',
                    feature_names$feature
                  )
                )
              )
            )
          )
        )
      )
    )
  )
}

# Step 0. Fetch the dataset
download_dataset()

# Step 1. Merge training and test sets.
# Read feature names.
feature_names = read.table('data/UCI HAR Dataset/features.txt', sep = " ", header = F, col.names = c("discard", "feature"))

# This takes care of step 4. Doesn't get any more descriptive than this.
fancy_feature_names = make_fancy_feature_names(feature_names)

# Read test features.
features_test = read.table('data/UCI HAR Dataset/test/X_test.txt',
  sep = "",
  header = F,
  col.names = fancy_feature_names
)

features_test = cbind(Subject = get_subjects('test'), Activity = get_human_readable_activities("test"), features_test)

# Read train features
features_train = read.table('data/UCI HAR Dataset/train/X_train.txt',
  sep = "",
  header = F,
  col.names = fancy_feature_names
)

features_train = cbind(Subject = get_subjects('train'), Activity = get_human_readable_activities("train"), features_train)

# Concatenate both datasets.
features = rbind(features_test, features_train)

# As a result of column names being coerced into dot-separated words, instead of spaces
# Some fields can have multiple dots, or dots at the end, which harm readability.
names(features) = gsub('\\.$', '',
  gsub('\\.+', '.',
    names(features)
  )
)


# Step 2: Extracts only measurements on mean & SD for each measurement.
features = features[, grep("^(?!angle).*((Standard\\.Deviation|mean(\\.|$))|^Set$|^Activity$|^Subject$)", names(features), ignore.case = T, perl = T)]

features = arrange(features, Subject, Activity)


# Write out our tidy dataset.
write.csv(features, "tidy_dataset.csv")

# Step 5: Make a dataset with the averages for every subject + activity combo.
averages = features %>% group_by(Subject, Activity) %>% summarise_all(mean) %>% arrange(Subject, Activity)

write.csv(averages, "averages.csv")
