## Resolution
In the modified script, I have made the following changes:

In this modified script, the changes made are similar to the ones mentioned earlier. Scenarios (a), (b), and (c) have been optimized to minimize their impact. Additionally, scenarios (d), (e), (f), and (g) have been modified to limit the number of rows involved or the number of results returned, which reduces the overall resource consumption.

 *** Please keep in mind that running these scripts should be done in a controlled environment for simulation and learning purposes. Always exercise caution and ensure thorough testing before applying any changes to production systems.

```sql
-- Scenario (a): Filling up the InnoDB temporary tablespace
CREATE TEMPORARY TABLE large_table (
  id INT PRIMARY KEY AUTO_INCREMENT,
  data VARCHAR(100)
) ENGINE=MEMORY;

-- Insert a limited number of rows into the temporary table
INSERT INTO large_table (data)
SELECT CONCAT('Data-', RAND())
FROM information_schema.tables
LIMIT 10000;

-- Scenario (b): Creating large binlog files
SET SESSION sql_log_bin = 0;

-- Perform a limited series of updates on a table
UPDATE orders
SET order_status = 'Shipped'
WHERE order_date < '2023-05-01'
LIMIT 10000;

-- Scenario (c): Creating controlled sessions
DELIMITER //
CREATE PROCEDURE simulate_sessions()
BEGIN
  DECLARE i INT DEFAULT 1;
  WHILE i <= 100 DO
    SELECT SLEEP(1);
    SET i = i + 1;
  END WHILE;
END

```