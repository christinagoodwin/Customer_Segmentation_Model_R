# Customer Segmentation Model
A customer segmentation model using RFM analysis and k-means clustering to inform personalized marketing campaigns for an e-commerce business.

## Project Overview
This project aims to analyze the customer data of an e-commerce company to better understand customer behaviors and segment them into distinct groups based on their buying habits. This segmentation can inform targeted and personalized marketing campaigns. The model uses Recency, Frequency, and Monetary (RFM) value calculations to quantify customer value, followed by k-means clustering to group customers into segments.

## Data and Methodology
The data utilized in this project is sourced from UCI's Machine Learning Repository and is known as the "Online Retail Data Set". It contains information on transactions between 01/12/2010 and 09/12/2011 for a UK-based e-commerce store. 

The methodology involved a series of steps:
1. Data cleaning and pre-processing
2. Calculation of RFM metrics
3. Scaling of RFM data
4. Optimal cluster determination using elbow method
5. Customer segmentation using k-means clustering
6. Integration with Mailchimp API to automate sending personalized marketing emails based on customer segment

## Findings and Implications
The model successfully segmented the customers into distinct groups based on their buying behaviors. This segmentation can help the company to better understand their customer base and tailor their marketing efforts more effectively. By focusing on customers who have not made a purchase in a while but have shown previous engagement, the company can potentially increase customer retention and conversion rates.

## Future Directions
This model can be further improved by incorporating other relevant customer data such as demographics and product preferences. The time-series nature of the data also lends itself to survival analysis or cohort analysis, which could give additional insights into customer behavior over time.

## Code and Visualizations
All of the code for this project is contained in the R script "Customer_Segmentation_Model.R". The script is well-commented and contains everything from the data cleaning and pre-processing steps to the final customer segmentation and email automation.

## Dependencies
The following R packages are required to run the code:
- tidyverse
- readxl
- dplyr
- purrr
- ggplot2
- cluster
- NbClust
- clustertend
- factoextra
- httr
- jsonlite

## References
[Online Retail Data Set, UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/352/online+retail)
