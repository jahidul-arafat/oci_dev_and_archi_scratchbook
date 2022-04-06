# deploy MySQL DB in OCI using terraform
# Ref: https://github.com/oracle-quickstart/oci-mysql

# create a table named <ontime> with the schema derived from the csv file
use airline;
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
use airline;
show tables;

# list all users in the DB
# Ref: https://www.javatpoint.com/mysql-show-users

# Decribe the table and get its schema
use airline;
describe ontime; # table name

# After you have imported the data into table, lets check how much data is imported
use airline;
SELECT COUNT(*) FROM ontime;

# List all columes in the table
use airline;
SELECT COUNT(*) AS NUMBEROFCOLUMNS 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE table_name = 'ontime';

# list rows from table
use airline;
SELECT *
FROM ontime
LIMIT 100;

#update option will fail as the mysql server is running in super privilege mode
use airline;
UPDATE ontime
SET Quarter=5
where DOT_ID_Reporting_Airline=19391;

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




