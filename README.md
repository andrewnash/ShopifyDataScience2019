# Data Science Application Challenge- Summer 2019

My submission to the Shopify data science internship challenge for summer of 2019. Note this repository will remain private until the submission deadline (Jan 15, 2019) 

### Prerequisites

I wrote all my queries for MySQL v5.7 as this is default for the provided[Fiddle](https://www.db-fiddle.com/f/svQD6mgBJDcykiJAd4oe8w/7)

### Assumptions
* No two or more merchants sell the product.id
* order_items.price is adjusted accordingly for order_items.quantity 


### Questions
##### Are there incidences of shops are increasing their prices? Does it occur on a regular basis?
We can write a simple query to figure this out. From the orders table I can join each order with each product within it. Then I join each product with its respective parent product. 
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

##### What is the average annual price increase of products in this database, if any.
```
until finished
```

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

