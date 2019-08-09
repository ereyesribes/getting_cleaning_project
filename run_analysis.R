library(data.table)

# This function takes care of getting the column for the human readable activities.
get_human_readable_activities <- function(set) {
  # Get the human readable activity labels
  label_codes = read.table('activity_labels.txt', sep = " ", header = F, col.names = c("number", "name"))

  # Read the activity data
  label_file = file(paste0(set, '/y_', set, '.txt'))
  labels = readLines(label_file)

  # Close file connections
  close(label_file)

  # Make activities human readable.
  factor(labels, levels = label_codes$number, labels = label_codes$name)
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

# Read test + train features.
features_test = read.table('test/X_test.txt',
  sep = "",
  header = F,
  col.names = fancy_feature_names
)

features_test$Set = "test"
features_test$Activity = get_human_readable_activities("test")

features_train = read.table('train/X_train.txt',
  sep = "",
  header = F,
  col.names = fancy_feature_names
)

features_train$Set = "train"
features_train$Activity = get_human_readable_activities("train")


features = rbind(features_test, features_train)

print(names(features))

# As a result of column names being coerced into dot-separated words, instead of spaces
# Some fields can have multiple dots, or dots at the end, which harm readability.
names(features) = gsub('\\.$', '',
  gsub('\\.+', '.',
    names(features)
  )
)


# TODO: SUBJECT.
# keep only STD & means (& set, activity.).
features = features[, grep("((Standard\\.Deviation|mean)|^Set$|^Activity$)", names(features))]


# Write out our tidy dataset.
write.csv(features, "tidy_dataset.csv")
