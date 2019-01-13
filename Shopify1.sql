-- Join each item in each order to its parent product and the date it was ordered
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
