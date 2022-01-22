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
#(kmeans is randomized so run "set.seed(12345)" first and that will be the same every time)
set.seed(12345)


load("lending_data_2017_Q2.rda")
View(lending_data)


#Selecting columns from data
lend_df <- lending_data %>%
  dplyr::select(annual_inc, loan_amnt, emp_length, home_ownership, dti, grade)
summary(lend_df)

######## Pre-processing steps:####################################################
#1 remove outliers before your rescale &  select the 5 columns 
#2 replace loan grades and remove the ones that correspond with outliers


#########  Annual Income  #########
#before plots:
inc_boxplot <- boxplot(lend_df$annual_inc)$stats #stats - first value is lower whisker, last is upper whisker 
hist(lend_df$annual_inc)

#conversion (removing outliers):
inc_outliers <- which(lend_df$annual_inc < inc_boxplot[1,1] | lend_df$annual_inc > inc_boxplot[5,1])
lend_df2 <- lend_df[-inc_outliers,] #creates new set without outliers

#after plots:
inc_boxplot <- boxplot(lend_df2$annual_inc)$stats #stats - first value is lower whisker, last is upper whisker 
hist(lend_df2$annual_inc) 

#***this process only removed about %5 of the data. Is acceptable since we still have over 100,000 observations

#another option is to view how many annual_inc observations were greater than 
  #sum(lend_df2$annual_inc > 200000) ## how many people make more than a million
  #you can see how much data your throwing away with different cutoff points
  #still have 97% of data if you make the cutoff at 200,000 "just make it clear your not throwing out all the data". 


#########  Loan Amount  #########
boxplot(lend_df2$loan_amnt)$stats
#data looks okay, no need to modify



#########  Debt to Income Ratio (dti)  #########
#before plots:
dti_boxplot <- boxplot(lend_df2$dti)$stats 
hist(lend_df2$dti)
plot(lend_df2$annual_inc, lend_df2$dti)

#conversion (removing outliers):
lend_df3 <- lend_df2 %>% dplyr::filter(!dti > 100 & !dti == 0 )
#still %95 of the data left

#option 2
#dti_outliers <- which(lend_df2$dti < dti_boxplot[1,1] | lend_df2$dti > dti_boxplot[5,1])
#lend_df3 <- lend_df2[-dti_outliers,]

#after plots:
boxplot(lend_df3$dti)$stats
hist(lend_df3$dti)
plot(lend_df3$annual_inc, lend_df3$dti)
summary(lend_df3)
#The NA's have been removed from previous steps


#########  Employment Length  #########
#Option 1 - replace with NA
#replace employment length (n/a's)- "fine to just create dummy variables"
#lend_df$emp_length[lend_df$emp_length == 'n/a'] <- NA #would make them missing values
#lend_df$emp_length <- addNA(lend_df$emp_length) #make missing values its own level (addNA)
#lend_df$emp_length <- as.character(lend_df$emp_length)
#lend_df$emp_length <- sub("years", "", lend_df$emp_length)
#lend_df$emp_length <- sub("< 1 year", "1", lend_df$emp_length)
#lend_df$emp_length <- sub("1 year", "1", lend_df$emp_length)
#lend_df$emp_length <- sub("10\\+ ", "10", lend_df$emp_length)
#lend_df$emp_length <- as.numeric(lend_df$emp_length)
#lend_df$emp_length[is.na(lend_df$emp_length)] <- median(lend_df$emp_length, na.rm=TRUE)

#Option 2 - making na's 1 numeric value
lend_df3$emp_length <- as.character(lend_df3$emp_length)  #factor to character
lend_df3$emp_length <- sub("years", "", lend_df3$emp_length)  #remove years
lend_df3$emp_length <- sub("< 1 year", "1", lend_df3$emp_length)  #assumption of 1
lend_df3$emp_length <- sub("1 year", "1", lend_df3$emp_length)  #replace with 1
lend_df3$emp_length <- sub("10\\+ ", "10", lend_df3$emp_length)  #over with 10
lend_df3$emp_length <- as.numeric(lend_df3$emp_length)  #numeric
lend_df3$emp_length[is.na(lend_df3$emp_length)] <- median(lend_df3$emp_length, na.rm=TRUE) #impute missing values
# plots: 
boxplot(lend_df3$emp_length)$stats
hist(lend_df3$emp_length)
plot(lend_df3$annual_inc, lend_df3$emp_length)


#########  Home Ownership  #########
#filter home ownership to not include "ANY" or "NONE" because they barely have values
lend_df3 <- filter(lend_df3, home_ownership %in% c("MORTGAGE", "OWN", "RENT"))

summary(lend_df3)


#dummy for home_ownership
lend_df3 <- dummy.data.frame(lend_df3, names = 'home_ownership')
#lend_df3 <- dummy.data.frame(lend_df3, names = 'grade')#don't need to create dummy variable for grade? 
head(lend_df3)



######## Preprocessing Complete #########
#removing grade
loan_grade <- lend_df3$grade
lend_df3 <- lend_df3 %>% select(-grade)


#center/scale/normalize data
lend_df3 <- data.frame(scale(lend_df3, center=TRUE, scale=TRUE))
head(lend_df3)

#cutree function: unable to perform, "Error: cannot allocate vector of size 37.2 Gb"

#Kmeans
lend_kmeans <- kmeans(lend_df3, centers = 7)
lend_pca <- prcomp(lend_df3, retx = TRUE)
plot(lend_pca$x[,1:2], col=lend_kmeans$cluster, pch=lend_kmeans$cluster)
legend("topright", legend=1:7, col=1:7, pch=1:7)
summary(lend_pca)


lend_pca$rotation


head(lend_pca$x)


plot(lend_pca)

#lend_dbscan <- dbscan(lend_df3, eps=2)
plot(lend_pca$x[,1:2], col=as.numeric(loan_grade), pch=as.numeric(loan_grade))
legend("topright", legend=1:7, col=1:7, pch=1:7)

plot(lend_pca$x[,1:2], col=lend_kmeans$cluster)
legend("topright", legend=1:7, col=1:7, pch=1:7)

#just for curiosity
plot3d(lend_pca$x[,1:3],col=lend_kmeans$cluster)













