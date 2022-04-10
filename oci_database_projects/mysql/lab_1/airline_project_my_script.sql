# MySQL HeatWave 
# Main Ref:
# https://blogs.oracle.com/mysql/post/using-mysql-database-service-in-oci-part-1
# https://blogs.oracle.com/mysql/post/using-mysql-database-service-in-oci-part-2
# https://blogs.oracle.com/mysql/post/using-mysql-database-service-in-oci-part-3


# deploy MySQL DB in OCI using terraform
# Ref: https://github.com/oracle-quickstart/oci-mysql

#ocicli mysql commands
# Ref: https://docs.public.oneportal.content.oci.oraclecloud.com/en-us/iaas/tools/oci-cli/3.0.3/oci_cli_docs/cmdref/mysql.html
> oci mysql db-system list --compartment-id ocid1.compartment.oc1..aaaaaaaa5hplc4q67l76kzeygvcbbu73da3kxhndhogtfvxgwtpd2xzayecq --profile DEFAULT
> oci mysql version list --compartment-id ocid1.compartment.oc1..aaaaaaaa5hplc4q67l76kzeygvcbbu73da3kxhndhogtfvxgwtpd2xzayecq --profile DEFAULT
#-------------------------------------------------------------------------

# Setting the mysql shell
# Install mysql shell - client
# Note that, it's not mysql-server, instead its a mysql-client
sudo yum install -y mysql-community-client mysql-shell

# if your mysql setup is having an issue, try below. 
# I had an issue, thats why tried so
# Ref: https://pupuweb.com/solved-fix-unable-find-match-error-mysql-centos/
sudo yum module disable mysql
sudo yum install mysql-community-server
yum install mysql

# Downlaod the mysql plugins
cd .mysqlsh/
git clone https://github.com/lefred/mysqlshell-plugins.git plugins

# Now, if you run mysqlsh, plugins will be loaded
# Check the mysql shell plugins here in: https://github.com/jahidul-arafat/mysqlshell-plugins
> mysqlsh admin@10.0.1.159 --sql

#--------------------------------------------------------------------------

# Resolving the pip issue (pip3.9) and install required plugins <requests, pyclamd>
# How to finx the pip error as Oracle MySQL 8.0.24 supports only pip version 3.9
# when the bastion host with latest Oracle Linux having python and pip version 3.6
# So, if the pip version is not resolved, then mysql shell can't install the extra modules
# Ref: https://lefred.be/content/mysql-shell-and-extra-python-modules/
wget https://bootstrap.pypa.io/get-pip.py
mysqlsh --py -f get-pip.py
mysqlsh --pym pip install --user prettytable
mysqlsh --pym pip install --user requests
mysqlsh --pym pip install --user pyclamd

#--------------------------------------------------------------------------


# Enable MySQL Shell history
# Ref: https://lefred.be/content/reminder-when-using-mysql-shell/
mysqlsh admin@10.0.1.159
mysql-js > shell.options.setPersist('history.autoSave', 1)
mysql-js> shell.options.setPersist('history.maxSize', 5000)
mysql-js> shell.options.setPersist('defaultMode', 'sql')    # set the default mode to sql

