# Data Science Application Challenge- Summer 2019

My submission to the Shopify data science internship challenge for summer of 2019. Note this repository will remain private until the submission deadline (Jan 15, 2019) 

## Prerequisites

I wrote all my queries for MySQL v5.7 as this is default for the provided [Fiddle](https://www.db-fiddle.com/f/svQD6mgBJDcykiJAd4oe8w/7)

### Assumptions
* No two or more merchants sell the product.id
* order_items.price is adjusted accordingly for order_items.quantity 


## Questions
#### 1) Are there incidences of shops are increasing their prices? Does it occur on a regular basis?
We can write a simple query to figure this out. From the orders table I can join each order with each product within it. Then I join each product with its respective parent product. 
Query also located in the [Shopify1.sql](Shopify1.sql) file 
```
SELECT product_variations.product, 
    order_items.quantity,
    order_items.price,
    orders.placed_on
FROM orders 
INNER JOIN order_items 
ON orders.id = order_items.order
INNER JOIN product_variations
ON order_items.product_variation = product_variations.id
ORDER BY product_variations.product, orders.placed_on
```
First 5 rows of result:

| product | quantity |  price |       placed_on      |
|---------|----------|--------|----------------------|
|    1    |    2     | 91.44  | 2014-01-10 09:23:48  |
|    1    |    2     | 91.66  | 2014-02-16 16:09:51  |
|    1    |    3     | 93.69  | 2015-01-15 17:52:33  |
|    1    |    3     | 93.09  | 2015-01-20 23:39:51  |
|    1    |    1     | 94.41  | 2015-02-15 11:18:16  |

Clearly, shops are increasing and decreasing their prices as seen in the trend above (which is consistent across all data). 

It is impossible to tell whether price adjustments occur on a regular basis as we only know if the price is adjusted after a product is sold. Thus, multiple price adjustments could occur on a product without our knowledge between purchases. 

#### 2) What is the average annual price increase of products in this database, if any.
Since I'm limited to only using MySQL this query gets a little more complicated. I'll breakdown my thinking as much as I can below.
Note: this could be optimized fairly easily into fewer queries and tables, but I chose to display it in the following form because I think it is far more readable.

First I recreate the query from the first question to reference throughout
```
-- Create table from 1)
CREATE TABLE product_orders AS
  SELECT product_variations.product,
    order_items.quantity,
    order_items.price,
    orders.placed_on
  FROM orders
  INNER JOIN order_items
  ON orders.id = order_items.order
  INNER JOIN product_variations
  ON order_items.product_variation = product_variations.id
  ORDER BY product_variations.product, orders.placed_on;
```
Then using the MIN() function I identify the first transaction of each year per product.
```
-- Find the first transaction (min) of each year
CREATE TABLE first_dates AS
  SELECT product_orders.product as products,
    MIN(CASE WHEN YEAR(placed_on) = '2014' THEN placed_on END) AS 'first_four',  --2014
    MIN(CASE WHEN YEAR(placed_on) = '2015' THEN placed_on END) AS 'first_five',  --2015
    MIN(CASE WHEN YEAR(placed_on) = '2016' THEN placed_on END) AS 'first_six',   --2016
    MIN(CASE WHEN YEAR(placed_on) = '2017' THEN placed_on END) AS 'first_seven', --2017
    MIN(CASE WHEN YEAR(placed_on) = '2018' THEN placed_on END) AS 'first_eight'  --2018
  FROM product_orders
  GROUP BY product_orders.product;
```
First 5 rows of result:

| products |     first_four      |      first_five     |       first_six     |     first_seven     |     first_eight     |
|----------|---------------------|---------------------|---------------------|---------------------|---------------------|
|    1     | 2014-01-10 09:23:48 | 2015-01-15 17:52:33 | 2016-01-24 17:31:50 | 2017-01-17 03:37:57 | 2018-09-13 06:18:24 |
|    2     | 2014-01-14 07:27:17 | 2015-01-15 17:52:33 | 2016-01-16 16:01:48 | 2017-01-08 10:57:05 | 2018-02-08 20:29:16 |
|    3     | 2014-01-14 20:03:43 | 2015-02-03 05:28:14 | 2016-09-26 09:13:35 | 2017-01-08 10:57:05 | 2018-02-06 01:14:53 |
|    4     | 2014-01-10 09:23:48 | 2015-01-15 17:52:33 | 2016-03-04 13:45:04 | 2017-01-08 10:57:05 | 2018-11-20 14:02:41 |
|    5     | 2014-02-17 01:25:58 | 2015-01-01 09:17:13 | 2016-01-24 17:31:50 | 2017-07-03 11:26:47 | 2018-04-23 02:30:28 |

The same is done to identify the date of the last transaction of each year using the MAX() function


Next I joined the date of the first transaction of each year with its respective transaction
```
-- Join first transaction with its respective price
CREATE TABLE first_prices AS
  SELECT DISTINCT first_dates.products,
    four_prices.price  AS first_four_price,
    five_prices.price  AS first_five_price,
    six_prices.price   AS first_six_price,
    seven_prices.price AS first_seven_price,
    eight_prices.price AS first_eight_price
  FROM first_dates
  INNER JOIN product_orders AS four_prices
  ON four_prices.placed_on = first_four AND four_prices.product = products
  INNER JOIN product_orders AS five_prices
  ON five_prices.placed_on = first_five AND five_prices.product = products
  INNER JOIN product_orders AS six_prices
  ON six_prices.placed_on = first_six AND six_prices.product = products
  INNER JOIN product_orders AS seven_prices
  ON seven_prices.placed_on = first_seven AND seven_prices.product = products
  INNER JOIN product_orders AS eight_prices
  ON eight_prices.placed_on = first_eight AND eight_prices.product = products;
```
First 5 rows of result:

| products | first_four_price | first_five_price | first_six_price | first_seven_price | first_eight_price |
|----------|------------------|------------------|-----------------|-------------------|-------------------|
|    1     |    91.44	      |  93.69	         |    95.56        |  98.24	           |  101.46           |     
|    2     |    10.87	      |  10.98           | 	  11.19	       |  11.54	           |  11.77            |
|    3     |    362.23	      |  366.97	         |    381.01	   |  384.63	       |  392.42           | 
|    3     |    362.23	      |  366.97          |    381.01	   |  384.59           |  392.42           |
|    4     |    23.8	      |  24.48	         |    25.28        |  25.58            |  26.72            |    

You might wounder why there are multiple rows for one product (i.e product 3 above). This occurs when two or more purchases are made at the exact same time stamp but have slightly different corresponding prices. I assume this discrepancy is related to transaction fees or is simply due to erroneous data. Later to overcome this issue, I average the difference in prices and use the result to calculate the yearly change in price.

I use the same query to join the last transaction of each year with its price

Next, I calculate the price change for each year, per product. Note: the AVG() function is used as discussed above, to overcome the issue of when two transactions occur at the same time stamp. 
```
-- Average repeat sales with slightly different prices and calculate difference
CREATE TABLE change_in_prices AS
  SELECT last_prices.products,
    AVG(last_prices.last_four_price)  - AVG(first_prices.first_four_price)  AS 'four',
    AVG(last_prices.last_five_price)  - AVG(first_prices.first_five_price)  AS 'five',
    AVG(last_prices.last_six_price)   - AVG(first_prices.first_six_price)   AS 'six',
    AVG(last_prices.last_seven_price) - AVG(first_prices.first_seven_price) AS 'seven',
    AVG(last_prices.last_eight_price) - AVG(first_prices.first_eight_price) AS 'eight'
  FROM last_prices
  INNER JOIN first_prices
  ON first_prices.products = last_prices.products
  GROUP BY products;
```

First 5 rows of result 

| products | four    | five   | six    | seven  | eight  |
|----------|---------|--------|--------|--------|--------|
| 1        | 0.2200  | 1.9300 | 0.8750 | 1.7600 | 0      |
| 2        | 0.1000  | 0.2200 | 0.2300 | 0.1800 | 0.1799 |
| 3        | 1.5399  | 7.8899 | 0      | 6.3499 | 7.5999 |
| 4        | 0.9200  | 0.5600 | 0.3099 | 0.5300 | 0      |
| 5        | 0.1700  | 0.2799 | 0.1700 | 0.0299 | 0.125  |

Now that the price change difference for each product is calculated, simply using the AVG() function on each column will give us the average change each year.
```
-- calculate yearly average
CREATE TABLE yearly_avg AS
  SELECT AVG(four) AS 'four_avg',
    AVG(five)    AS 'five_avg',
    AVG(six)     AS 'six_avg',
    AVG(seven)   AS 'seven_avg',
    AVG(eight)   AS 'eight_avg'
  FROM change_in_prices;
```
Result:

| four_avg | five_avg | six_avg  | seven_avg | eight_avg |
|----------|----------|----------|-----------|-----------|
| 0.7274   | 0.8588   | 0.6487   | 0.6337    | 0.5994    |

Finally from this the average price increase for all years can be calculated by finding the average on each column
```
-- calculate final average price increase for all years
SELECT (four_avg + five_avg + six_avg + seven_avg + eight_avg)/5
	AS average_annual_price_increase
FROM yearly_avg;
```
Thus I calculated the average annual price increase to be 0.63% based on the first and last purchases made each year between 2014 and 2018. Technically, this is not correct as the actual price is not known at the beginning and end of each year, but most products have sales very close to the beginning and end of each year making my representation a reasonably close measure. No indication was given of the date the data was retrieved, so I did not incorporate the currently listed price from the products table.


#### 3) If it were being redeveloped, what changes would you make to the database schema given to make it more flexible?

As hinted at in the introduction to the problem, it would be useful if changes merchants have made to product prices were recorded in the database, then a real answer could be given in #2. 

I also think it could be useful to break down items into categories. Doing this may provide more insight into the data when analysing for features/phenomena like ones described in the problem statement. Some categories like Apple Electronics might have a static price which rarely changes or some categories might fluctuate in price far more often than others. 

Changing to a noSQL database would be the ultimate form of flexibility as data would be unstructured.

#### 4) Does the query (/queries) you wrote scale? What if there were hundreds of thousands of products, customers, variations and orders? What changes might you make to your technique, or the database itself, to optimize this sort of analysis?

Currently, my queries are currently dependent upon the fact that we are only analysing years 2014 - 2018 (as I am not aware of any way to avoid manually searching for different years in mySQL v5.7). If more data were added for 2019, an extra year column would need to be added to each table to represent this. 

Obviously, creating tables for only one use is not the most efficient option. To make the most scalable/efficient query, it would be ideal to use one big query followed by many sub-queries. If I was tasked with this job without the constraint of only using mySQL queries, I would export the data obtained from my query in Part #1 and interpret it in Python. Since no more data is needed after the first query, a Python script would be a lot more scalable. This Python script could easily be written to require no changes no matter how much the data changes because it is a Turing complete language, unlike mySQL.

Another possible improvement is changing to a noSQL database like MongoDB. It is possible unstructured data is more suitable for this particular use case. Instead of joining product tables, order tables, customer tables, etc., one table could store most of this information (i.e., primary key represents merchant who has an array of transactions with an array of items in each transaction).

Finally, more resources could be allocated to the mySQL server to increase indexing speed.

#### 5) Without rewriting it, how would your analysis change if the prices were presented in multiple currencies?

Assuming data were available on what transactions occurred in what currency, my analysis would not have to change much. First, I would store a table of conversion rates, and then define one master currency. Finally, when selecting a price I would just multiply it by the appropriate conversion rate. 

#### 6) Based on your findings above, would you recommend building the new feature? Why or why not?

According to [this](https://www.statista.com/statistics/256598/global-inflation-rate-compared-to-previous-year/), global (and Canadian) inflation rate is much larger than the 0.61% I calculated from the data, so at first glance, a new feature to help merchants seems justified. However, I believe further analysis should be conducted before continuing. In particular, I would like to address and ideally resolve the following concerns I have

Currently, my data points for the yearly average price increase are taken at the closest purchase to the beginning and end of each year. It is possible that holiday sales (i.e Christmas, boxing day, and new years) affect these data points making them unreliable, so perhaps data points should be taken later in the year?
Some products have sales of 0-1 orders in a year, my analysis does not account for this, making them have a yearly change of 0 which could lead to inaccuracies.
It could be useful to break products down into different categories. Is it possible different categories have different average price increases? Then perhaps this should be included in the feature.



## License

This project is licensed under the Beerware License - see the [LICENSE.md](LICENSE.md) file for details

