# Decentral Infosec

![photo_2022-08-09_21-06-12](https://user-images.githubusercontent.com/3188163/183788375-82863742-2127-4fcb-b7b1-5b16506c5fc0.jpg)

Platform for analyzing EVM blockchain transactions in order to identify potentially fraudulent transactions before they are mined.

## Machine Learning analysis of transactions
In order to analyze blockchain transactions machine learning is being used, specifically the ML.NET SDK. Since the platform tries to predict one of two classes (fraudulent or not), binary classification algorithms should be used. One of the most commonly used algorithms for such tasks is **Fast Tree**, which is an implementation of so called MART (Multiple Additive Regression Trees) algorithm.

### Steps invloved in the machine learning analysis
- Prepare train transactions data set (where each record is clearly marked as fraudulent or not)
- Create the ML model
- Run test transactions through the model
