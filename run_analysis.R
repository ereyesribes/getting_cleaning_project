library(data.table)

get_human_readable_activities <- function() {
  # Get the human readable activity labels
  label_codes = read.table('activity_labels.txt', sep = " ", header = F, col.names = c("number", "name"))

  # Read the activity data
  label_train_file = file('train/y_train.txt')
  label_test_file = file('test/y_test.txt')
  label_train = readLines(label_train_file)
  label_test = readLines(label_test_file)


  # Make activities human readable.
  label = c(label_train, label_test)
  factor(label, levels = label_codes$number, labels = label_codes$name)
}


# Read feature names. then read X
feature_names = read.table('features.txt', sep = " ", header = F, col.names = c("discard", "feature"))

# Make the feature names more human readable.
fancy_feature_names = gsub('()', '',
  gsub('std', 'Standard Deviation ',
    gsub('Mag', 'Magnitude ',
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

# Read test + train features.
features_test = read.table('test/X_test.txt',
  sep = "",
  header = F,
  col.names = fancy_feature_names
)

features_test$set = "test"

features_train = read.table('train/X_train.txt',
  sep = "",
  header = F,
  col.names = fancy_feature_names
)

features_train$set = "train"

features = rbind(features_test, features_train)

# As a result of column names being coerced into dot-separated words, instead of spaces
# Some fields can have multiple dots, or dots at the end, which harm readability.
names(features) = gsub('\\.$', '',
  gsub('\\.+', '.',
    names(features)
  )
)

features$activity = get_human_readable_activities()

# keep only STD & means.
features = features[, grep("(std|mean)\\(\\)", feature_names$feature)]


# Write out our tidy dataset.
write.csv(features, "tidy_dataset.csv")
