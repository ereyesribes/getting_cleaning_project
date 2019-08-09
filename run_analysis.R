library(data.table)

# This function takes care of getting the column for the human readable activities.
get_human_readable_activities <- function(set) {
  # Get the human readable activity labels
  label_codes = read.table('activity_labels.txt', sep = " ", header = F, col.names = c("number", "name"))

  # Read the activity data
  label_file = file(paste0(set, '/y_', set, '.txt'))
  labels = readLines(label_file)

  # Close file connection
  close(label_file)

  # Make activities human readable.
  factor(labels, levels = label_codes$number, labels = label_codes$name)
}

get_subjects <- function(set) {
  # Read the subject data
  subject_file = file(paste0(set, '/subject_', set, '.txt'))
  subjects = readLines(subject_file)

  # Close file connection
  close(subject_file)

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

# Read feature names. then read X
feature_names = read.table('features.txt', sep = " ", header = F, col.names = c("discard", "feature"))

fancy_feature_names = make_fancy_feature_names(feature_names)

# Read test features.
features_test = read.table('test/X_test.txt',
  sep = "",
  header = F,
  col.names = fancy_feature_names
)

# Make Subject+Activity columns
Activity = get_human_readable_activities("test")
Subject = get_subjects('test')

features_test = cbind(Subject, Set, Activity, features_test)


# Read train features
features_train = read.table('train/X_train.txt',
  sep = "",
  header = F,
  col.names = fancy_feature_names
)

# Make subject+Activity columns
Activity = get_human_readable_activities("train")
Subject = get_subjects('train')

features_train = cbind(Subject, Activity, features_train)

# Concatenate both datasets.
features = rbind(features_test, features_train)

# As a result of column names being coerced into dot-separated words, instead of spaces
# Some fields can have multiple dots, or dots at the end, which harm readability.
names(features) = gsub('\\.$', '',
  gsub('\\.+', '.',
    names(features)
  )
)


# keep only STD & means (& set, activity.).
features = features[, grep("((Standard\\.Deviation|mean)|^Set$|^Activity$|^Subject$)", names(features))]


# Write out our tidy dataset.
write.csv(features, "tidy_dataset.csv")