# create a table named <ontime> with the schema derived from the csv file
use dnothi;
CREATE TABLE ontime (
   id int unsigned auto_increment invisible primary key,
   `Year` int unsigned,
   `Quarter` tinyint unsigned,
   `Month` tinyint unsigned,
   `DayofMonth` tinyint unsigned,
   `DayOfWeek` tinyint unsigned,
   `FlightDate` date,
   `Reporting_Airline` varchar(2),
   `DOT_ID_Reporting_Airline` int unsigned,
   `IATA_CODE_Reporting_Airline` varchar(2),
   `Tail_Number` varchar(6),
   `Flight_Number_Reporting_Airline` int unsigned,
   `OriginAirportID` int unsigned,
   `OriginAirportSeqID` int unsigned,
   `OriginCityMarketID` int unsigned,
   `Origin` varchar(3),
   `OriginCityName` varchar(34),
   `OriginState` varchar(2),
   `OriginStateFips` tinyint unsigned,
   `OriginStateName` varchar(46),
   `OriginWac` tinyint unsigned,
   `DestAirportID` int unsigned,
   `DestAirportSeqID` int unsigned,
   `DestCityMarketID` int unsigned,
   `Dest` varchar(3),
   `DestCityName` varchar(34),
   `DestState` varchar(2),
   `DestStateFips` tinyint unsigned,
   `DestStateName` varchar(46),
   `DestWac` tinyint unsigned,
   `CRSDepTime` int unsigned,
   `DepTime` int unsigned,
   `DepDelay` decimal(4,2),
   `DepDelayMinutes` decimal(4,2),
   `DepDel15` decimal(4,2),
   `DepartureDelayGroups` tinyint ,
   `DepTimeBlk` varchar(9),
   `TaxiOut` decimal(4,2),
   `WheelsOff` int unsigned,
   `WheelsOn` int unsigned,
   `TaxiIn` decimal(3,2),
   `CRSArrTime` int unsigned,
   `ArrTime` int unsigned,
   `ArrDelay` decimal(4,2),
   `ArrDelayMinutes` decimal(4,2),
   `ArrDel15` decimal(4,2),
   `ArrivalDelayGroups` tinyint ,
   `ArrTimeBlk` varchar(9),
   `Cancelled` decimal(4,2),
   `CancellationCode` varchar(1),
   `Diverted` decimal(4,2),
   `CRSElapsedTime` decimal(5,2),
   `ActualElapsedTime` decimal(5,2),
   `AirTime` decimal(4,2),
   `Flights` decimal(3,2),
   `Distance` decimal(5,2),
   `DistanceGroup` tinyint unsigned,
   `CarrierDelay` decimal(4,2),
   `WeatherDelay` decimal(4,2),
   `NASDelay` decimal(4,2),
   `SecurityDelay` decimal(4,2),
   `LateAircraftDelay` decimal(4,2),
   `FirstDepTime` varchar(4),
   `TotalAddGTime` varchar(6),
   `LongestAddGTime` varchar(6),
   `DivAirportLandings` tinyint unsigned,
   `DivReachedDest` varchar(4),
   `DivActualElapsedTime` varchar(7),
   `DivArrDelay` varchar(7),
   `DivDistance` varchar(7),
   `Div1Airport` varchar(3),
   `Div1AirportID` varchar(5),
   `Div1AirportSeqID` varchar(7),
   `Div1WheelsOn` varchar(4),
   `Div1TotalGTime` varchar(6),
   `Div1LongestGTime` varchar(6),
   `Div1WheelsOff` varchar(4),
   `Div1TailNum` varchar(6),
   `Div2Airport` varchar(3),
   `Div2AirportID` varchar(5),
   `Div2AirportSeqID` varchar(7),
   `Div2WheelsOn` varchar(4),
   `Div2TotalGTime` varchar(5),
   `Div2LongestGTime` varchar(5),
   `Div2WheelsOff` varchar(50),
   `Div2TailNum` varchar(50),
   `Div3Airport` varchar(50),
   `Div3AirportID` varchar(50),
   `Div3AirportSeqID` varchar(50),
   `Div3WheelsOn` varchar(50),
   `Div3TotalGTime` varchar(50),
   `Div3LongestGTime` varchar(50),
   `Div3WheelsOff` varchar(50),
   `Div3TailNum` varchar(50),
   `Div4Airport` varchar(50),
   `Div4AirportID` varchar(50),
   `Div4AirportSeqID` varchar(50),
   `Div4WheelsOn` varchar(50),
   `Div4TotalGTime` varchar(50),
   `Div4LongestGTime` varchar(50),
   `Div4WheelsOff` varchar(50),
   `Div4TailNum` varchar(50),
   `Div5Airport` varchar(50),
   `Div5AirportID` varchar(50),
   `Div5AirportSeqID` varchar(50),
   `Div5WheelsOn` varchar(50),
   `Div5TotalGTime` varchar(50),
   `Div5LongestGTime` varchar(50),
   `Div5WheelsOff` varchar(50),
   `Div5TailNum` varchar(50)
);

# Lets get the table, check whether it is created
use dnothi;
show tables;

