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

-- calculate yearly average
CREATE TABLE yearly_avg AS
	SELECT AVG(four) AS 'four_avg',
    AVG(five)    AS 'five_avg',
    AVG(six)     AS 'six_avg',
    AVG(seven)   AS 'seven_avg',
    AVG(eight)   AS 'eight_avg'
	FROM change_in_prices;

-- calculate final average price increase for all years
SELECT (four_avg + five_avg + six_avg + seven_avg + eight_avg)/5
	AS average_annual_price_increase
FROM yearly_avg;
