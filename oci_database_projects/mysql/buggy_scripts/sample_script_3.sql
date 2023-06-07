-- Scenario (a): Creating a large number of temporary tables
DELIMITER //
CREATE PROCEDURE create_temp_tables()
BEGIN
  DECLARE i INT DEFAULT 1;
  WHILE i <= 1000 DO
    SET @table_name = CONCAT('temp_table_', i);
    SET @sql = CONCAT('CREATE TEMPORARY TABLE ', @table_name, ' (id INT)');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    SET i = i + 1;
  END WHILE;
END//
DELIMITER ;

-- Call the procedure to create temporary tables
CALL create_temp_tables();

-- Scenario (b): Recursive self-join causing excessive resource usage
WITH RECURSIVE cte AS (
  SELECT 1 AS level
  UNION ALL
  SELECT level + 1 FROM cte WHERE level < 100000
)
SELECT SUM(level) FROM cte;

-- Scenario (c): Running an inefficient cross join query
SELECT *
FROM orders o1
CROSS JOIN orders o2;

-- Scenario (d): Executing a long-running transaction
START TRANSACTION;
INSERT INTO large_table (data)
VALUES ('Some data');
SELECT SLEEP(600); -- Sleeping for 10 minutes
COMMIT;

-- Scenario (e): Creating excessive indexes on a table
ALTER TABLE orders ADD INDEX idx1 (customer_id);
ALTER TABLE orders ADD INDEX idx2 (order_date);
ALTER TABLE orders ADD INDEX idx3 (product_id);
-- Continue adding more indexes

-- Scenario (f): Simulating a deadlock situation
-- Requires multiple concurrent connections running this script

-- Connection 1:
START TRANSACTION;
UPDATE orders SET order_status = 'Shipped' WHERE order_id = 1;

-- Connection 2:
START TRANSACTION;
UPDATE orders SET order_status = 'Cancelled' WHERE order_id = 2;

-- Connection 1:
UPDATE orders SET order_status = 'Delivered' WHERE order_id = 2;

-- Scenario (g): Generating a large amount of binary log events
SET SESSION sql_log_bin = 1;
-- Execute multiple large data modifications or schema changes

-- Scenario (h): Running a complex subquery with multiple joins
SELECT *
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
WHERE cat.category_name = 'Electronics';

-- Scenario (i): Dropping an important table accidentally
-- Only execute this scenario in a controlled environment with backups
DROP TABLE important_table;

-- Scenario (j): Disabling binary logging
SET SESSION sql_log_bin = 0;

-- Continue adding more scenarios as per your simulation and learning requirements