# list all users in the DB
# Ref: https://www.javatpoint.com/mysql-show-users

# Decribe the table and get its schema
use dnothi;
describe ontime; # table name

# After you have imported the data into table, lets check how much data is imported
use dnothi;
SELECT COUNT(*) FROM ontime;

# List all columes in the table
use dnothi;
SELECT COUNT(*) AS NUMBEROFCOLUMNS 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE table_name = 'ontime';

# list rows from table
use dnothi;
SELECT *
FROM ontime
LIMIT 100;

#update option will fail as the mysql server is running in super privilege mode
# Execute this statement in terminal mysqlsh
use dnothi;
UPDATE ontime SET Quarter=5 WHERE DOT_ID_Reporting_Airline=19391;

# Check how much data is loaded into the database
SELECT TABLE_SCHEMA,
sys.format_bytes(sum(table_rows)) `ROWS`,
sys.format_bytes(sum(data_length)) DATA,
sys.format_bytes(sum(index_length)) IDX,
sys.format_bytes(sum(data_length) + sum(index_length)) 'TOTAL SIZE',
round(sum(index_length) / sum(data_length),2) IDXFRAC
FROM information_schema.TABLES
GROUP By table_schema ORDER BY sum(DATA_length) DESC;

#
#If you’re using a cloud service for your MySQL database like AWS Aurora, you need to check for your innodb_read_only variable instead of the read-only variable.
#This is because cloud services like AWS Aurora usually have multiple database instances, and you can only write to the main (master) database instance and not the secondary (slave) database instance.
SHOW GLOBAL VARIABLES LIKE 'innodb_read_only'; 

# Disadvantage of read_only=1
# Ref: https://dev.mysql.com/worklog/task/?id=3602
SHOW GLOBAL variables like 'read_only';
SELECT @@global.read_only, @@global.super_read_only;
SET global read_only=0;
SET GLOBAL super_read_only = 0;

# Import Data from mysqlsh to OSS
# Ref: https://docs.oracle.com/en-us/iaas/mysql-database/doc/importing-and-exporting-databases.html#GUID-63396585-3ECA-4202-86D7-94C6DE08CCCD

# Check the health of all databases. This command should only be executed inside the terminal
#mysqlcheck -h 10.0.1.159 -uadmin -p --all-databases

# Check the performance_schema.errorlog
SELECT * FROM performance_schema.error_log\G



# Check the mysqldump commands
# When exporting, backing up and restoring Mysql database from the master database to the slave database, you need to pay attention to whether to enable GTID mode for the database. If you enable it, you should add the parameter -- set GTID purged = off to mysqldump data.
#Ref: https://programming.vip/docs/mysqldump-export-data-backup-set-gtid-purged-off.html
# https://www.sqlshack.com/how-to-backup-and-restore-mysql-databases-using-the-mysqldump-command/

mysqldump -h 10.0.1.159 -u admin -p --set-gtid-purged=OFF dnothi > dnothi_dump.sql
mysqldump -alv -h 10.0.1.159 -u admin -p --set-gtid-purged=OFF airline > airline_dump.sql

# loading dumped data into database
mysql -h 10.0.1.150 -u admin -p demodb < demodb_dump.sql


# Heatwave
# Query-1: Before Heatwave
use dnothi;
SELECT year, Reporting_Airline, AVG(ArrDelay) AS avgArrDelay
FROM ontime
WHERE Reporting_Airline IN ('AA', 'UA', 'DL')
GROUP BY Reporting_Airline, year ORDER BY year, Reporting_Airline;

# Check whether the Heatwave is ready or is enabled. If you didnt enable the heatwave cluster, then 
# rapid_cluster_status --> OFF
# rapid_service_status --> OFFLINE

SELECT * FROM performance_schema.global_status
Where variable_name like 'rapid%er%status';
Output:
+----------------------+----------------+
| VARIABLE_NAME        | VARIABLE_VALUE |
+----------------------+----------------+
| rapid_cluster_status | ON             |
| rapid_service_status | ONLINE         |
+----------------------+----------------+

