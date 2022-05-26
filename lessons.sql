/*
* -> 2.2 DISTINCT
* Note: shows combined unique values in selected columns. Always remember about duplicate in columns
*/
SELECT DISTINCT city, country
FROM employees;

SELECT COUNT(DISTINCT country)
FROM employees;

/*
* -> 2.9 BETWEEN
* Note: the same with BETWEEN including boundaries
*/
SELECT *
FROM orders
WHERE freight >= 20 AND freight <= 40;

SELECT *
FROM orders
WHERE BETWEEN 20 AND 40;

/*
* -> 2.11 ORDER BY
* Note:
*/
SELECT DISTINCT country, city
FROM customers
ORDER BY country DESC, city ASC;

/*
* -> 2.18 GROUP BY
* Note:
*/
SELECT ship_country, COUNT(*)
FROM orders
WHERE freight > 50
GROUP BY ship_country
ORDER BY COUNT(*) DESC;

SELECT category_id, SUM(units_in_stock)
FROM products
GROUP BY category_id
ORDER BY SUM(units_in_stock) DESC
LIMIT 10;

/*
* -> 2.19 HAVING
* Note: post filter
*/
SELECT category_id, SUM(unit_price * units_in_stock)
FROM products
WHERE discontinued <> 1
GROUP BY category_id
HAVING SUM(unit_price * units_in_stock) > 5500
ORDER BY SUM(unit_price * units_in_stock);

/*
* -> 2.20 UNION, INTERSECT, EXCEPT
* Note: work with two queries
*/
SELECT country
FROM customers
UNION
SELECT country
FROM employees

/*
* -> 3.2 INNER JOIN
* Note:
*/
SELECT product_name, company_name, units_in_stock
FROM products
JOIN suppliers ON products.supplier_id = suppliers.supplier_id
ORDER BY units_in_stock DESC

SELECT category_name, SUM(unit_price * units_in_stock)
FROM products
JOIN categories ON products.category_id = categories.category_id
WHERE discontinued <> 1
GROUP BY category_name
HAVING SUM(unit_price * units_in_stock) > 5000
ORDER BY SUM(unit_price * units_in_stock) DESC

SELECT order_date, product_name, ship_country, products.unit_price, quantity, discount
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
JOIN products ON order_details.product_id = products.product_id

/*
* -> 3.3 LEFT, RIGHT JOIN
* Note: In this example LEFT is 'customers', 'orders' is RIGHT
*/
SELECT company_name, order_id
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id

/*
* -> 3.4 SELF JOIN
* Note: just watch the lesson
*/

/*
* -> 3.5 USING
* Note: USING: can use if join tables attribute is the same
*/
SELECT  contact_name, company_name, phone, first_name, last_name, title,
        order_date, product_name, ship_country, products.unit_price, quantity, discount
FROM orders
JOIN order_details USING(order_id) -- ON orders.order_id = order_details.order_id
JOIN products USING(product_id) -- ON order_details.product_id = products.product_id
JOIN customers USING(customer_id) -- ON orders.customer_id = customers.customer_id
JOIN employees USING(employee_id) -- ON orders.employee_id = employees.employee_id
WHERE ship_country = 'USA'

/*
* -> 3.6 AS - alias
* Note: You can use alias IN ('SELECT', 'GROUP BY', 'ORDER BY'), but NOT IN ('WHERE', 'HAVING')
*/

/*
* -> 3.8 Homework - JOINS
* 1 task: Найти заказчиков и обслуживающих их заказы сотрудников таких, что и заказчики и сотрудники из города London, а доставка идёт компанией Speedy Express. Вывести компанию заказчика и ФИО сотрудника.
*/
SELECT c.company_name, CONCAT(e.first_name, ' ', e.last_name)
FROM orders AS o
JOIN employees AS e USING(employee_id)
JOIN customers AS c USING(customer_id)
JOIN shippers AS s ON o.ship_via = s.shipper_id
WHERE e.city = 'London' AND c.city = 'London' AND s.company_name = 'Speedy Express'

/*
* -> 4.1 Subquery
* Note: Show products that has more units than average units in stock
*/
SELECT product_name, units_in_stock
FROM products
WHERE units_in_stock > (SELECT AVG(units_in_stock)
                        FROM products)
ORDER BY units_in_stock

/*
* -> 4.2 WHERE EXIST, ANY, ALL
* Note: EXIST returns true if subquery returns one or more rows
*/

