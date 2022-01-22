#KD nuggets article on Missing values

#identifying outliers, scaling the data, normalizing, 
#library "dummies" for dummy variables
#Dummy, normalize, scatterplot to find outliers
#module 4 pg 13 reading in the data
#after scale dti

library(dplyr) #to reshape data
library(dummies)#create dummy variables
library(rgl) #3D plotting
library(cluster)#silhouette plots
library(fpc) #DBscan (Density-Based clustering)

load("lending_data_2017_Q2.rda")
View(lending_data)

#(kmeans is randomized so run "set.seed(12345)" first and that will be the same every time)
set.seed(12345)

######## Pre-processing steps:######################
#1 remove outliers before your rescale &  select the 5 columns 

#2 replace loan grades and remove the ones that correspond with outliers
##look at inner quartile range (%90) - part of your box plot, eliminate points ouside the wiskers
boxplot(lending_data$annual_inc)$stats #do for every variable  #can also do $out
boxplot(lending_data$loan_amnt)$stats#stats - first value is lower whisker, last is upper whisker 
#boxplot(lending_data$emp_length)$stats
#boxplot(lending_data$home_ownership)$stats
boxplot(lending_data$dti)$stats

inc_boxplot <- boxplot(lending_data$annual_inc)$stats
inc_outliers <- which(lending_data$annual_inc < inc_boxplot[1,1] | lending_data$annual_inc > inc_boxplot[5,1])
lending_data <- lending_data[-inc_outliers,]
inc_boxplot$out #values it gives for outliers
#nothing that gives you the rows thats why you use the which

hist(lending_data$annual_inc) ##histogram
sum(lending_data$annual_inc > 1000000) ## how many people make more than a million
  #you can see how much data your throwing away with different cutoff points
  #still have 98% of data if you make the cutoff at 200,000 just make it clear your not throwing out all the data and that is fine. 
  #just make it clear your not throwing out any of the data

#scatter-plot is great too
plot(lending_data$annual_inc, lending_data$dti)# debt to income ratio 
#can also use PCA to identify outlier

#Option 1
#replace employment length (n/a's)- fine to just create dummy variables
lending_data$emp_length[lending_data$emp_length == 'n/a'] <- NA #would make them missing values
lending_data$emp_length <- addNA(lending_data$emp_length) #make missing values its own level (addNA)
lending_data$emp_length <- as.character(lending_data$emp_length)
lending_data$emp_length <- sub("years", "", lending_data$emp_length)
lending_data$emp_length <- sub("< 1 year", "1", lending_data$emp_length)
lending_data$emp_length <- sub("1 year", "1", lending_data$emp_length)
lending_data$emp_length <- sub("10\\+ ", "10", lending_data$emp_length)
lending_data$emp_length <- as.numeric(lending_data$emp_length)
lending_data$emp_length[is.na(lending_data$emp_length)] <- median(lending_data$emp_length, na.rm=TRUE)


#Option 2
#making 1 numeric value
lending_data$emp_length <- as.character(lending_data$emp_length)  #factor to character
lending_data$emp_length <- sub("years", "", lending_data$emp_length)  #remove years
lending_data$emp_length <- sub("< 1 year", "1", lending_data$emp_length)  #assumption of 1
lending_data$emp_length <- sub("1 year", "1", lending_data$emp_length)  #replace with 1
lending_data$emp_length <- sub("10\\+ ", "10", lending_data$emp_length)  #over with 10
lending_data$emp_length <- as.numeric(lending_data$emp_length)  #numeric
lending_data$emp_length[is.na(lending_data$emp_length)] <- median(lending_data$emp_length, na.rm=TRUE) #impute missing values
plot(my_pca$x[,1:2], col=my_kmeans$cluster)
lending_data <- lending_data[-outliers,]

####################################################
#Selecting columns from data
lend_df <- lending_data %>%
  dplyr::select(annual_inc, loan_amnt, emp_length, home_ownership, dti)
summary(lend_df)

col = lend_df$loan_grade
col = lend_df$grade

#create dummy variable for each grade
lend_df <- dummy.data.frame(lending_data[,c("annual_inc", "loan_amnt", "emp_length", "home_ownership", "dti")],
                            names="grade")

#dummy.data.frame(lend_df, names=c(â€œemp_lengthâ€, â€œhome_ownership€))
#dummy.data.frame(lend.df$emp_length)
head(lending_df)


##Rescale your data once you remove your outliers & Create dummy Variables
#center/scale/normalize data
lending_df <- scale(lending_df, center=TRUE, scale=TRUE)
# Error in colMeans(x, na.rm = TRUE) : 'x' must be numeric
head(lending_df)

#cluster Dendrogram
lending_dist <- dist(lending_df)
lending_lclust <- lclust(lending_dist)
plot(lending_lclust)

lending_cut <- cutree(lending_lclust, k=7)
lending_cut[1:20]

lending_pca <- prcomp(lending_df, retx=TRUE)
plot(lending_pca$x[,1:2], col=lending_cut, pch=lending_cut)

lending_sil <- silhouette(lending_cut, lending_dist)
plot(lending_sil)

lending_kmeans <- kmeans(lending_df, centers=7)
plot(lending_pca$x[,1:2], col=lending_kmeans$cluster, pch=lending_kmeans$cluster)


lending_kmeans_sil <- silhouette(lending_kmeans$cluster, lending_dist)
plot(lending_kmeans_sil)


hist(lending_dist)
