# From the OCI MySQL DB Console enable the MySQL HeatWave Cluster. 
# Before that you need to run the estimator to estimate the number HeatWwave Node Required.
# If your database is even chnaging and growing, you need to run the estimator often.
# Default Nodes: 2


# Load command to load the dnothi data into HeatWave once the cluster is ready
# Having the possibility to load and unload data from HeatWave on demand allows you to pay for what you consume.

CALL sys.heatwave_load(JSON_ARRAY('dnothi'), NULL);
# This will load the data and return a report.
+------------------------------------------+
| INITIALIZING HEATWAVE AUTO PARALLEL LOAD |
+------------------------------------------+
| Version: 1.26                            |
|                                          |
| Load Mode: normal                        |
| Load Policy: disable_unsupported_columns |
| Output Mode: normal                      |
|                                          |
+------------------------------------------+
6 rows in set (14 min 46.6384 sec)

+------------------------------------------------------------------------+
| OFFLOAD ANALYSIS                                                       |
+------------------------------------------------------------------------+
| Verifying input schemas: 1                                             |
| User excluded items: 0                                                 |
|                                                                        |
| SCHEMA                       OFFLOADABLE    OFFLOADABLE     SUMMARY OF |
| NAME                              TABLES        COLUMNS     ISSUES     |
| ------                       -----------    -----------     ---------- |
| `dnothi`                               1            110                |
|                                                                        |
| Total offloadable schemas: 1                                           |
|                                                                        |
+------------------------------------------------------------------------+
10 rows in set (14 min 46.6384 sec)

+-----------------------------------------------------------------------------------------------------------------------------+
| CAPACITY ESTIMATION                                                                                                         |
+-----------------------------------------------------------------------------------------------------------------------------+
| Default load pool for tables: TRANSACTIONAL                                                                                 |
| Default encoding for string columns: VARLEN (unless specified in the schema)                                                |
| Estimating memory footprint for 1 schema(s)                                                                                 |
|                                                                                                                             |
|                                TOTAL       ESTIMATED       ESTIMATED       TOTAL     DICTIONARY      VARLEN       ESTIMATED |
| SCHEMA                   OFFLOADABLE   HEATWAVE NODE      MYSQL NODE      STRING        ENCODED     ENCODED            LOAD |
| NAME                          TABLES       FOOTPRINT       FOOTPRINT     COLUMNS        COLUMNS     COLUMNS            TIME |
| ------                   -----------       ---------       ---------     -------     ----------     -------       --------- |
| `dnothi`                           1       88.51 GiB        4.00 MiB          61              0          61        3.67 min |
|                                                                                                                             |
| Sufficient MySQL host memory available to load all tables.                                                                  |
| Sufficient HeatWave cluster memory available to load all tables.                                                            |
|                                                                                                                             |
+-----------------------------------------------------------------------------------------------------------------------------+
13 rows in set (14 min 46.6384 sec)

+---------------------------------------------------------------------------------------------------------------------------------------+
| EXECUTING LOAD                                                                                                                        |
+---------------------------------------------------------------------------------------------------------------------------------------+
| HeatWave Load script generated                                                                                                        |
|   Retrieve load script containing 3 generated DDL command(s) using the query below:                                                   |
|   SELECT log->>"$.sql" AS "Load Script" FROM sys.heatwave_load_report WHERE type = "sql" ORDER BY id;                                 |
|                                                                                                                                       |
| Adjusting load parallelism dynamically per table                                                                                      |
| Using current parallelism of 32 thread(s) as maximum                                                                                  |
|                                                                                                                                       |
| Using SQL_MODE: ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION |
|                                                                                                                                       |
| Proceeding to load 1 tables into HeatWave                                                                                             |
|                                                                                                                                       |
| Applying changes will take approximately 3.66 min                                                                                     |
|                                                                                                                                       |
+---------------------------------------------------------------------------------------------------------------------------------------+
13 rows in set (14 min 46.6384 sec)

+----------------------------------------+
| LOADING TABLE                          |
+----------------------------------------+
| TABLE (1 of 1): `dnothi`.`ontime`      |
| Commands executed successfully: 3 of 3 |
| Warnings encountered: 0                |
| Table loaded successfully!             |
|   Total columns loaded: 110            |
|   Table loaded using 32 thread(s)      |
|                                        |
+----------------------------------------+
7 rows in set (14 min 46.6384 sec)