/*
* -> Homework - Subquery
* 2 task: Напишите запрос, который выводит общую сумму фрахтов заказов для компаний-заказчиков для заказов, стоимость фрахта которых больше или равна средней величине стоимости фрахта всех заказов, а также дата отгрузки заказа должна находится во второй половине июля 1996 года. Результирующая таблица должна иметь колонки customer_id и freight_sum, строки которой должны быть отсортированы по сумме фрахтов заказов.
*/
SELECT customer_id, SUM(freight) AS freight_sum
FROM orders
JOIN (
      SELECT customer_id, AVG(freight) AS freight_avg
      FROM orders
      GROUP BY customer_id
) oa USING(customer_id)
WHERE freight > freight_avg AND shipped_date BETWEEN '1996-07-16' AND '1996-07-31'
GROUP BY customer_id
ORDER BY freight_sum


/*
* -> 5.1 DDL > Data Definition Language
* Note: Deletes all data from the table and reset autoincrease serial number
*/
TRUNCATE TABLE orders RESTART IDENTITY;
-- same with DELETE but without logging
DELETE FROM orders

/*
* -> 5.6-7 CHECK, DEFAULT
* Note:
*/
CREATE TABLE customers
(
      customer_id serial,
      full_name varchar,
      status char DEFAULT 'r'

      CONSTRAINT pk_books_book_id PRIMARY KEY (book_id)
      CONSTRAINT CHK_customers_status CHECK (status = 'r' OR status = 'p')
)

ALTER TABLE books
ADD COLUMN price decimal CONSTRAINT CHK_books_price CHECK (price >= 0);

ALTER TABLE customers
ALTER COLUMN status DROP DEFAULT

/*
* -> 5.8-9 SEQUENCES
* Note: Create a custom autoincrement and just watch
* Note: GENERATED ALWAYS AS IDENTITY NOT NULL is improved autoincrement (PostgreSQL v10)
*/
CREATE TABLE books
(
      book_id GENERATED ALWAYS AS IDENTITY NOT NULL
)

/*
* -> 5.10-11 INSERT, RETURNING
* Note: BULK INSERT from SELECT
*/
INSERT INTO books_backup
SELECT *
FROM books
WHERE price > 4.5

/*
* -> 6.1-3  Database design
* Note: Just watch
*/


/*
* -> 7.1-2 VIEW
* Note: Can only add a new column (at the end of SELECT), can't delete, rename, order of columns
* Note: Temporary, Recursive, Updated, Materialised (caching)
*/
CREATE VIEW vw_products_suppliers_categories AS
SELECT product_name, quantity_per_unit, unit_price, units_in_stock,
       company_name, contact_name, phone, category_name
FROM products
JOIN suppliers USING(supplier_id)
JOIN categories USING(category_id)

SELECT *
FROM vw_products_suppliers_categories
WHERE unit_price > 20;

/*
* -> 7.4 CHECK
* Note: if view created from one table, you can insert.
* Note: The following INSERT will cause an error, becouse violating the view's constraint
*/
CREATE OR REPLACE VIEW vw_heavy_orders AS
SELECT *
FROM orders
WHERE freight > 100 --view's constraint
WITH LOCAL CHECK OPTION --Take WHERE seriously

INSERT INTO vw_heavy_orders
VALUES ('order_id', ..., 80, ..., 'FRANCE') -- here freight is 80

/*
* -> 8.1 CASE WHEN
* Note: the example enough
*/
SELECT order_id, order_date,
      CASE  WHEN date_part('month', order_date) BETWEEN 3 AND 5 THEN 'spring'
            WHEN date_part('month', order_date) BETWEEN 6 AND 8 THEN 'summer'
            WHEN date_part('month', order_date) BETWEEN 9 AND 11 THEN 'autumn'
            ELSE 'winter'
      END AS season
FROM orders

/*
* -> 8.3 COALESCE & NULLIF
* Note: COALESCE(arg1, arg2...) if arg1 is NULL will returns arg2 (takes string args)
* Note: NULLIF (arg1, arg2) if arg1 and arg2 are equal will return NULL
*/
SELECT order_id, order_date, COALESCE(ship_region, 'unknown') AS ship_region --Column 'ship_region' contains NULL rows
FROM orders


SELECT contact_name, COALESCE(NULLIF(city, ''), 'unknown') AS city --Column 'city' contains '' (empty string) rows
FROM customers

-- From Homework
SELECT contact_name, COALESCE(order_id::text, 'no orders') AS order_id
FROM customers
LEFT JOIN orders USING(customer_id)
WHERE order_id IS NULL

/*
* -> 9.2 Functions
* Note:
*/
SELECT *
INTO temp_customers
FROM customers

CREATE OR REPLACE FUNCTION fix_customer_region() RETURNS void
AS $$
      UPDATE temp_customers
      SET region = 'unknown'
      WHERE region IS NULL
$$ LANGUAGE SQL;

SELECT fix_customer_region();

