# Data Loading
library(tidyverse)
library(readxl)


online_retail_data <- read_excel("Online Retail.xlsx") %>%
                      na.omit(online_retail_data)

# Data Cleaning and Pre-processing
library(dplyr)

# We will assume the 'InvoiceDate' column is the data of purchase, 
# and the 'CustomerID' is the ID of the customer.
# Lastly, the 'UnitPrice' is the cost of the price per unit.

str(online_retail_data)
sum(is.na(online_retail_data))

# All of our data seems to be formatted correctly, and free of any missing values.
# Since our time is POSIXct, there is no need to convert the date.
# We will now store the last date of the data
last_date <- max(online_retail_data$InvoiceDate)

# We will also create a new column for total amount
online_retail_data <- mutate(online_retail_data, TotalAmount = UnitPrice * Quantity) 

#Calculating RFM metrics
customers <- online_retail_data %>%
              group_by(CustomerID) %>%
              summarise(Recency = as.numeric(last_date - max(InvoiceDate)),
                        Frequency = n(),
                        Monetary = sum(TotalAmount))

# Now that we have created RFM metrics of our customers, we will now segment them.
# We will use a k-means clustering algorithm
# Firstly, we need to determine an optimal numbers of cluster.
#So we will create a scree plot.

library(purrr)
library(ggplot2)
library(cluster)
library (NbClust)
library (clustertend)
library (factoextra)

# Now that we have created RFM metrics of our customers, we will now segment them.
# We will use a k-means clustering algorithm
# Firstly, we need to determine an optimal numbers of cluster.
#So we will create a scree plot.

# Scaling the RFM Data
rfm_data <- scale(customers[,2:4])

# The range of k values that will be run
k_values <- 2:15

#Calculating the within-cluster sum of squares (WSS)
wss <- wss <- map_dbl(k_values, function(k) {
  kmeans(rfm_data, centers = k)$tot.withinss
})

# Scree Plot
# Create an elbow plot
elbow_plot <- tibble(k = k_values, wss = wss) %>%
  ggplot(aes(x = k, y = wss)) +
  geom_line() +
  geom_point() +
  labs(x = "Number of clusters (k)", y = "Within-cluster Sum of Squares (WSS)") +
  ggtitle("Elbow Plot") +
  theme_minimal()

# Display the elbow plot
print(elbow_plot)

# It seems that 6 clusters might be best, but I want to do a silhouette analysis to make sure.

set.seed(456)
k_means <- kmeans(rfm_data, centers = 6)
customers$cluster <- k_means$cluster

# Define function to calculate mode
calculate_mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

# Add cluster assignment back to original data
online_retail_data <- online_retail_data %>%
  inner_join(customers, by = "CustomerID")

# Group by CustomerID and cluster, then summarise the other columns
customer_cluster_info <- online_retail_data %>%
  group_by(CustomerID, cluster) %>%
  summarise(
    most_common_stockcode = calculate_mode(StockCode),
    most_common_country = calculate_mode(Country),
    item = names(which.max(table(Description))),
    Recency = first(Recency),
    Frequency = first(Frequency),
    Monetary = first(Monetary),
    .groups = "drop"
  )

customer_cluster_info

## MOCK MAILCHIMP EMAIL DELIVERY

# Install required packages
install.packages("httr")
install.packages("jsonlite")

# Load required packages
library(httr)
library(jsonlite)

# Function to send email to customers
send_email_to_customers <- function(df) {
  # Mailchimp API URL
  url <- "https://usX.api.mailchimp.com/3.0/campaigns" # replace "usX" with your datacenter
  
  # Mailchimp API key
  api_key <- "your_api_key" # replace with your actual Mailchimp API key
  
  for(i in 1:nrow(df)) {
    # Define the email body
    body <- list(
      recipients = list(list(email_address = df[i, 'Email'], 
                             email_type = "html")),
      settings = list(subject_line = "Personalized Recommendations Based on Your Purchases", 
                      from_name = "Your Name", 
                      reply_to = "your-email@example.com"),
      template = list(
        id = "your_template_id", 
        sections = list(
          item = df[i, 'item'],
          Recency = df[i, 'Recency'],
          Frequency = df[i, 'Frequency'],
          Monetary = df[i, 'Monetary']
        )
      )
    )
    
    # Make the POST request
    response <- POST(url, body = body, encode = "json", 
                     authenticate("anystring", api_key, type = "basic"),
                     add_headers("Content-Type" = "application/json"))
    
    # Check the status of the request
    if(response$status_code == 200) {
      print(paste("Email sent successfully to", df[i, 'Email']))
    } else {
      print(paste("Failed to send email to", df[i, 'Email']))
    }
  }
}

# Call the function
send_email_to_customers(customer_cluster_info)

## Please note that you must:
## 1. Replace "your_api_key" with an actual Mailchimp API key
## 2. Replace "usX" in the URL with the datacenter that corresponds to the account.
## 3. Replace "your-email@example.com" with the email to send from.
## 4. Replace "your_template_id" with the actual id of the template.
## 5. The original data frame does not include any actual emails.
