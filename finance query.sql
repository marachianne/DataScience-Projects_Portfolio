create database FINANCE;
select * from finance;

#Which country generates the highest sales and profit?
SELECT Country, 
       SUM(Sales) AS Total_Sales, 
       SUM(Profit) AS Total_Profit
FROM finance
GROUP BY Country
ORDER BY Total_Sales DESC;

#How do sales vary across different months?
SELECT Year, Month_Name,
       SUM(Sales) AS Total_Sales
FROM finance
GROUP BY Year, Month_Number,Month_Name
ORDER BY Year, Month_Number;


#How do sales vary across different months?
SELECT Discount_Band, 
       SUM(Units_Sold) AS Total_Units_Sold, 
       SUM(Profit) AS Total_Profit
FROM finance
GROUP BY Discount_Band
ORDER BY Discount_Band;

#Which products generate the highest and lowest revenue?
SELECT Product, 
       SUM(Sales) AS Total_Sales, 
       SUM(Profit) AS Total_Profit
FROM finance
GROUP BY Product
ORDER BY Total_Sales DESC;


#How do product prices compare to manufacturing costs?
SELECT Product, 
       AVG(Manufacturing_Price) AS Avg_Manufacturing_Price, 
       AVG(Sale_Price) AS Avg_Sale_Price,
       (AVG(Sale_Price) - AVG(Manufacturing_Price)) AS Avg_Profit_Per_Unit
FROM finance
GROUP BY Product
ORDER BY Avg_Profit_Per_Unit DESC;


#What is the profit margin for each product?
SELECT Product, 
       SUM(Profit) / SUM(Sales) * 100 AS Profit_Margin
FROM finance
GROUP BY Product
ORDER BY Profit_Margin DESC;


#How has sales performance changed over the years?
SELECT Year, 
       SUM(Sales) AS Total_Sales,
       LAG(SUM(Sales)) OVER (ORDER BY Year) AS Previous_Year_Sales,
       ((SUM(Sales) - LAG(SUM(Sales)) OVER (ORDER BY Year)) / 
       LAG(SUM(Sales)) OVER (ORDER BY Year)) * 100 AS Sales_Growth_Percentage
FROM finance
GROUP BY Year
ORDER BY Year;


#When are the best months for sales?
SELECT Month_Name, 
       SUM(Sales) AS Total_Sales
FROM finance
GROUP BY Month_Name
ORDER BY Total_Sales DESC;


#Which customer segment generates the most revenue?
SELECT Segment, 
       SUM(Sales) AS Total_Sales, 
       SUM(Profit) AS Total_Profit
FROM finance
GROUP BY Segment
ORDER BY Total_Sales DESC;


#Which segment is the most profitable?
SELECT Segment, 
       SUM(Profit) AS Total_Profit,
       (SUM(Profit) / SUM(Sales)) * 100 AS Profit_Margin
FROM finance
GROUP BY Segment
ORDER BY Total_Profit DESC;

#How do sales grow over time?
SELECT Year, Month_Name, 
       SUM(Sales) AS Monthly_Sales,
       LAG(SUM(Sales)) OVER (PARTITION BY Year ORDER BY Month_Number) AS Previous_Month_Sales,
       ((SUM(Sales) - LAG(SUM(Sales)) OVER (PARTITION BY Year ORDER BY Month_Number)) / 
       LAG(SUM(Sales)) OVER (PARTITION BY Year ORDER BY Month_Number)) * 100 AS MoM_Growth
FROM finance
GROUP BY Year, Month_Number, Month_Name
ORDER BY Year, Month_Number;

#Are Discounts Increasing or Decreasing Profits?
SELECT Discount_Band, 
       SUM(Units_Sold) AS Total_Units_Sold, 
       SUM(Sales) AS Total_Sales, 
       SUM(Profit) AS Total_Profit,
       (SUM(Profit) / SUM(Sales)) * 100 AS Profit_Margin
FROM finance
GROUP BY Discount_Band
ORDER BY Discount_Band;

#Best & Worst Performing Products
(
    SELECT Product, 
           SUM(Sales) AS Total_Sales, 
           SUM(Profit) AS Total_Profit
    FROM finance
    GROUP BY Product
    ORDER BY Total_Profit DESC
    LIMIT 5
) 
UNION ALL
(
    SELECT Product, 
           SUM(Sales) AS Total_Sales, 
           SUM(Profit) AS Total_Profit
    FROM finance
    GROUP BY Product
    ORDER BY Total_Profit ASC
    LIMIT 5
);

#Does increasing the sale price reduce the number of units sold?
SELECT Product, 
       AVG(Sale_Price) AS Avg_Sale_Price, 
       AVG(Units_Sold) AS Avg_Units_Sold, round(
       (AVG(Units_Sold) / NULLIF(AVG(Sale_Price), 0)),2) AS Price_Elasticity
FROM finance
GROUP BY Product
ORDER BY Price_Elasticity DESC;