/*
* -> 9.4 IN, OUT, DEFAULT
* Note: sequence of OUT args and sequence of SELECT have to be same for function result
*/
CREATE OR REPLACE FUNCTION get_price_boundaries_by_discontinuity(is_discontinued int DEFAULT 1, OUT max_price real, OUT min_price real)
AS $$
      SELECT MAX(unit_price), MIN(unit_price)
      --won't work INTO max_price, min_price
      FROM products
      WHERE discontinued = is_discontinued
$$ LANGUAGE SQL;

SELECT * FROM get_price_boundaries_by_discontinuity();

/*
* -> 9.4 Plural returns
* Note: RETURNS SETOF [data_type, RECORD, table_name] returns results in rows
* Note: RETURNS TABLE (column_name data_type) here column_name (custom) isn't the same column from a selecting table
*/
CREATE OR REPLACE FUNCTION get_avg_prices_by_prod_cats(OUT sum_price real, OUT avg_price float8)
RETURNS SETOF RECORD
AS $$

      SELECT SUM(unit_price), AVG(unit_price)
      FROM products
      GROUP BY category_id

$$ LANGUAGE SQL;

SELECT sum_price AS sum_of, avg_price AS in_avg FROM get_avg_prices_by_prod_cats();


CREATE OR REPLACE FUNCTION get_customer_by_country(customer_country varchar)
RETURNS SETOF customers
AS $$
      --won't work SELECT customer_id, company_name
      SELECT *
      FROM customers
      WHERE country = customer_country
$$ LANGUAGE SQL;

SELECT order_id, company_name FROM get_customer_by_country('USA');


CREATE OR REPLACE FUNCTION get_customer_by_country(customer_country varchar)
RETURNS TABLE(char_code char, company_name varchar)
AS $$
      SELECT customer_id, company_name
      FROM customers
      WHERE country = customer_country
$$ LANGUAGE SQL;

SELECT char_code, company_name FROM get_customer_by_country('USA');

/*
* -> 9.5 PL/pgSQL
* Note: In PL/pgSQL functions, we can use variables, loops, if else, RETURN instead of SELECT or RETURN QUERY with SELECT
*/
CREATE OR REPLACE FUNCTION get_price_boundaries_by_discontinuity(is_discontinued int DEFAULT 1, OUT max_price real, OUT min_price real)
AS $$
BEGIN
      SELECT MAX(unit_price), MIN(unit_price)
      INTO max_price, min_price
      FROM products
      WHERE discontinued = is_discontinued;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_price_boundaries_by_discontinuity();

/*
* -> 9.8 DECLARE variables in function
* Note:
*/
CREATE OR REPLACE FUNCTION calc_middle_price() RETURNS SETOF products
AS $$
DECLARE
      avg_price real;
      low_price real;
      high_price real;
BEGIN
      SELECT AVG(unit_price) INTO avg_price
      FROM products;

      low_price = avg_price * 0.85;
      high_price = avg_price * 1.25;

      RETURN QUERY
      SELECT *
      FROM products
      WHERE unit_price BETWEEN low_price AND high_price;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM calc_middle_price();

/*
* -> 10.2 RAISE EXCEPTION
* Note: RAISE [levels] 'messages (%)', arg_name USING HINT = '', ERRCODE = '';
* Note: log_min_messages - server-side logs (WARNING - default);
* Note: client_min_messages - client-side logs (NOTICE - default);
*/


/*
* -> 11.1-2 Explicit and Implicit cast data_type
* Note: CAST(expression AS date_type), expression::data_type;
*/


/*
* -> 12.1 INDEX - introdaction
* Note: Just watch, VACUUM [FULL], Autovacuum;
*/


/*
* -> 12.2 INDEX - types and scans
* Note: Just watch;
* Note: PRIMARY KEY and UNIQUE will index by default;
* Note: SELECT amname FROM pg_am;
*/


/*
* -> 12.3 INDEX - types
* Note: Just watch;
* Note: Each type of INDEX has it's own constraints (=, >=, <, LIKE '', NULL, 'WAL');
* Note: B-tree is default;
*/


/*
* -> 12.4-7 EXPLAIN, ANALYZE, GIST
* Note: Just watch;
* Note: CREATE INDEX ... ON table_name(column1, column2);
* Note: Index scan will work by first or both column, separetely second column won't work;
*/
CREATE TABLE pref_test(
      id int,
      reason text COLLATE "C",
      annotation text COLLATE "C"
)

INSERT INTO pref_test(id, reason, annotation)
SELECT s.id, md5(random()::text), null
FROM generate_series(1, 10000000) AS s(id)
ORDER BY random();

UPDATE pref_test
SET annotation = UPPER(md5(random()::text));

