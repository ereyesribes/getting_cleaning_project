# Getting and Cleaning Data Course Project

This repo is a submission for the Getting and Cleaning Data course project.
In this project we must clean up the "Human Activity Recognition Using Smartpones" Dataset by UCI.


## The Dataset

[Human Activity Recognition Using Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

## The Files

* CodeBook.md a code book that describes the variables, the data, and the transformations performed on it.
* run_analysis.R cleans up the file, following the specifications outlined in the project instructions:
  1. Merge the training and the test sets to create one data set.
  2. Extract only the measurements on the mean and standard deviation for each measurement.
  3. Use descriptive activity names for the activities in the data set.
  4. Appropriately label the data set with descriptive variable names.
  5. From the data set produced in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.
* tidy_dataset.csv is the result of steps 1-4, a clean dataset.
* averages.csv is the result of step 5, a separate dataset containing the average of every feature for each possible combination of activity+ssubject.
