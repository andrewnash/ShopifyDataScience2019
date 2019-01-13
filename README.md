# Data Science Application Challenge- Summer 2019

My submission to the Shopify data science internship challenge for summer of 2019. Note this repository will remain private until the submission deadline (Jan 15, 2019) 

### Prerequisites

I wrote all my queries for MySQL v5.7 as this is default for the provided [Fiddle](https://www.db-fiddle.com/f/svQD6mgBJDcykiJAd4oe8w/7)

### Assumptions
* No two or more merchants sell the product.id
* order_items.price is adjusted accordingly for order_items.quantity 


### Questions
#### Are there incidences of shops are increasing their prices? Does it occur on a regular basis?
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

#### What is the average annual price increase of products in this database, if any.
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
```
-- Find the first transaction (max) of each year
CREATE TABLE last_dates AS
	SELECT product_orders.product as products,
    MAX(CASE WHEN YEAR(placed_on) = '2014' THEN placed_on END) AS 'last_four',  --2014
    MAX(CASE WHEN YEAR(placed_on) = '2015' THEN placed_on END) AS 'last_five',  --2015
    MAX(CASE WHEN YEAR(placed_on) = '2016' THEN placed_on END) AS 'last_six',   --2016
    MAX(CASE WHEN YEAR(placed_on) = '2017' THEN placed_on END) AS 'last_seven', --2017
    MAX(CASE WHEN YEAR(placed_on) = '2018' THEN placed_on END) AS 'last_eight'  --2018
  FROM product_orders
  GROUP BY product_orders.product;
```
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

The same is done for the last transaction of each year
```
-- Join last transaction with its respective price
CREATE TABLE last_prices AS
  SELECT DISTINCT last_dates.products,
    four_prices.price  AS last_four_price,
    five_prices.price  AS last_five_price,
    six_prices.price   AS last_six_price,
    seven_prices.price AS last_seven_price,
    eight_prices.price AS last_eight_price
  FROM last_dates
  INNER JOIN product_orders AS four_prices
  ON four_prices.placed_on = last_four AND four_prices.product = products
  INNER JOIN product_orders AS five_prices
  ON five_prices.placed_on = last_five AND five_prices.product = products
  INNER JOIN product_orders AS six_prices
  ON six_prices.placed_on = last_six AND six_prices.product = products
  INNER JOIN product_orders AS seven_prices
  ON seven_prices.placed_on = last_seven AND seven_prices.product = products
  INNER JOIN product_orders AS eight_prices
  ON eight_prices.placed_on = last_eight AND eight_prices.product = products;
```
I calculated the average annual price increase to be 0.63% based on the first and last purchases made each year between 2014 and 2018. Technically, this is not correct as the actual price is not known at the beginning and end of each year, but most products have sales very close to the beginning and end of each year making my representation a reasonably close measure. No indication was given of the date the data was retrieved, so I did not incorporate the currently listed price from the products table.
    
A noteworthy observation is that when calculating the annual price increase, there are often cases where purchases are made at the exact same time stamp but have slightly different corresponding prices. I assume this discrepancy is related to transaction fees or is simply due to erroneous data. To overcome this issue, I averaged the difference in prices and used the result to calculate the yearly change in price. See example case below:




End with an example of getting some data out of the system or using it for a little demo
    
## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## License

This project is licensed under the Beerware License - see the [LICENSE.md](LICENSE.md) file for details