CREATE INDEX idx_pref_test_id ON pref_test(id);


SELECT *
FROM pref_test
WHEN LOWER(annotation) LIKE('ab%');

CREATE INDEX idx_pref_test_annotation_lower ON pref_test(LOWER(annotation));


EXPLAIN --ANALYZE
SELECT *
FROM pref_test
WHERE id = 37000;

/*
* -> 13.4 ARRAY - VARIADIC and FOREACH
* Note: Just watch;
*/


/*
* -> 14.1-4  CUSTOM data_type - DOMAINS, ENUM, COMPOSITE
* Note: Just watch
*/


/*
* -> 15.2 GROUPPING SET, ROLLUP, CUBE
* Note: ROLLUP have 'grand total' row in result
*/

SELECT supplier_id, category_id, SUM(units_in_stock)
FROM products
GROUP BY GROUPPING SETS ((supplier_id), (supplier_id, category_id))
ORDER BY supplier_id, category_id NULL FIRST


SELECT supplier_id, SUM(units_in_stock)
FROM products
GROUP BY ROLLUP(supplier_id)

/*
* -> 17.2 IMPORT .CSV
* Note: psql: \copy patients (table_name) FROM 'CSV file path' DELIMITER ',' CSV HEADER;
* Note: Just watch;
*/


/*
* -> 18.1-2 Common Table Expression (CTE)
* Note: Just watch;
*/


/*
* -> 19.1-2 Window Functions
* Note: Just watch
*/
SELECT category_id, category_name, product_name, unit_price,
       AVG(unit_price) OVER(PARTITION BY category_id) AS avg_price
FROM products
JOIN categories USING(category_id)


SELECT order_id, order_date, product_id, customer_id, unit_price AS sub_total,
       SUM(unit_price) OVER(PARTITION BY order_id ORDER BY product_id)
FROM orders
JOIN order_details USING(order_id)
ORDER BY order_id


SELECT row_id, order_id, order_date, product_id, customer_id, unit_price AS sub_total,
       SUM(unit_price) OVER(ORDER BY row_id) AS sale_sum
FROM (
      SELECT order_id, order_date, product_id, unit_price,
             row_number() OVER() AS row_id
      FROM orders
      JOIN order_details USING(order_id)
) subquery
ORDER BY order_id;

/*
* -> 19.3 Window Functions - RANK, DENSE_RANK, LAG, LEAD
* Note: Just watch, works via ORDER BY
*/
SELECT product_name, units_in_stock,
       RANK() OVER(ORDER BY units_in_stock) --RANK with gap
FROM products;


SELECT product_name, units_in_stock,
       DENSE_RANK() OVER(ORDER BY units_in_stock) --DENSE_RANK without gap
FROM products;

SELECT product_name, unit_price,
       LAG(unit_price) OVER(ORDER BY unit_price DESC) - unit_price AS price_lag --LAG gets prev unit_price
FROM products;


SELECT product_name, unit_price,
       LEAD(unit_price) OVER(ORDER BY unit_price) - unit_price AS price_lead --LEAD gets next unit_price
FROM products;


/*
* -> 19.4 Return N-rows
* Note:
*/
SELECT *
FROM products
WHERE product_id = ANY(
      SELECT product_id
      FROM (
            SELECT product_id, unit_price
                   ROW_NUMBER() OVER(ORDEr BY unit_price DESC) AS nth
            FROM products
      ) sorted_prices
      WHERE nth > 6;
);


SELECT *
FROM (
      SELECT order_id, product_id, unit_price, quantity,
             RANK() OVER(PARTITION BY order_id ORDER BY quantity DESC) as rank_quantity
      FROM orders
      JOIN order_details USING(order_id)
) subquery
WHERE rank_quantity <= 3;


--From Homework
SELECT DISTINCT employee_id, total_by_emp, AVG(total_by_emp) OVER() AS avg_price
FROM (
      SELECT employee_id, SUM(unit_price*quantity) OVER(PARTITION BY employee_id) AS total_by_emp
      FROM orders
      JOIN order_details USING(order_id)
) subquery
ORDER BY total_by_emp DESC;

/*
* ->
* Note:
*/


/*
* ->
* Note:
*/


/*
* ->
* Note:
*/


/*
* ->
* Note:
*/


/*
* ->
* Note:
*/



/*
* ->
* Note:
*/


/*
* ->
* Note:
*/


/*
* ->
* Note:
*/




--- DON'T TOUCH! ---
SELECT *
-- FROM orders
-- FROM order_details
-- FROM products
-- FROM categories

-- FROM employees
-- FROM employee_territories
-- FROM customers
-- FROM suppliers
-- FROM shippers

-- FROM territories
-- FROM us_states
-- FROM region