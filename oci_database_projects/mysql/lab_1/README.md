# Oracle Cloud Infrastructure| MDS - MySQL Database Service, HeatWave and Machine Learning | HeatWave Advisor
**Core Ref:**
- [x] https://blogs.oracle.com/mysql/post/using-mysql-database-service-in-oci-part-1
- [x] https://blogs.oracle.com/mysql/post/using-mysql-database-service-in-oci-part-2
- [x] https://blogs.oracle.com/mysql/post/using-mysql-database-service-in-oci-part-3

**Table of Contents**
<!-- vscode-markdown-toc -->
* 1. [A. Optional](#A.Optional)
* 2. [ocicli mysql commands](#ociclimysqlcommands)
* 3. [B. Prerequisite Info](#B.PrerequisiteInfo)
* 4. [Step-1: Setting the mysql shell at Oracle Linux 8.5](#Step-1:SettingthemysqlshellatOracleLinux8.5)
	* 4.1. [1.1 Create a db_config file at HOME directory](#Createadb_configfileatHOMEdirectory)
	* 4.2. [1.2 Having an Issue in mysql setup?](#HavinganIssueinmysqlsetup)
	* 4.3. [1.3 Downlaod the mysql plugins](#Downlaodthemysqlplugins)
	* 4.4. [1.4 List all MySQL Server plugins](#ListallMySQLServerplugins)
	* 4.5. [1.5 PIP issue in Oracle Linux 8.5 | How to resolve it ?](#PIPissueinOracleLinux8.5Howtoresolveit)
	* 4.6. [1.6 Enable MySQL Shell history](#EnableMySQLShellhistory)
* 5. [Step-2 Create a Database Named "dnothi"](#Step-2CreateaDatabaseNameddnothi)
	* 5.1. [2.1 Create the Schema from dumps to avoid manual labor](#CreatetheSchemafromdumpstoavoidmanuallabor)
	* 5.2. [2.2 create a table named <ontime> with the schema derived from the csv file](#createatablenamedontimewiththeschemaderivedfromthecsvfile)
	* 5.3. [2.3 Lets get the table, check whether it is created](#Letsgetthetablecheckwhetheritiscreated)
	* 5.4. [2.4 Upload sample data into the dnothi database; specific to a table named "ontime"](#Uploadsampledataintothednothidatabasespecifictoatablenamedontime)
* 6. [Step-3 DB Operations](#Step-3DBOperations)
	* 6.1. [3.1 list all users in the DB](#listallusersintheDB)
	* 6.2. [3.2 Decribe the table and get its schema](#Decribethetableandgetitsschema)
	* 6.3. [3.3 After you have imported the data into table, lets check how much data is imported](#Afteryouhaveimportedthedataintotableletscheckhowmuchdataisimported)
	* 6.4. [3.4 List all columes in the table](#Listallcolumesinthetable)
	* 6.5. [3.5 list rows from table](#listrowsfromtable)
	* 6.6. [3.6 Try to alter a value](#Trytoalteravalue)
	* 6.7. [3.7 Check how much data is loaded into the database](#Checkhowmuchdataisloadedintothedatabase)
	* 6.8. [3.8 Check the read_only and super_read_only status of your database](#Checktheread_onlyandsuper_read_onlystatusofyourdatabase)
	* 6.9. [3.9 Check the health of all databases. This command should only be executed inside the terminal](#Checkthehealthofalldatabases.Thiscommandshouldonlybeexecutedinsidetheterminal)
	* 6.10. [3.10 Check the performance_schema.errorlog](#Checktheperformance_schema.errorlog)
* 7. [Step 4 Import Data from mysqlsh to OSS](#Step4ImportDatafrommysqlshtoOSS)
* 8. [Step-5 Check the mysqldump commands](#Step-5Checkthemysqldumpcommands)
	* 8.1. [5.1 Dumping a database](#Dumpingadatabase)
	* 8.2. [5.2 loading dumped data into database](#loadingdumpeddataintodatabase)
* 9. [Step-6 Heatwave](#Step-6Heatwave)
	* 9.1. [6.1 Query-1: Before Heatwave](#Query-1:BeforeHeatwave)
	* 9.2. [6.2 Check whether the Heatwave is ready or is enabled. If you didnt enable the heatwave cluster, then](#CheckwhethertheHeatwaveisreadyorisenabled.Ifyoudidntenabletheheatwaveclusterthen)
	* 9.3. [6.3 Check whether have you executed any query over your Heatwave cluster using the below command](#CheckwhetherhaveyouexecutedanyqueryoveryourHeatwaveclusterusingthebelowcommand)
	* 9.4. [6.4 Lets run our previous query again which took around 8 mins without Heatwave](#Letsrunourpreviousqueryagainwhichtookaround8minswithoutHeatwave)
	* 9.5. [6.5 Now if you tried to check how many queries has been offlaoded to HeatWave cluster, run the below query in mysql shell](#NowifyoutriedtocheckhowmanyquerieshasbeenofflaodedtoHeatWaveclusterrunthebelowqueryinmysqlshell)
	* 9.6. [6.6 How would you be sured that the table you want to use has been loaded to HeatWave](#HowwouldyoubesuredthatthetableyouwanttousehasbeenloadedtoHeatWave)
	* 9.7. [6.7 How would you be sure that the query that you are executing will be offloaded to HeatWave or Not](#HowwouldyoubesurethatthequerythatyouareexecutingwillbeoffloadedtoHeatWaveorNot)
* 10. [Step-7 HeatWave and MachineLearning](#Step-7HeatWaveandMachineLearning)
	* 10.1. [7.1 Using Autopilot Encoding advisor](#UsingAutopilotEncodingadvisor)
		* 10.1.1. [7.1.1 Lets execute the above marked command](#Letsexecutetheabovemarkedcommand)
		* 10.1.2. [7.1.2 Now Alter as suggested above](#NowAlterassuggestedabove)
		* 10.1.3. [7.1.3 After all the altering as suggested by the Heatwave advisor, lets rerun our main query again which took 0.499 to .500 secs.](#AfterallthealteringassuggestedbytheHeatwaveadvisorletsrerunourmainqueryagainwhichtook0.499to.500secs.)
	* 10.2. [7.2. Using auto-pilot placement advisor](#Usingauto-pilotplacementadvisor)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

---
##  1. <a name='A.Optional'></a>Optional
**Deploy MySQL DB in OCI using terraform**
https://github.com/oracle-quickstart/oci-mysql

##  2. <a name='ociclimysqlcommands'></a>ocicli mysql commands
Ref: https://docs.public.oneportal.content.oci.oraclecloud.com/en-us/iaas/tools/oci-cli/3.0.3/oci_cli_docs/cmdref/mysql.html
```bash
> oci mysql db-system list --compartment-id ocid1.compartment.oc1..aaaaaaaa5hplc4q67l76kzeygvcbbu73da3kxhndhogtfvxgwtpd2xzayecq --profile DEFAULT
> oci mysql version list --compartment-id ocid1.compartment.oc1..aaaaaaaa5hplc4q67l76kzeygvcbbu73da3kxhndhogtfvxgwtpd2xzayecq --profile DEFAULT
```

##  3. <a name='B.PrerequisiteInfo'></a>Prerequisite Info

**Bastion Host**
- [x] Bastion Host: 155.248.250.144 user: opc
- [x] OS: Oracle Linux 8.5
- [x] Kernel: hostnamectl | grep Kernel -> Linux 5.4.17-2136.305.5.5.el8uek.x86_64

**MDS - MySQL Database**
- [x]  Shape: MySQL.HeatWave.VM.Standard.E3 ** This shape will let you enable HeatWave later
- [x]  OCPU Count: 1
- [x]  Memory: 512 GB
- [x]  Storage Size: 100 GBMySQL version: 8.0.28
---


##  4. <a name='Step-1:SettingthemysqlshellatOracleLinux8.5'></a>Step-1: Setting the mysql shell at Oracle Linux 8.5
- [x] Install mysql shell - client
- [x] Note that, it's not mysql-server, instead its a mysql-client
  
```bash
> sudo yum install -y mysql-community-client mysql-shell
```

###  4.1. <a name='Createadb_configfileatHOMEdirectory'></a>Create a db_config file at HOME directory
```bash
> cd $HOME
> cat db_conf
---
[client]
host=10.0.1.159
user=admin
password=<your db passowrd>
database=dnothi
---
```

###  4.2. <a name='HavinganIssueinmysqlsetup'></a>Having an Issue in mysql setup?  
- [x] if your mysql setup is having an issue, try below. 
- [x] I had an issue, thats why tried so
- [x] Ref: https://pupuweb.com/solved-fix-unable-find-match-error-mysql-centos/

```bash
sudo yum module disable mysql
sudo yum install mysql-community-server
yum install mysql
```

###  4.3. <a name='Downlaodthemysqlplugins'></a>Downlaod the mysql plugins
```bash
cd .mysqlsh/
git clone https://github.com/lefred/mysqlshell-plugins.git plugins
```
- [x] Now, if you run mysqlsh, plugins will be loaded
- [ ] Check the mysql shell plugins here in: https://github.com/jahidul-arafat/mysqlshell-plugins

###  4.4. <a name='ListallMySQLServerplugins'></a>List all MySQL Server plugins
```bash
> mysqlsh admin@10.0.1.159 --sql
mysql > SHOW PLUGINS\G
```

###  4.5. <a name='PIPissueinOracleLinux8.5Howtoresolveit'></a>PIP issue in Oracle Linux 8.5 | How to resolve it ?
- [x] Resolving the pip issue (pip3.9) and install required plugins <requests, pyclamd>
- [x] How to fix the pip error as Oracle MySQL 8.0.24 supports only pip version 3.9
- [x] when the bastion host with latest Oracle Linux having python and pip version 3.6
- [x] So, if the pip version is not resolved, then mysql shell can't install the extra modules
- [x] Ref: https://lefred.be/content/mysql-shell-and-extra-python-modules/

```bash
> wget https://bootstrap.pypa.io/get-pip.py
> mysqlsh --py -f get-pip.py
> mysqlsh --pym pip install --user prettytable
> mysqlsh --pym pip install --user requests
> mysqlsh --pym pip install --user pyclamd
```

###  4.6. <a name='EnableMySQLShellhistory'></a>Enable MySQL Shell history
Ref: https://lefred.be/content/reminder-when-using-mysql-shell/
```bash
mysqlsh admin@10.0.1.159
mysql-js > shell.options.setPersist('history.autoSave', 1)
mysql-js> shell.options.setPersist('history.maxSize', 5000)
mysql-js> shell.options.setPersist('defaultMode', 'sql')    # set the default mode to sql
```

##  5. <a name='Step-2CreateaDatabaseNameddnothi'></a>Step-2 Create a Database Named "dnothi"
mysqlsh admin@10.0.1.159 --sql
sql > create database dnothi;
    > show databases;

###  5.1. <a name='CreatetheSchemafromdumpstoavoidmanuallabor'></a>Create the Schema from dumps to avoid manual labor
- [x] From the CSV File create the Schema; Later using this schema we will create a table named "ontime"
- [x] Note that, for a table to be in MySQL HeatWave this must need to have a primary key 
- [x] This is mandatory with HeatWave and for HA and recommended for InnoDB. Without the primary key, if you try to use that table in HeatWave, this will trigger an error

```bash
mysqlsh admin@10.0.1.159 --py 
Py > schema_utils.create_from_csv(
   -> 'On_Time_Reporting_Carrier_On_Time_Performance_(1987_present)_2020_5.csv',
   -> pk_auto_inc=True, first_as_pk=False, limit=1000) # I have limited the rows to parse 100 entries (there are 602454 in this file)
```

###  5.2. <a name='createatablenamedontimewiththeschemaderivedfromthecsvfile'></a>create a table named <ontime> with the schema derived from the csv file
```bash
mysqlsh admin@10.0.1.159 --sql
sql> use dnothi;
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
```

###  5.3. <a name='Letsgetthetablecheckwhetheritiscreated'></a>Lets get the table, check whether it is created
```bash
use dnothi;
show tables;
```

###  5.4. <a name='Uploadsampledataintothednothidatabasespecifictoatablenamedontime'></a>Upload sample data into the dnothi database; specific to a table named "ontime"
What we are going to do? Lets have a look at the csv files we gonna import into our database table.
```bash
> ls
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1987_10.zip
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1987_11.zip
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1987_12.zip
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1988_1.zip
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1988_10.zip
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1988_11.zip
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1988_12.zip
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1988_2.zip
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1988_3.zip
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1988_4.zip
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1988_5.zip
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1988_6.zip
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1988_7.zip
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1988_8.zip
On_Time_Reporting_Carrier_On_Time_Performance_1987_present_1988_9.zip
```
So, all the files are starting with "On_Time" and ending with a ".zip" extension
- [x] We will traverse each of these files
- [x] Unzipe those one after another
- [x] Rename the files for easy processing 
- [x] using the mysqlsl import-table will import the csv file into table "ontime"
- [x] We have deployed 4 threads here, this is based on your DB instances. If you have a high thread DB instance, try to increase the threads to 8 or 16 or even higher


```bash
#!/usr/bin/bash
counter=0
for i in `ls On_Time*zip`
do
  echo "Count : " $counter
  echo "--------------------------------------------------------"
  unzip -o $i
  #file_csv=$(ls *.csv | sed 's/(//; s/)//')
  #mv *.csv "$file_csv"
  mv *.csv dummy_data_$counter.csv
  
  mysqlsh mysql://admin@10.0.1.159/dnothi -- \
  util import-table dummy_data_$counter.csv \
  --table="ontime" --dialect="csv-unix" \
  --skipRows=1 --showProgress --threads=4
  
  #rm -rf "${file_csv}"
  
  echo "Printing the file property"
  file_property=$(ls -lh dummy_data_$counter.csv)
  echo $file_property
  echo ""
  echo ""

  rm -rf dummy_data_$counter.csv
  rm -rf readme.html
  (( counter++ ))
done
```

##  6. <a name='Step-3DBOperations'></a>Step-3 DB Operations
###  6.1. <a name='listallusersintheDB'></a>list all users in the DB
Ref: https://www.javatpoint.com/mysql-show-users
```bash
mysqlsh admin@10.0.1.159 --sql
sql > SELECT user, host, db, command FROM information_schema.processlist;  
    > select user();
    > select current_user();
    > SELECT user, host, account_locked, password_expired FROM user;  
```

###  6.2. <a name='Decribethetableandgetitsschema'></a>Decribe the table and get its schema
```bash
mysqlsh admin@10.0.1.159 --sql
mysql > use dnothi;
      > describe ontime; # table name
```

###  6.3. <a name='Afteryouhaveimportedthedataintotableletscheckhowmuchdataisimported'></a>After you have imported the data into table, lets check how much data is imported
```bash
use dnothi;
SELECT COUNT(*) FROM ontime;
```

###  6.4. <a name='Listallcolumesinthetable'></a>List all columes in the table
```
use dnothi;
SELECT COUNT(*) AS NUMBEROFCOLUMNS 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE table_name = 'ontime';
```

###  6.5. <a name='listrowsfromtable'></a>list rows from table
```
use dnothi;
SELECT *
FROM ontime
LIMIT 100;
```

###  6.6. <a name='Trytoalteravalue'></a>Try to alter a value
- [x] update option will fail if the mysql server is running in super privilege mode
- [x] Usually mysql server will not be in read_only or super read_only mode 
- [x] Execute this statement in terminal mysqlsh
```bash
use dnothi;
UPDATE ontime SET Quarter=5 WHERE DOT_ID_Reporting_Airline=19391;
```

###  6.7. <a name='Checkhowmuchdataisloadedintothedatabase'></a>Check how much data is loaded into the database
```bash
SELECT TABLE_SCHEMA,
sys.format_bytes(sum(table_rows)) `ROWS`,
sys.format_bytes(sum(data_length)) DATA,
sys.format_bytes(sum(index_length)) IDX,
sys.format_bytes(sum(data_length) + sum(index_length)) 'TOTAL SIZE',
round(sum(index_length) / sum(data_length),2) IDXFRAC
FROM information_schema.TABLES
GROUP By table_schema ORDER BY sum(DATA_length) DESC;
```

---
**NOTES**
- [x] If you’re using a cloud service for your MySQL database like AWS Aurora, you need to check for your innodb_read_only variable instead of the read-only variable.
- [x] This is because cloud services like AWS Aurora usually have multiple database instances, and you can only write to the main (master) database instance and not the secondary (slave) database instance.
SHOW GLOBAL VARIABLES LIKE 'innodb_read_only'; 
- [x] Disadvantage of read_only=1 
- [x] Ref: https://dev.mysql.com/worklog/task/?id=3602
---

###  6.8. <a name='Checktheread_onlyandsuper_read_onlystatusofyourdatabase'></a>Check the read_only and super_read_only status of your database
```bash
mysql > SHOW GLOBAL variables like 'read_only';
      > SELECT @@global.read_only, @@global.super_read_only;
      > SET global read_only=0;         # this require mysql root priviledge. Only at OCI, we only have ADMIN priviledge 
      > SET GLOBAL super_read_only = 0; # this require mysql root priviledge. Only at OCI, we only have ADMIN priviledge
```
###  6.9. <a name='Checkthehealthofalldatabases.Thiscommandshouldonlybeexecutedinsidetheterminal'></a>Check the health of all databases. This command should only be executed inside the terminal
```bash
mysqlcheck -h 10.0.1.159 -uadmin -p --all-databases
```

###  6.10. <a name='Checktheperformance_schema.errorlog'></a>Check the performance_schema.errorlog
```bash
SELECT * FROM performance_schema.error_log\G
```

##  7. <a name='Step4ImportDatafrommysqlshtoOSS'></a>Step-4 Import Data from mysqlsh to OSS
Ref: https://docs.oracle.com/en-us/iaas/mysql-database/doc/importing-and-exporting-databases.html#GUID-63396585-3ECA-4202-86D7-94C6DE08CCCD


##  8. <a name='Step-5Checkthemysqldumpcommands'></a>Step-5 Check the mysqldump commands
- [x] The set-gtid-purged function is set to AUTO by default in the GUI and it seems everytime you want to export without this parameter - you have to change it to OFF in Data Exports
- [x] When exporting, backing up and restoring Mysql database from the master database to the slave database, you need to pay attention to whether to enable GTID mode for the database. 
- [x] If you enable it, you should add the parameter -- set GTID purged = off to mysqldump data.
- [x] What is GTID? A global transaction identifier (GTID) is a unique identifier created and associated with each transaction committed on the server of origin (source). This identifier is unique not only to the server on which it originated, but is unique across all servers in a given replication setup. 
- [x] Ref: 
  - [x] https://programming.vip/docs/mysqldump-export-data-backup-set-gtid-purged-off.html
  - [x] https://www.sqlshack.com/how-to-backup-and-restore-mysql-databases-using-the-mysqldump-command/

###  8.1. <a name='Dumpingadatabase'></a>Dumping a database
```bash
mysqldump -h 10.0.1.159 -u admin -p --set-gtid-purged=OFF dnothi > dnothi_dump.sql
mysqldump -alv -h 10.0.1.159 -u admin -p --set-gtid-purged=OFF dnothi > airline_dump.sql
```

###  8.2. <a name='loadingdumpeddataintodatabase'></a>loading dumped data into database
```bash
mysql -h 10.0.1.150 -u admin -p demodb < demodb_dump.sql
```


##  9. <a name='Step-6Heatwave'></a>Step-6 Heatwave
###  9.1. <a name='Query-1:BeforeHeatwave'></a>Query-1: Before Heatwave 
This will take around 8 minutes of time.
```bash
mysql> use dnothi;
SELECT year, Reporting_Airline, AVG(ArrDelay) AS avgArrDelay
FROM ontime
WHERE Reporting_Airline IN ('AA', 'UA', 'DL')
GROUP BY Reporting_Airline, year ORDER BY year, Reporting_Airline;
```

###  9.2. <a name='CheckwhethertheHeatwaveisreadyorisenabled.Ifyoudidntenabletheheatwaveclusterthen'></a>Check whether the Heatwave is ready or is enabled. If you didnt enable the heatwave cluster, then 
- [x] rapid_cluster_status --> OFF
- [x] rapid_service_status --> OFFLINE

```bash
SELECT * FROM performance_schema.global_status
Where variable_name like 'rapid%er%status';
Output:
+----------------------+----------------+
| VARIABLE_NAME        | VARIABLE_VALUE |
+----------------------+----------------+
| rapid_cluster_status | ON             | # <<---
| rapid_service_status | ONLINE         | # <<---
+----------------------+----------------+
```

---
**NOTES**
- [x] From the OCI MySQL DB Console enable the MySQL HeatWave Cluster. 
- [x] Before that you need to run the estimator to estimate the number HeatWwave Node Required.
- [x] If your database is even chnaging and growing, you need to run the estimator often.
- [x] Default Nodes: 2
- [x] Load command to load the dnothi data into HeatWave once the cluster is ready
- [x] Having the possibility to load and unload data from HeatWave on demand allows you to pay for what you consume.
---
```bash
mysql> CALL sys.heatwave_load(JSON_ARRAY('dnothi'), NULL);
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
```
###  9.3. <a name='CheckwhetherhaveyouexecutedanyqueryoveryourHeatwaveclusterusingthebelowcommand'></a>Check whether have you executed any query over your Heatwave cluster using the below command
- [x] So at this stage data has been loaded into HeatWave Cluster
- [x] But we didnt run any query in this Heatwave cluster yet
- [x] Check whether have you executed any query over your Heatwave cluster using the below command

```bash
mysql> select * from performance_schema.global_status
where variable_name='rapid_query_offload_count';
```

###  9.4. <a name='Letsrunourpreviousqueryagainwhichtookaround8minswithoutHeatwave'></a>Lets run our previous query again which took around 8 mins without Heatwave
- [x] I will execute this below query twice
- [x] it took only 0.4999 to 0.5046 sec

```bash
mysql> SELECT year, Reporting_Airline, AVG(ArrDelay) AS avgArrDelay
FROM ontime
WHERE Reporting_Airline IN ('AA', 'UA', 'DL')
GROUP BY Reporting_Airline, year ORDER BY year, Reporting_Airline;
```
*This has taken only 0.499 to 0.5046 sec*

###  9.5. <a name='NowifyoutriedtocheckhowmanyquerieshasbeenofflaodedtoHeatWaveclusterrunthebelowqueryinmysqlshell'></a>Now if you tried to check how many queries has been offlaoded to HeatWave cluster, run the below query in mysql shell
```bash
mysql> select * from performance_schema.global_status where variable_name = 'rapid_query_offload_count';
+---------------------------+----------------+
| VARIABLE_NAME             | VARIABLE_VALUE |
+---------------------------+----------------+
| rapid_query_offload_count | 2              |
+---------------------------+----------------+
1 row in set (0.0007 sec)
```

###  9.6. <a name='HowwouldyoubesuredthatthetableyouwanttousehasbeenloadedtoHeatWave'></a>How would you be sured that the table you want to use has been loaded to HeatWave
```bash
select rpt.NAME, rp.*
from performance_schema.rpd_tables rp
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
```

###  9.7. <a name='HowwouldyoubesurethatthequerythatyouareexecutingwillbeoffloadedtoHeatWaveorNot'></a>How would you be sure that the query that you are executing will be offloaded to HeatWave or Not
```bash
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
```       

##  10. <a name='Step-7HeatWaveandMachineLearning'></a>Step-7 HeatWave and MachineLearning      
- [x] Lets faster this query execution capabilities of HeatWave even more using Machine Learning
- [x] MYSQL HeatWave includes several AutoPilot processes. 
- [x] Lets see, if AutoPilot encoding will be able to improve our query even more
- [x] Lets get the recommendation from MySQL HeatWave AutoPilot

###  10.1. <a name='UsingAutopilotEncodingadvisor'></a>Using Autopilot Encoding advisor

```bash
mysql> CALL sys.heatwave_advisor(JSON_OBJECT("auto_enc",JSON_OBJECT("mode","recommend")));
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
|   SELECT log->>"$.sql" AS "SQL Script" FROM sys.heatwave_advisor_report WHERE type = "sql" ORDER BY id; #<<---- this is the command you need to execute next       |
|                                                                                                                |
| Caution: Executing the generated script will alter the column comment and secondary engine flags in the schema |
|                                                                                                                |
+----------------------------------------------------------------------------------------------------------------+
9 rows in set (0.7538 sec)

Query OK, 0 rows affected (0.7538 sec)
```

####  10.1.1. <a name='Letsexecutetheabovemarkedcommand'></a>Lets execute the above marked command
- [x] Retrieve script containing 11 generated DDL commands using the query below. and then execute these commands sequentailly
- [x] First, set the thread to 32
- [x] unload the ontime table from RAPID (HeatWave Cluster)
- [x] Then set your SECONDARY_ENGINE to NULL. 
- [x] Then executes the comamnds which will alter the column encodings from 'VARLEN' to 'DICTIONARY'
- [x] Reset the SECONDARY_ENGINE to 'RAPID'
- [x] Finally reload the table into Heatwave cluster again.

```bash
mysql> SELECT log->>"$.sql" AS "SQL Script" FROM sys.heatwave_advisor_report WHERE type = "sql" ORDER BY id;

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
```

####  10.1.2. <a name='NowAlterassuggestedabove'></a>Now Alter as suggested above
```bash
mysql> SET SESSION innodb_parallel_read_threads = 32;  
     > ALTER TABLE `dnothi`.`ontime` SECONDARY_UNLOAD;
     > ALTER TABLE `dnothi`.`ontime` SECONDARY_ENGINE=NULL;
     > ALTER TABLE `dnothi`.`ontime` MODIFY `ArrTimeBlk` varchar(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ';
     > ALTER TABLE `dnothi`.`ontime` MODIFY `DepTimeBlk` varchar(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ';       |
     > ALTER TABLE `dnothi`.`ontime` MODIFY `DestCityName` varchar(34) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ';    |
     > ALTER TABLE `dnothi`.`ontime` MODIFY `DestStateName` varchar(46) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ';   |
     > ALTER TABLE `dnothi`.`ontime` MODIFY `OriginCityName` varchar(34) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ';  |
     > ALTER TABLE `dnothi`.`ontime` MODIFY `OriginStateName` varchar(46) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED '; |
     > ALTER TABLE `dnothi`.`ontime` SECONDARY_ENGINE=RAPID;                                                                              > ALTER TABLE `dnothi`.`ontime` SECONDARY_LOAD;                 
```

####  10.1.3. <a name='AfterallthealteringassuggestedbytheHeatwaveadvisorletsrerunourmainqueryagainwhichtook0.499to.500secs.'></a>After all the altering as suggested by the Heatwave advisor, lets rerun our main query again which took 0.499 to .500 secs.
- [x] As there is only one table, there would not be much improvement in execution.
- [x] After Heatwave autopilot, the execution time improved to be a little to 0.46s
- [x] As we had only one query and a single table, there’s not much improvement. But if you use multiple queries and joins, this can provide even better results !

```bash
SELECT year, Reporting_Airline, AVG(ArrDelay) AS avgArrDelay
FROM ontime
WHERE Reporting_Airline IN ('AA', 'UA', 'DL')
GROUP BY Reporting_Airline, year ORDER BY year, Reporting_Airline;
```

###  10.2. <a name='Usingauto-pilotplacementadvisor'></a>Using auto-pilot placement advisor
- [x] If we have multiple tables, then its suggeted to use "Autopilot Placement" advisor for further performance and memory optimization
- [x] Autopilot placement advisor might not suggest you anything until/unless you have 5 queries with (JOIN/GROUP-BY Clause) on target_schema

```bash
mysql> CALL sys.heatwave_advisor(JSON_OBJECT("target_schema",JSON_ARRAY("dnothi")));
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
```



        