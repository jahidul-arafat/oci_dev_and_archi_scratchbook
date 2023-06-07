-- Scenario (a): Filling up the InnoDB temporary tablespace
CREATE TABLE large_table (
  id INT PRIMARY KEY AUTO_INCREMENT,
  data VARCHAR(100)
);

-- Insert a large number of rows into the temporary table
INSERT INTO large_table (data)
SELECT CONCAT('Data-', RAND())
FROM information_schema.tables t1
CROSS JOIN information_schema.tables t2
LIMIT 1000000;

-- Scenario (b): Creating large binlog files
SET SESSION sql_log_bin = 1;

-- Perform a series of large updates on a table
UPDATE orders
SET order_status = 'Shipped'
WHERE order_date < '2023-05-01';

-- Scenario (c): Creating excessive sessions
DELIMITER //
CREATE PROCEDURE simulate_sessions()
BEGIN
  DECLARE i INT DEFAULT 1;
  WHILE i <= 5000 DO
    START TRANSACTION;
    SELECT SLEEP(10);
    COMMIT;
    SET i = i + 1;
  END WHILE;
END//
DELIMITER ;

-- Call the procedure to simulate excessive sessions
CALL simulate_sessions();