+-------------------------------------------------------------------------------+
| LOAD SUMMARY                                                                  |
+-------------------------------------------------------------------------------+
|                                                                               |
| SCHEMA                          TABLES       TABLES      COLUMNS         LOAD |
| NAME                            LOADED       FAILED       LOADED     DURATION |
| ------                          ------       ------      -------     -------- |
| `dnothi`                             1            0          110    14.77 min |
|                                                                               |
+-------------------------------------------------------------------------------+
6 rows in set (14 min 46.6384 sec)

Query OK, 0 rows affected (14 min 46.6384 sec)

# So at this stage data has been loaded into HeatWave Cluster
# But we didnt run any query in this Heatwave cluster yet
# Check whether have you executed any query over your Heatwave cluster usign the below command
> select * from performance_schema.global_status
where variable_name='rapid_query_offload_count';

# Lets run our previous query again which took around 8 mins withouty Heatwave
# I will exedcute this below query twice
# it took only 0.4999 to 0.5046 sec
SELECT year, Reporting_Airline, AVG(ArrDelay) AS avgArrDelay
FROM ontime
WHERE Reporting_Airline IN ('AA', 'UA', 'DL')
GROUP BY Reporting_Airline, year ORDER BY year, Reporting_Airline;

# This has taken only 0.499 to 0.5046 sec
# Now if yuo tried to check how mnay queries has been offlaoded to HeatWave cluster, run the below query in mysql shell
select * from performance_schema.global_status where variable_name = 'rapid_query_offload_count';
+---------------------------+----------------+
| VARIABLE_NAME             | VARIABLE_VALUE |
+---------------------------+----------------+
| rapid_query_offload_count | 2              |
+---------------------------+----------------+
1 row in set (0.0007 sec)

# How would you be sured that the table you want to use has been loaded to HeatWave
select rpt.NAME, rp.*
join performance_schema.rpd_table_id rpt
on rpt.id=rp.id\G
*************************** 1. row ***************************
                NAME: dnothi.ontime
                  ID: 1
        SNAPSHOT_SCN: 3
       PERSISTED_SCN: 3
           POOL_TYPE: RAPID_LOAD_POOL_TRANSACTIONAL
 DATA_PLACEMENT_TYPE: PrimaryKey
               NROWS: 166628027
         LOAD_STATUS: AVAIL_RPDGSTABSTATE
       LOAD_PROGRESS: 100
          SIZE_BYTES: 57646514176
         QUERY_COUNT: 2
        LAST_QUERIED: 2022-04-08 09:49:31.872549
LOAD_START_TIMESTAMP: 2022-04-08 09:24:15.858082
  LOAD_END_TIMESTAMP: 2022-04-08 09:39:02.227809
1 row in set (0.0006 sec)

# How would you be sure that the query that you are executing will be offlaoded to HeatWave or Not
EXPLAIN SELECT year, Reporting_Airline, AVG(ArrDelay) AS avgArrDelay
FROM ontime
WHERE Reporting_Airline IN ('AA', 'UA', 'DL')
GROUP BY Reporting_Airline, year ORDER BY year, Reporting_Airline\G

*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: ontime
   partitions: NULL
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 158731404
     filtered: 30.000001907348633
        Extra: Using where; Using temporary; Using filesort; Using secondary engine RAPID		#<<--------- See, secondy engine is 'RAPID'. This make sures that your query is offlioaded to HeatWave
        
        
# Lets faster this query execution cabpabilities of HeatWave even more using Machine Learning
# MYSQL HeatWave includes several AutoPilot processes. 
# Lets see, if AutoPilot encoding will be able to improve our query even more
# Lets get the recommendation from MySQL HeatWave AutoPilot
# # 01 Using Autopilot Encoding advisor

