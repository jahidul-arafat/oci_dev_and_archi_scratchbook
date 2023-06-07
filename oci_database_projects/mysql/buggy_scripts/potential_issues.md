# MDS Outbreak: Bug or Script
### A. MDS Issues:
- [ ] Current MDS Version: MySQL 8.0.29
- [ ] MDS binlog issues – causing storage constraints, with 400GB Database, backup size found to be around 1TB
- [ ] MDS – restore from backup is time-consuming; taking around 3 to 4 hrs for a 100GB Database
- [ ] MDS hanged multiple times, mostly at the end of the month, when month-end reports are generated, causing the active sessions to raise above 4000 and MDS failing to serve the requesting, creating a long poll of queues.


### B. Root Cause Analysis
![RCA/MySQL/Bug/Script](./5n6z2tt6-400.png)
Here is a summary of the root cause analysis based on our observation and discussion with the core MySQL Team:
1. The MySQL version being used by the customer (MySQL 8.0.29) has some known bugs that can impact the database performance.
2. The customer's use of the MySQL managed database service in OCI limits their access to certain administrative functions, including root access.
3. The customer has reported several issues with their MySQL database, including binlog issues, time-consuming backup and restore processes, and database hangs.
4. These issues have been identified as being indirectly correlated with the excessive usage of the InnoDB temporary tablespace.
5. The customer is executing scripts that are filling up the InnoDB temporary tablespace, resulting in the system occupying almost all the space for 3-4 hours.
6. The excessive usage of the InnoDB temporary tablespace is leading to increased disk I/O usage and larger binlog files, which are causing storage constraints, longer backup and restore times, and overall database performance issues.
7. The customer's configuration includes a max_connections setting of 4000, which is not sufficient to handle the load during peak periods, resulting in a large number of active sessions and impacting the overall database performance.
8. The customer may need to increase the max_connections setting or optimize their queries and database design to reduce the number of simultaneous connections required.
9. It is important to monitor the database server's performance during peak periods and adjust the max_connections setting accordingly to achieve the best performance and scalability.
10. To avoid these issues, it is important to ensure that the InnoDB temporary tablespace is properly configured and optimized to handle the workload, and to monitor disk I/O usage and binlog file sizes to ensure that they are within acceptable limits.

### C. Best Practice guideline to optimise scripts to avoid system disruption
1. Use "EXPLAIN" to analyze queries and identify performance issues, such as slow queries or
inefficient use of indexes.
2. Avoid using "SELECT *", which can retrieve unnecessary data and lead to increased disk I/O
usage.
3. Use "LIMIT" to limit the number of rows returned by a query, which can reduce the amount of
data retrieved and improve performance.
4. Use "JOIN" instead of "WHERE" clauses to join tables, which can improve query performance
and reduce disk I/O usage.
  
5. Use "UNION" instead of "OR" clauses to combine queries, which can improve query performance and reduce disk I/O usage.
6. Use "GROUP BY" and "ORDER BY" clauses to sort and group data, which can improve query performance and reduce disk I/O usage.
7. Use prepared statements and parameter binding to optimize the execution of queries and reduce the risk of SQL injection attacks.
8. Use connection pooling to manage database connections and reduce the overhead of creating and destroying connections.
9. Monitor the performance of the database server during peak periods and adjust the configuration settings, such as buffer sizes, to optimize performance.
10. Use caching mechanisms, such as memcached or Redis, to cache frequently accessed data and reduce the load on the database server.

### D. Some Example Optimised Scripts
Here are some examples of SQL scripts that demonstrate how to optimize database queries:
1. Using "JOIN" instead of "WHERE" clauses to join tables:
FROM JOIN ON
2. Using "LIMIT" to limit the number of rows returned by a query:
```sql
SELECT *
FROM
ORDER BY   DESC LIMIT 10;
```

3. Using "GROUP BY" and "ORDER BY" clauses to sort and group data:
```sql
SELECT customer_id, SUM(total_price) as total_sales
FROM orders
GROUP BY customer_id
ORDER BY total_sales DESC;
```

4. Using prepared statements and parameter binding to optimize the execution of queries:

```sql
PREPARE stmt1 FROM 'SELECT * FROM customer WHERE customer_id=?';
SET @customer_id=123;
EXECUTE stmt1 USING @customer_id;
```


5. Using connection pooling to manage database connections:
```sql
$dbh = new PDO("mysql:host=localhost;dbname=mydb", "username", "password", array(PDO::ATTR_PERSISTENT => true));
```

By implementing these best practices and optimizing their SQL scripts, the customer can improve the performance of their MySQL database and reduce the risk of system disruption.
