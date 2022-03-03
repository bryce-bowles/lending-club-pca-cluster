# Lending Club Cluster and Principal Component Analysis
Using loan data, performed a k-means cluster analysis to identify 7 groups or clusters and two principal component analyses (PCA) of borrowers by income, loan amount, employment length, home ownership status, and debt-to-income ratio. Explained all preprocessing steps. Performed PCA to identify characteristics of each cluster. Evaluated how clusters compare to assigning applicants to clusters by loan grade. Supported comparrison with visuals. ([Report](4_Assignment-3Cluster_Analysis_and_Principal_Component_Analysis.pdf))

 
## Data Preprocessing and Removing Outliers

You will find an attached file, “4_Assignment-3.R”, that describes each step in detail. The data was first loaded using the previous read in file lending_data_2017_Q2.rda. To narrow down the dataset to only what was needed, a dplyr function was used to select columns or filter out unneeded data. From there, it was essential to take a look at a summary of the data columns: 

![image](https://user-images.githubusercontent.com/65502025/155847292-3326bf55-42e2-46e9-b27b-b8fc51520330.png)

 
The highlighted values stand out, meaning all could possibly skew the data.

Data Preprocessing Issues Identified: 
*	At least one or a few individuals have a very high annual income in comparison to other quartiles, including the max of $8,900,000 
*	R thinks the employment length “n/a” is a character string – need to convert to numeric
*	Home ownership has levels of very few observation (ANY and NONE)
*	Debt to income ratio has 75 missing values and very high maximum, way higher than the 3rd Quartile

Steps that need to be taken to fix the issues:  
*	Annual Income: Identify, replace with the median or filter out outliers
*	Employment Length: Either 
   *	1) Replace the “n/a” with “N/A” so R recognizes it or
   * 2) Convert “n/a”s to 1 numeric value
*	Home Ownership: Recategorize ANY and NONE or remove from sample
*	Debt to Income Ratio: Remove or recategorize NA’s
*	Creating dummy variables for qualitative variables 

The process by which the outliers were identified and removed is: Outliers were first identified by looking at the summary (discussed above). Then, box plots, histograms, and scatter plots were used to that each Annual Income, Loan Amount, and Debt to Income Ratio had outliers to be removed. Each plot was very distorted meaning the data was very skewed. After removing the outliers, the data was replotted to determine if the amount removed/replaced was suffice. 

A “which” statement narrowed down the Annual Income’s outliers and removed about only %4 of the overall data. The loan amount needed no action taken and did not include outliers severe enough to remove. A R “dplyr” function was used to filter out the top 100 values of the Debt to Income Ratio, improving the dataset while keeping the dataset around %95 of its initial data. After this step, there were no longer 75 Debt to Income Ratio NA values. “n/a”s in the employment length were converted “n/a”s to 1 numeric value – using judgement to space out the years. And lastly, it was decided that ANY and NONE would be removed from the dataset. 

Next, a dummy variable was created for the Home ownership variable. Since loan grade was not needing to be scaled, a new value was created for it to be used later. It was removed from the dataset before scaling. After the preprocessing steps were completed, the data was then scaled and centered. 

## Kmeans Clustering with Principle Component Analysis
Kmeans was used to identify 7 groups or clusters. Many of the sample clusters can be partitioned (by color), but there are some that overlap – mainly cluster 6 with other clusters. Cluster 6 seems to overlap with cluster 2, 4 and slightly 1.  

The graph is difficult to assign clusters with strict characteristics because of the diagonal shape in relation to the principle components. Principle components were looked at first to see where the load was on each. On PC1, there are larger values on home ownership mortgage (to the right of the graph) and smaller values on home ownership rent (left of the graph). Esentually, to the right of the graph, you’ll see greater values in home ownership mortgage, annual income, loan amount and a little bit of employment length. To the left, you will find larger values for home ownership rent. The values toward the top of the graph are going to include larger values in home ownership own and debt to income ratio. On the bottom of the graph, you will find larger values in annual income, home ownership rent, and loan amount. So you could make an assumption that cluster 7 has larger values in annual income, home ownership rent, and loan amount. 
  
![image](https://user-images.githubusercontent.com/65502025/151872254-add035c1-6089-4c26-a003-ad7e80268c87.png)


![image](https://user-images.githubusercontent.com/65502025/151872240-bdb862bd-9f26-405f-b734-2653e654334e.png)

 
 ![image](https://user-images.githubusercontent.com/65502025/151872227-a1d88b5a-8f42-46b0-b4d6-a9be02fe2847.png)


## How clusters compare to assigning applicants to clusters by loan grade 
When comparing to loan grade, there is no distinction between the classifications, but you can see two different cluster shapes. 

![image](https://user-images.githubusercontent.com/65502025/151872193-8aecbb67-8cf0-42ef-a05f-8c57a2adf6f6.png)