CALL sys.heatwave_advisor(JSON_OBJECT("auto_enc",JSON_OBJECT("mode","recommend")));
+-------------------------------+
| INITIALIZING HEATWAVE ADVISOR |
+-------------------------------+
| Version: 1.26                 |
|                               |
| Output Mode: normal           |
| Excluded Queries: 0           |
| Target Schemas: All           |
|                               |
+-------------------------------+
6 rows in set (0.7538 sec)

+---------------------------------------------------------+
| ANALYZING LOADED DATA                                   |
+---------------------------------------------------------+
| Total 1 tables loaded in HeatWave for 1 schemas         |
| Tables excluded by user: 0 (within target schemas)      |
|                                                         |
| SCHEMA                            TABLES        COLUMNS |
| NAME                              LOADED         LOADED |
| ------                            ------         ------ |
| `dnothi`                               1            110 |
|                                                         |
+---------------------------------------------------------+
8 rows in set (0.7538 sec)

+--------------------------------------------------------------------------------------------+
| ENCODING SUGGESTIONS                                                                       |
+--------------------------------------------------------------------------------------------+
| Total Auto Encoding suggestions produced for 6 columns                                     |
| Queries executed: 3                                                                        |
|   Total query execution time: 998.62 ms                                                    |
|   Most recent query executed on: Friday 8th April 2022 09:49:31                            |
|   Oldest query executed on: Friday 8th April 2022 09:49:04                                 |
|                                                                                            |
|                                                    CURRENT           SUGGESTED             |
| COLUMN                                              COLUMN              COLUMN             |
| NAME                                              ENCODING            ENCODING             |
| ------                                            --------           ---------             |
| `dnothi`.`ontime`.`ArrTimeBlk`                      VARLEN          DICTIONARY             |
| `dnothi`.`ontime`.`DepTimeBlk`                      VARLEN          DICTIONARY             |
| `dnothi`.`ontime`.`DestCityName`                    VARLEN          DICTIONARY             |
| `dnothi`.`ontime`.`DestStateName`                   VARLEN          DICTIONARY             |
| `dnothi`.`ontime`.`OriginCityName`                  VARLEN          DICTIONARY             |
| `dnothi`.`ontime`.`OriginStateName`                 VARLEN          DICTIONARY             |
|                                                                                            |
| Applying the suggested encodings might improve query performance and cluster memory usage. |
|   Estimated HeatWave cluster memory savings: -3.18 GiB                                     |
|                                                                                            |
+--------------------------------------------------------------------------------------------+
20 rows in set (0.7538 sec)

+----------------------------------------------------------------------------------------------------------------+
| SCRIPT GENERATION                                                                                              |
+----------------------------------------------------------------------------------------------------------------+
| Script generated for applying suggestions for 1 loaded tables                                                  |
|                                                                                                                |
| Applying changes will take approximately 4.42 min                                                              |
|                                                                                                                |
| Retrieve script containing 11 generated DDL commands using the query below:                                    |
|   SELECT log->>"$.sql" AS "SQL Script" FROM sys.heatwave_advisor_report WHERE type = "sql" ORDER BY id; #,,---- this is the command you need to execute next       |
|                                                                                                                |
| Caution: Executing the generated script will alter the column comment and secondary engine flags in the schema |
|                                                                                                                |
+----------------------------------------------------------------------------------------------------------------+
9 rows in set (0.7538 sec)

Query OK, 0 rows affected (0.7538 sec)

# Lets execute the above marked command
# Retrieve script containing 11 generated DDL commands using the query below. and then execute these commands sequentailly
# First, set the thread to 32
# unload the ontime table from RAPID (HeatWave Cluster)
# Then set your SECONDARY_ENGINE to NULL. 
# Then executes the comamnds which will alter the column encodings from 'VARLEN' to 'DICTIONARY'
# Reset the SECONDARY_ENGINE to 'RAPID'
# Finally reload the table into Heatwave cluster again.

SELECT log->>"$.sql" AS "SQL Script" FROM sys.heatwave_advisor_report WHERE type = "sql" ORDER BY id;

+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| SQL Script                                                                                                                                                                                                     |
+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| SET SESSION innodb_parallel_read_threads = 32;                                                                                                                                                                 |
| ALTER TABLE `dnothi`.`ontime` SECONDARY_UNLOAD;                                                                                                                                                                |
| ALTER TABLE `dnothi`.`ontime` SECONDARY_ENGINE=NULL;                                                                                                                                                           |
| ALTER TABLE `dnothi`.`ontime` MODIFY `ArrTimeBlk` varchar(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ';       |
| ALTER TABLE `dnothi`.`ontime` MODIFY `DepTimeBlk` varchar(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ';       |
| ALTER TABLE `dnothi`.`ontime` MODIFY `DestCityName` varchar(34) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ';    |
| ALTER TABLE `dnothi`.`ontime` MODIFY `DestStateName` varchar(46) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ';   |
| ALTER TABLE `dnothi`.`ontime` MODIFY `OriginCityName` varchar(34) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ';  |
| ALTER TABLE `dnothi`.`ontime` MODIFY `OriginStateName` varchar(46) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED '; |
| ALTER TABLE `dnothi`.`ontime` SECONDARY_ENGINE=RAPID;                                                                                                                                                          |
| ALTER TABLE `dnothi`.`ontime` SECONDARY_LOAD;                                                                                                                                                                  |
+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
11 rows in set (0.0008 sec)

# After all the altering as suggested by the Heatwave advisor, lets rerun our main query again which took 0.499 to .500 secs.
# As there is only one table, there would not be much improvement in execution.
# After Heatwave autopilot, the execution time improved to be a little to 0.46s
# As we had only one query and a single table, there’s not much improvement. But if you use multiple queries and joins, this can provide even better results !
SELECT year, Reporting_Airline, AVG(ArrDelay) AS avgArrDelay
FROM ontime
WHERE Reporting_Airline IN ('AA', 'UA', 'DL')
GROUP BY Reporting_Airline, year ORDER BY year, Reporting_Airline;

# 02. Using auto-pilot placement advisor
# If we have multiple tables, then its suggeted to use "Autopilot Placement" advisor for further performance and memory optimization
# Autopilot placement advisor might not suggest you anything until/unless you have 5 queries with (JOIN/GROUP-BY Clause) on target_schema

CALL sys.heatwave_advisor(JSON_OBJECT("target_schema",JSON_ARRAY("dnothi")));
+-------------------------------+
| INITIALIZING HEATWAVE ADVISOR |
+-------------------------------+
| Version: 1.26                 |
|                               |
| Output Mode: normal           |
| Excluded Queries: 0           |
| Target Schemas: 1             |
|                               |
+-------------------------------+
6 rows in set (0.1035 sec)

+---------------------------------------------------------+
| ANALYZING LOADED DATA                                   |
+---------------------------------------------------------+
| Total 1 tables loaded in HeatWave for 1 schemas         |
| Tables excluded by user: 0 (within target schemas)      |
|                                                         |
| SCHEMA                            TABLES        COLUMNS |
| NAME                              LOADED         LOADED |
| ------                            ------         ------ |
| `dnothi`                               1            110 |
|                                                         |
+---------------------------------------------------------+
8 rows in set (0.1035 sec)

+-------------------------------------------------------------------+
| AUTO DATA PLACEMENT                                               |
+-------------------------------------------------------------------+
| Auto Data Placement Configuration:                                |
|                                                                   |
|   Minimum benefit threshold: 1%                                   |
|                                                                   |
| Producing Data Placement suggestions for current setup:           |
|                                                                   |
|   Tables Loaded: 1                                                |
|   Queries used: 2                                                 |
|     Total query execution time: 902.28 ms                         |
|     Most recent query executed on: Friday 8th April 2022 10:27:53 |
|     Oldest query executed on: Friday 8th April 2022 10:27:48      |
|   HeatWave cluster size: 2 nodes                                  |
|                                                                   |
+-------------------------------------------------------------------+
13 rows in set (0.1035 sec)

+--------------------------------------------------------------------------------------------+
| DATA PLACEMENT SUGGESTIONS                                                                 |
+--------------------------------------------------------------------------------------------+
| No Data Placement suggestion produced                                                      |
|   Issue: Need at least 5 executed queries containing JOIN/GROUP-BY clause on target schema | 
+--------------------------------------------------------------------------------------------+
2 rows in set (0.1035 sec)



        