# Migrating MySQL 5.7 to MySQL 8 | Challenges
## References
- [x] Tips for Upgrading to from MySQL 5.7 to MySQL 8: https://severalnines.com/database-blog/tips-for-upgrading-mysql-5-7-to-mysql-8
- [ ] Upgrade prerequisites: https://dev.mysql.com/doc/refman/8.0/en/upgrade-prerequisites.html
- [ ] Changes in MySQL 8.0: https://dev.mysql.com/doc/refman/8.0/en/upgrading-from-previous-series.html#upgrade-server-changes
- [ ] Download MySQL CE: https://dev.mysql.com/downloads/mysql/

## Introduction:
- [x] For all of you who use MySQL 5.6, make sure you upgrade it to MySQL 5.7 first and then eventually to MySQL 8.0 
- [x] However, always note that migration is a one-way ticket. Once the upgrade is complte, there is no coming back. If you are plannign to migrate the MySQL 5.7 to MySQL 8.0, make sure to take a backup of your database directly before upgrade. 

## Priliminary Checklist
- [x] Features Removed in MySQL 8.0. Click [here](https://dev.mysql.com/doc/refman/8.0/en/mysql-nutshell.html#mysql-nutshell-removals) for details.
  - [ ] Some InnoDB Information Schema Views renamed
  - [ ] Features related to account management removed
  - [ ] The query cache was removed
  - [ ] The data dictionary provides information about database objects, so the server no longer checks directory names in the data directory to find databases.
  - [ ] The DDL log, also known as the metadata log, has been removed.
  - [ ] Read More at [here](https://dev.mysql.com/doc/refman/8.0/en/mysql-nutshell.html#mysql-nutshell-removals).
- [ ] Server and Status Variables and Options Added, Deprecated, or Removed in MySQL 8.0. Click [here](https://dev.mysql.com/doc/refman/8.0/en/added-deprecated-removed.html) for details.

## Sanity Checking Tools
### Sanity Checking Tool 01: mysqlcheck
```bash
# Before you attempt anything, you should double-check that your existing MySQL 5.7 setup ticks all the boxes on the sanity checklist before upgrtading to MySQL 8.0
> mysqlcheck -u root -p --all-databases --check-upgrade
# If mysqlcheck reports any error, correct the issues;
---
classicmodels.customers                            Table is already up to date
classicmodels.employees                            Table is already up to date
classicmodels.offices                              Table is already up to date
classicmodels.orderdetails                         Table is already up to date
classicmodels.orders                               Table is already up to date
classicmodels.payments                             Table is already up to date
classicmodels.productlines                         Table is already up to date
classicmodels.products                             Table is already up to date
demo.t1                                            Table is already up to date
demo.t2                                            Table is already up to date
demo.t3                                            Table is already up to date
mysql.columns_priv                                 Table is already up to date
mysql.component                                    Table is already up to date
mysql.db                                           Table is already up to date
mysql.default_roles                                Table is already up to date
mysql.engine_cost                                  Table is already up to date
mysql.func                                         Table is already up to date
mysql.general_log                                  Table is already up to date
mysql.global_grants                                Table is already up to date
mysql.gtid_executed                                Table is already up to date
mysql.help_category                                Table is already up to date
mysql.help_keyword                                 Table is already up to date
mysql.help_relation                                Table is already up to date
mysql.help_topic                                   Table is already up to date
mysql.innodb_index_stats                           Table is already up to date
mysql.innodb_table_stats                           Table is already up to date
mysql.password_history                             Table is already up to date
mysql.plugin                                       Table is already up to date
mysql.procs_priv                                   Table is already up to date
mysql.proxies_priv                                 Table is already up to date
mysql.replication_asynchronous_connection_failover Table is already up to date
mysql.replication_asynchronous_connection_failover_managed Table is already up to date
mysql.replication_group_configuration_version      Table is already up to date
mysql.replication_group_member_actions             Table is already up to date
mysql.role_edges                                   Table is already up to date
mysql.server_cost                                  Table is already up to date
mysql.servers                                      Table is already up to date
mysql.slave_master_info                            Table is already up to date
mysql.slave_relay_log_info                         Table is already up to date
mysql.slave_worker_info                            Table is already up to date
mysql.slow_log                                     Table is already up to date
mysql.tables_priv                                  Table is already up to date
mysql.time_zone                                    Table is already up to date
mysql.time_zone_leap_second                        Table is already up to date
mysql.time_zone_name                               Table is already up to date
mysql.time_zone_transition                         Table is already up to date
mysql.time_zone_transition_type                    Table is already up to date
mysql.user                                         Table is already up to date
sys.sys_config                                     Table is already up to date
---
```

### Sanity Checking Tool 02: util.checkForServerUpgrade()
- [x] You can use the upgrade checker utility to check MySQL 5.7 server instances, and MySQL 8.0 server instances at another GA (General Availability) status release within the MySQL 8.0 release series, for compatibility errors and issues for upgrading.
- [ ] If you invoke checkForServerUpgrade() without specifying a MySQL Server instance, the instance currently connected to the global session is checked.
- [x] When you invoke the upgrade checker utility, MySQL Shell connects to the server instance and tests the settings described at [Preparing Your Installation for Upgrade](https://dev.mysql.com/doc/refman/8.0/en/upgrade-prerequisites.html).
- [x] Ref: https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-utilities-upgrade.html


> The upgrade checker utility does not support checking MySQL Server instances at a version earlier than MySQL 5.7.
> 
> MySQL Server only supports upgrade between GA releases. Upgrades from non-GA releases of MySQL 5.7 or 8.0 are not supported.

#### Simulation

```bash
# To see the currently connected instance\
> mysqlsh root@localhost 
JS > \status
MySQL Shell version 8.0.29

Connection Id:                11
Default schema:               
Current schema:               
Current user:                 root@localhost
SSL:                          Cipher in use: TLS_AES_256_GCM_SHA384 TLSv1.3
Using delimiter:              ;
Server version:               8.0.28 Homebrew
Protocol version:             X protocol
Client library:               8.0.29
Connection:                   localhost via TCP/IP
TCP port:                     33060
Server characterset:          utf8mb4
Schema characterset:          utf8mb4
Client characterset:          utf8mb4
Conn. characterset:           utf8mb4
Result characterset:          utf8mb4
Compression:                  Enabled (DEFLATE_STREAM)
Uptime:                       5 hours 9 min 16.0000 sec

JS  > util.help("checkForServerUpgrade")

JS  > util.checkForServerUpgrade()
---
The MySQL server at localhost:33060, version 8.0.28 - Homebrew, will now be
checked for compatibility issues for upgrade to MySQL 8.0.29...

1) Issues reported by 'check table x for upgrade' command
  No issues found

Errors:   0
Warnings: 0
Notices:  0

No known compatibility errors or issues were found.
---

JS  > util.checkForServerUpgrade('root@localhost:3306',{"password":"XXXX","outputFormat":"JSON"})
    > util.checkForServerUpgrade('root@localhost:3306',{"password":"XXXX","outputFormat":"JSON", "targetVersion":"8.0.29"})
    > util.checkForServerUpgrade('root@localhost:3306',{"password":"XXXX","outputFormat":"JSON", "targetVersion":"8.0.29"})
    > util.checkForServerUpgrade('root@localhost:3306',{"password":"XXXX","outputFormat":"JSON", "targetVersion":"8.0.29", "configPath":"/opt/homebrew/etc/my.cnf"})

# Using mysqlsh command interface
> mysqlsh -- util checkForServerUpgrade root@localhost:3306 --target-version=8.0.29\ 
--output-format=JSON \
--config-path=/opt/homebrew/etc/my.cnf

```

#### What would upgrade check suggestions would look like?

```text
# A Sample of upgrade suggestions would looks like. Its not in my case, as I already have the latest version of MySQL 8.0.29

The MySQL server at example.com:3306, version
5.7.33-enterprise-commercial-advanced - MySQL Enterprise Server - Advanced Edition (Commercial),
will now be checked for compatibility issues for upgrade to MySQL 8.0.29...

1) Usage of old temporal type
  No issues found

2) Usage of db objects with names conflicting with new reserved keywords
  Warning: The following objects have names that conflict with new reserved keywords. 
  Ensure queries sent by your applications use `quotes` when referring to them or they will result in errors.
  More information: https://dev.mysql.com/doc/refman/en/keywords.html

  dbtest.System - Table name
  dbtest.System.JSON_TABLE - Column name
  dbtest.System.cube - Column name

3) Usage of utf8mb3 charset
  Warning: The following objects use the utf8mb3 character set. It is recommended to convert them to use 
  utf8mb4 instead, for improved Unicode support.
  More information: https://dev.mysql.com/doc/refman/8.0/en/charset-unicode-utf8mb3.html 
 
  dbtest.view1.col1 - column's default character set: utf8 

4) Table names in the mysql schema conflicting with new tables in 8.0
  No issues found

5) Partitioned tables using engines with non native partitioning
  Error: In MySQL 8.0 storage engine is responsible for providing its own
  partitioning handler, and the MySQL server no longer provides generic
  partitioning support. InnoDB and NDB are the only storage engines that
  provide a native partitioning handler that is supported in MySQL 8.0. A
  partitioned table using any other storage engine must be altered—either to
  convert it to InnoDB or NDB, or to remove its partitioning—before upgrading
  the server, else it cannot be used afterwards.
  More information:
    https://dev.mysql.com/doc/refman/8.0/en/upgrading-from-previous-series.html#upgrade-configuration-changes

  dbtest.part1_hash - MyISAM engine does not support native partitioning

6) Foreign key constraint names longer than 64 characters
  No issues found

7) Usage of obsolete MAXDB sql_mode flag
  No issues found

8) Usage of obsolete sql_mode flags
  No issues found

9) ENUM/SET column definitions containing elements longer than 255 characters 
  No issues found

10) Usage of partitioned tables in shared tablespaces
  Error: The following tables have partitions in shared tablespaces. Before upgrading to 8.0 they need 
  to be moved to file-per-table tablespace. You can do this by running query like 
  'ALTER TABLE table_name REORGANIZE PARTITION X INTO 
    (PARTITION X VALUES LESS THAN (30) TABLESPACE=innodb_file_per_table);'
  More information: https://dev.mysql.com/doc/refman/8.0/en/mysql-nutshell.html#mysql-nutshell-removals

  dbtest.table1 - Partition p0 is in shared tablespace tbsp4
  dbtest.table1 - Partition p1 is in shared tablespace tbsp4 

11) Circular directory references in tablespace data file paths
  No issues found

12) Usage of removed functions
  Error: Following DB objects make use of functions that have been removed in
    version 8.0. Please make sure to update them to use supported alternatives
    before upgrade.
  More information:
    https://dev.mysql.com/doc/refman/8.0/en/mysql-nutshell.html#mysql-nutshell-removals

  dbtest.view1 - VIEW uses removed function PASSWORD

13) Usage of removed GROUP BY ASC/DESC syntax 
  Error: The following DB objects use removed GROUP BY ASC/DESC syntax. They need to be altered so that 
  ASC/DESC keyword is removed from GROUP BY clause and placed in appropriate ORDER BY clause.
  More information: https://dev.mysql.com/doc/relnotes/mysql/8.0/en/news-8-0-13.html#mysqld-8-0-13-sql-syntax 

  dbtest.view1 - VIEW uses removed GROUP BY DESC syntax
  dbtest.func1 - FUNCTION uses removed GROUP BY ASC syntax 

14) Removed system variables for error logging to the system log configuration
  No issues found

15) Removed system variables
  Error: Following system variables that were detected as being used will be
    removed. Please update your system to not rely on them before the upgrade.
  More information: https://dev.mysql.com/doc/refman/8.0/en/added-deprecated-removed.html#optvars-removed

  log_builtin_as_identified_by_password - is set and will be removed
  show_compatibility_56 - is set and will be removed

16) System variables with new default values
  Warning: Following system variables that are not defined in your
    configuration file will have new default values. Please review if you rely on
    their current values and if so define them before performing upgrade.
  More information: https://mysqlserverteam.com/new-defaults-in-mysql-8-0/

  back_log - default value will change
  character_set_server - default value will change from latin1 to utf8mb4
  collation_server - default value will change from latin1_swedish_ci to
    utf8mb4_0900_ai_ci
  event_scheduler - default value will change from OFF to ON
[...]

17) Zero Date, Datetime, and Timestamp values
  Warning: By default zero date/datetime/timestamp values are no longer allowed
    in MySQL, as of 5.7.8 NO_ZERO_IN_DATE and NO_ZERO_DATE are included in
    SQL_MODE by default. These modes should be used with strict mode as they will
    be merged with strict mode in a future release. If you do not include these
    modes in your SQL_MODE setting, you are able to insert
    date/datetime/timestamp values that contain zeros. It is strongly advised to
    replace zero values with valid ones, as they may not work correctly in the
    future.
  More information:
    https://lefred.be/content/mysql-8-0-and-wrong-dates/

  global.sql_mode - does not contain either NO_ZERO_DATE or NO_ZERO_IN_DATE
    which allows insertion of zero dates
  session.sql_mode -  of 2 session(s) does not contain either NO_ZERO_DATE or
    NO_ZERO_IN_DATE which allows insertion of zero dates
  dbtest.date1.d - column has zero default value: 0000-00-00

18) Schema inconsistencies resulting from file removal or corruption
  No issues found

19) Tables recognized by InnoDB that belong to a different engine
  No issues found

20) Issues reported by 'check table x for upgrade' command
  No issues found

21) New default authentication plugin considerations
  Warning: The new default authentication plugin 'caching_sha2_password' offers
    more secure password hashing than previously used 'mysql_native_password'
    (and consequent improved client connection authentication). However, it also
    has compatibility implications that may affect existing MySQL installations. 
    If your MySQL installation must serve pre-8.0 clients and you encounter
    compatibility issues after upgrading, the simplest way to address those
    issues is to reconfigure the server to revert to the previous default
    authentication plugin (mysql_native_password). For example, use these lines
    in the server option file:
    
    [mysqld]
    default_authentication_plugin=mysql_native_password
    
    However, the setting should be viewed as temporary, not as a long term or
    permanent solution, because it causes new accounts created with the setting
    in effect to forego the improved authentication security.
    If you are using replication please take time to understand how the
    authentication plugin changes may impact you.
  More information:
    https://dev.mysql.com/doc/refman/8.0/en/upgrading-from-previous-series.html#upgrade-caching-sha2-password-compatibility-issues
    https://dev.mysql.com/doc/refman/8.0/en/upgrading-from-previous-series.html#upgrade-caching-sha2-password-replication

Errors:   7
Warnings: 36
Notices:  0

7 errors were found. Please correct these issues before upgrading to avoid compatibility issues.
```

## What Does these Sanity Checking Tools Really Checks? | Checklists
### Checklist Item 01: Sanity Check before upgrading
#### 1.1 Any Obsolete DataType ?
- [x] There must be no tables that use obsolet data types or function. 
  - [ ] In-place upgrade to MySQL 8.0 is not supported if tables contain old temporal columns in pre-5.6.4 format (TIME,DATETIME,TIMESTAMP columns without support for fractional seconds precision). If your tables still use the old temporal column format, upgrade using `REPAIR TABLE` before attmpting an in-place upgrade ti MySQL 8.0

#### 1.2  No orphan file
- [ ] There must be no orphan .frm files
- [ ] If MySQL crashes in  the middle of an ALTER TABLE operation, you may end up with an orphaned temporary table inside the InnoDB tablespace. 
- [ ] What if you have deleted the `.frm` file from the temprary table, you can copy any other InnoDB `.frm` file to have that name and drop the table as simulated below.
- [ ] What if you see a `.frm` orphan file strating with `#` i.e. `#sql-f3be_1.frm` and you are trying to drop it using the command `drop table #sql-f3be_1.frm`, this will result an `table not found`. To resolve use drop table `#mysql50##sql-f3be_1.frm`. The trick here is to prefix the tablename with #mysql50# to prevent the server from escaping the hash mark and hyphen
- [ ] Ref: https://mariadb.com/resources/blog/get-rid-of-orphaned-innodb-temporary-tables-the-right-way/

#### 1.3 Empty Definers in Triggers !
- [ ] Triggers must not have a missing or empty definer or an invalid creation context i.e.
  - [ ] character_set_client
  - [ ] collation_connection
  - [ ] Database collections 
  

#### Simulation
```bash
# Check if the following triggers or invalid context exists
# Note: A database trigger is procedural code that is automatically executed in response to certain events on a particular table or view in a database.
- [x] character_set_client
- [x] collation_connection
- [x] Database collections 

> mysqlsh root@localhost --sql
sql> use infomation_schema;
   > SHOW TRIGGERS\G 

# Showing a particular trigger in a particular schema 
sql> select * from information_schema.triggers where 
information_schema.triggers.trigger_name like '%trigger_name%' and 
information_schema.triggers.trigger_schema like '%data_base_name%'

# Check if any orphan file exists into the innoDB tablespace
## Where is the created MySQL database folder stored in Mac OSX?
mysql> SELECT @@datadir,@@innodb_data_home_dir;
+--------------------------+------------------------+
| @@datadir                | @@innodb_data_home_dir |
+--------------------------+------------------------+
| /opt/homebrew/var/mysql/ | NULL                   |
+--------------------------+------------------------+
1 row in set (0.00 sec)

> ls /opt/homebrew/var/mysql 
#ib_16384_0.dblwr			binlog.000010				jarotballs-MacBook-Pro.local.err
#ib_16384_1.dblwr			binlog.index				jarotballs-MacBook-Pro.local.pid
#innodb_temp				ca-key.pem				mysql
auto.cnf				ca.pem					mysql.ibd
binlog.000001				classicmodels				performance_schema
binlog.000002				client-cert.pem				private_key.pem
binlog.000003				client-key.pem				public_key.pem
binlog.000004				demo					server-cert.pem
binlog.000005				ib_buffer_pool				server-key.pem
binlog.000006				ib_logfile0				sys
binlog.000007				ib_logfile1				undo_001
binlog.000008				ibdata1					undo_002
binlog.000009				ibtmp1

# What if you have already deleted the .frm table from the directory and the database still showing show. You have to drop it inside from database either. Solution is ..
mysql > cp t1.frm "#sql-f3db_2.frm"
      > drop table `#mysql50##sql-f3db_2`;
# And on the server reboot, you should be free of those annoying message.

```

### Checklist Item 02: Is any of your tables having non-native storage engines?
#### 2.1 Any Partition Table without Native partition  support ?
- [x] There must be no partition tables that use a storage engine that does not have native partitioning support.
- [ ] If you have any storage engine other than native partitioned support,how to alter those to native storage engine.

#### 2.2 Must be no table patition that reside in shared InnoDB tablespace
- [x] Before upgrading to MySQL 8.0.13 or higher, there must be no table partitions that reside in shared InnoDB tablespaces, which include the system tablespace and general tablespaces. 

#### 2.3 Check if any storage enginer having MyISAM tables
- [ ] What if you have a storage engine having `MyISAM` tables and you need to convert those to `InnoDB`

#### 2.4 Conflicting with MySQL 8.0 Data Dictionary
- [ ] There must be no tables in the MySQL 5.7 mysql system database that have the same name as a table used by the MySQL 8.0 data dictionary

#### 2.5 Is FK constraints > 64 character ?
- [ ] There must be no tables that have foreign key constraint names longer than 64 characters

#### Simulation
```bash
# Lets find out whether exisiting database having any storage enginer other than the native partition support or in partitioned. 
> mysqlsh root@localhost --sql
sql> SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE ENGINE NOT IN ('innodb', 'ndbcluster')
AND CREATE_OPTIONS LIKE '%partitioned%';

# Say, you have a storage engine other than native support and you want to alter theat to INNODB
sql> alter table table_name ENGINE = INNODB;

# To make a partitioned table non-partitoned
sql> alter table table_name REMOVE PARTITIONING;

# Identify table partitions in shared tablespaces by querying INFORMATION_SCHEMA
# If MySQL 8.0
sql > SELECT DISTINCT NAME, SPACE, SPACE_TYPE FROM INFORMATION_SCHEMA.INNODB_TABLES
  WHERE NAME LIKE '%#P#%' AND SPACE_TYPE NOT LIKE 'Single';

# If MySQL 5.7
sql > SELECT DISTINCT NAME, SPACE, SPACE_TYPE FROM INFORMATION_SCHEMA.INNODB_SYS_TABLES
  WHERE NAME LIKE '%#P#%' AND SPACE_TYPE NOT LIKE 'Single';

# There must be no tables in the MySQL 5.7 mysql system database that have the same name as a table used by the MySQL 8.0 data dictionary. To identify tables with those names, execute this query:
# Any tables reported by the query must be dropped or renamed (use RENAME TABLE). This may also entail changes to applications that use the affected tables.
sql> SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE LOWER(TABLE_SCHEMA) = 'mysql'
and LOWER(TABLE_NAME) IN
(
'catalogs',
'character_sets',
'check_constraints',
'collations',
'column_statistics',
'column_type_elements',
'columns',
'dd_properties',
'events',
'foreign_key_column_usage',
'foreign_keys',
'index_column_usage',
'index_partitions',
'index_stats',
'indexes',
'parameter_type_elements',
'parameters',
'resource_groups',
'routines',
'schemata',
'st_spatial_reference_systems',
'table_partition_values',
'table_partitions',
'table_stats',
'tables',
'tablespace_files',
'tablespaces',
'triggers',
'view_routine_usage',
'view_table_usage'
);

# The INNODB_FOREIGN table provides metadata about InnoDB foreign keys. The INNODB_FOREIGN table has these columns:
-[x] ID: The name (not numeric) of the foreign key index, preceded by the schema(database) name i.e. test/products_fk
-[x] FOR_NAME: The name of the child table in this foreign key relationship.
-[x] REF_NAME: The name of the parent table in this foreign key relationship.
-[x] N_COLS: The number of columns in the foreign key index.
-[x] TYPE: A collection of bit flags with information about the foreign key column, ORed together. 
  0 = ON DELETE/UPDATE RESTRICT, 
  1 = ON DELETE CASCADE, 
  2 = ON DELETE SET NULL, 
  4 = ON UPDATE CASCADE, 
  8 = ON UPDATE SET NULL, 
  16 = ON DELETE NO ACTION, 
  32 = ON UPDATE NO ACTION.
sql> select * from information_schema.innodb_foreign\G
*************************** 1. row ***************************
      ID: classicmodels/customers_ibfk_1  (test/fk1)
FOR_NAME: classicmodels/customers         (test/child)
REF_NAME: classicmodels/employees         (test/parent)
  N_COLS: 1
    TYPE: 48
*************************** 2. row ***************************
      ID: classicmodels/employees_ibfk_1
FOR_NAME: classicmodels/employees
REF_NAME: classicmodels/employees
  N_COLS: 1
    TYPE: 48
*************************** 3. row ***************************
      ID: classicmodels/employees_ibfk_2
FOR_NAME: classicmodels/employees
REF_NAME: classicmodels/offices
  N_COLS: 1
    TYPE: 48
*************************** 4. row ***************************
      ID: classicmodels/orderdetails_ibfk_1
FOR_NAME: classicmodels/orderdetails
REF_NAME: classicmodels/orders
  N_COLS: 1
    TYPE: 48
*************************** 5. row ***************************
      ID: classicmodels/orderdetails_ibfk_2
FOR_NAME: classicmodels/orderdetails
REF_NAME: classicmodels/products
  N_COLS: 1
    TYPE: 48
*************************** 6. row ***************************
      ID: classicmodels/orders_ibfk_1
FOR_NAME: classicmodels/orders
REF_NAME: classicmodels/customers
  N_COLS: 1
    TYPE: 48
*************************** 7. row ***************************
      ID: classicmodels/payments_ibfk_1
FOR_NAME: classicmodels/payments
REF_NAME: classicmodels/customers
  N_COLS: 1
    TYPE: 48
*************************** 8. row ***************************
      ID: classicmodels/products_ibfk_1
FOR_NAME: classicmodels/products
REF_NAME: classicmodels/productlines
  N_COLS: 1
    TYPE: 48
8 rows in set (0.0068 sec)

# Check if you have tables having FK key contraint names longer than 64 characters. Use the below query to identify tables with constraint names that are too long.
sql> SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN
  (SELECT LEFT(SUBSTR(ID,INSTR(ID,'/')+1),
               INSTR(SUBSTR(ID,INSTR(ID,'/')+1),'_ibfk_')-1)
   FROM INFORMATION_SCHEMA.INNODB_FOREIGN
   WHERE LENGTH(SUBSTR(ID,INSTR(ID,'/')+1))>64);

#*** For a table with a constraint name that exceeds 64 characters, drop the constraint and add it back with constraint name that does not exceed 64 characters (use `ALTER TABLE`)
```

### Checklist Item 04: Chenages in Keywords and Reserved words in MySQL 8.
- [x] Find the reserved list [here](https://dev.mysql.com/doc/refman/8.0/en/keywords.html).

### Checklist Item 05: Obsolete SQL Modes in MySQL 8?
#### 5.1 Is MySQL 8.0 is failing at startup due to obsolete sql_mode ?
- [x] There must be no obsolete SQL Modes defined by `sql_mode` system variable.
- [ ] Attempting to use an obsolete SQL mode prevents MySQL 8.0 from starting.
- [ ] Applications that use obsolte SQL modes should be revised to avoid them.
- [ ] To avoid a startup failure on MySQL 8.0, remove any instance of NO_AUTO_CREATE_USER from sql_mode system variable settings in MySQL option files.
- [ ] Loading a dump file that includes the NO_AUTO_CREATE_USER SQL mode in stored program definitions into a MySQL 8.0 server causes a failure. 
- [ ] As of MySQL 5.7.24 and MySQL 8.0.13, mysqldump removes NO_AUTO_CREATE_USER from stored program definitions. 
- [ ] Dump files created with an earlier version of mysqldump must be modified manually to remove instances of NO_AUTO_CREATE_USER.

#### Simulation
```bash
# Check for your sql_mode in my.cnf
# Find where is your my.cnf file is
> find / -name my.cnf
[mysqld]
sql-mode="STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION"

# Check your current sql_modes
sql > show variables like 'sql_mode';
    > select @@sql_mode;

# Check the current global and session sql_mode
sql > select @@GLOBAL.sql_mode;
    > select @@SESSION.sql_mode;

# What if you accidentally enabled a sql_mode and you want to disable it now ?
# i.e. accidentally enabled sql_mode 'ONLY_FULL_GROUP_BY' and you want to remove it
sql > SET sql_mode = 'ONLY_FULL_GROUP_BY';
    > SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

# Be careful of iusing sql_mode=''. This actually clears all the modes currently enabled.
sql > sql_mode = '';
    > select @@sql_mode;

# or you can set the global and session sql_mode like below:
sql > set global sql_mode="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
    > set session sql_mode="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"

```

### Checklist Item 06: View Length and Changes in View
#### 6.1 length(view) should not exceed 64 characters
- [x] Note: views with column names up to 255 characters were permitted in MySQL 5.7. 
- [ ] To avoid upgrade errors, such views shouyld be altered before upgrading.
- [ ] Ref: https://dev.mysql.com/doc/refman/8.0/en/identifier-length.html

#### Simulation
```bash
# List all views in a specific database
# here I have two custom databases 'demo' and 'classicmodels'
sql > show databases; 
    > show full tables in demo where table_type like 'VIEW';

# Create a new view named 'myview' in database: demo
sql > CREATE VIEW demo.v AS SELECT 'a' || 'b' as mycolumn;
    > show full tables in demo where table_type like 'VIEW';
    +----------------+------------+
    | Tables_in_demo | Table_type |
    +----------------+------------+
    | myview         | VIEW       |
    | v              | VIEW       |
    +----------------+------------+
    > describe myview;
    +----------+------+------+-----+---------+-------+
    | Field    | Type | Null | Key | Default | Extra |
    +----------+------+------+-----+---------+-------+
    | mycolumn | int  | NO   |     | 0       |       |
    +----------+------+------+-----+---------+-------+

    > show create view demo.v\G   #tableName.viewName
    *************************** 1. row ***************************
                View: v
         Create View: CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `demo`.`v` AS select ((0 <> 'a') or (0 <> 'b')) AS `col1`
character_set_client: utf8mb4
collation_connection: utf8mb4_0900_ai_ci
1 row in set (0.0016 sec


# Lets be more specific
sql > SELECT TABLE_SCHEMA, TABLE_NAME 
      FROM information_schema.VIEWS 
      WHERE TABLE_SCHEMA LIKE 'your_db_name';

      +--------------+------------+
      | TABLE_SCHEMA | TABLE_NAME |
      +--------------+------------+
      | demo         | v          |
      | demo         | myview     |
      +--------------+------------+

# Check the length of a field in a view and check if it is exceedign 64 characters
sql > SELECT LENGTH('jahidul arafat');    # test
    > SELECT MAX(LENGTH(field_to_query)) FROM table_to_query;
    > SELECT LENGTH(field_to_query), COUNT(*) FROM table_to_query GROUP BY LENGTH(field_to_query);

# List all views from INFORMATION_SCHEMA
sql > select * FROM information_schema.views\G
    > SELECT DISTINCT table_name FROM information_schema.TABLES WHERE table_type = 'VIEW';
+-----------------------------------------------+
| TABLE_NAME                                    |
+-----------------------------------------------+
| version
...
| x$statements_with_temp_tables                 |
| user_summary_by_file_io_type                  |
| x$user_summary_by_file_io_type                |
| user_summary_by_file_io                       |
| x$user_summary_by_file_io                     |
| user_summary_by_statement_type                |
| x$user_summary_by_statement_type              |
| user_summary_by_statement_latency             |
| x$user_summary_by_statement_latency           |
| user_summary_by_stages                        |
| x$user_summary_by_stages                      |
| user_summary                                  |
| x$user_summary                                |                   |
| waits_global_by_latency                       |
| x$waits_global_by_latency                     |
| metrics                                       |
| processlist                                   |
| x$processlist                                 |
| session                                       |
| x$session                                     |
| session_ssl_status                            |
| v                                             |
| myview                                        |
+-----------------------------------------------+
102 rows in set (0.0061 sec)

```

#### 5.2 Changes in views
- [x] Information schema changes: Some of the views which were stored in the information_schema are not supported in MySQL 5.7
  - [ ] global_status
  - [ ] session_status
  - [ ] global_variables
  - [ ] session_variables
- [x] view `global_variables` is not avaibale in information_schema rather switched to performance_schema database in MySQL 5.7 and MySQL 8
- [ ] **Impact:** This issue can hit monitoring and trending system which may use those queries to collect MySQL metrics.

#### Simulation
```bash
# Simulation-01
# information_schema.global_variables view is not available in MySQL 5.7 and not even in MySQL 8.0, you will find it under performance_schema table
mysqlsh root@localhost --sql
sql> select * from information_schema.global_variables;

#Error raised in MySQL 5.7
ERROR 3167 (HY000): The ‘INFORMATION_SCHEMA.GLOBAL_VARIABLES’ feature is disabled; see the documentation for ‘show_
compatibility_56’

# Error raised in MySQL 8.0
ERROR: 1109: Unknown table 'GLOBAL_VARIABLES' in information_schema

# Simulation-02
# global_variables view in performance_schema table in MySQL 5.7 and MySQL 8
sql> select count(*) from performance_schema.global_variables;
+----------+
| count(*) |
+----------+
|      621 |
+----------+
1 row in set (0.0071 sec)
```

### Checklist 06: Check the size of your tables or store procedures
#### 6.1 Table with ENUM or SET column elements exceeding new MySQL 8.0 limits ?
- [x] There must be no tables or store procedures with individual ENUM or SET column elements that exceed 255 characters or 1020 bytes in length.
- [ ] Prior to MySQL 8.0, the maximum combined length of ENUM or SET column elements was 64K.
- [ ] In MySQL 8.0, the maximum character length of an individual ENUM or SET column element is 255 characters, and the maximum byte length is 1020 bytes. (The 1020 byte limit supports multitibyte character sets). 
- [ ] Before upgrading to MySQL 8.0, modify any ENUM or SET column elements that exceed the new limits. Failing to do so causes the upgrade to fail with an error.

#### Simulation
```bash
# Check the size of your MySQL Databases
sql > SELECT table_schema AS "Database", 
ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" 
FROM information_schema.TABLES 
GROUP BY table_schema;

+--------------------+-----------+
| Database           | Size (MB) |
+--------------------+-----------+
| classicmodels      |      0.50 |
| demo               |      0.04 |
| information_schema |      0.00 |
| mysql              |      2.56 |
| performance_schema |      0.00 |
| sys                |      0.02 |
+--------------------+-----------+
6 rows in set (0.0889 sec)

# Check the sizes of all tables in a specific database
sql > SELECT table_name AS "Table",
ROUND(((data_length + index_length) / 1024 / 1024), 2) AS "Size (MB)"
FROM information_schema.TABLES
WHERE table_schema = "classicmodels"      # database name
ORDER BY (data_length + index_length) DESC;

+--------------+-----------+
| Table        | Size (MB) |
+--------------+-----------+
| orderdetails |      0.23 |
| products     |      0.08 |
| orders       |      0.06 |
| employees    |      0.05 |
| customers    |      0.03 |
| offices      |      0.02 |
| payments     |      0.02 |
| productlines |      0.02 |
+--------------+-----------+

```

### Checklist 07: Are you still using ASC or DESC with GroupBy ?
#### 7.1 OrderBy instead of ASC/DESC in GroupBy | Query
- [x] As of MySQL 8.0.13, the deprecated ASC or DESC qualifiers for GROUP BY clauses have been removed. 
- [ ] Queries that previously relied on GROUP BY sorting may produce results that differ from previous MySQL versions. To produce a given sort order, provide an ORDER BY clause.

---
**Notes:**
Queries and stored program definitions from MySQL 8.0.12 or lower that use ASC or DESC qualifiers for GROUP BY clauses should be amended. Otherwise, upgrading to MySQL 8.0.13 or higher may fail, as may replicating to MySQL 8.0.13 or higher replica servers.

---

### Checklist 08: Wants to enable lower_case_table_name during upgrade time ?
#### 8.1 Check if your schema and table names are in lower case or not ?
- [x] If you intend to change the lower_case_table_names setting to 1 at upgrade time, ensure that schema and table names are lowercase before upgrading. 
- [ ] Otherwise, a failure could occur due to a schema or table name lettercase mismatch. 
- [x] Changing the lower_case_table_names setting at upgrade time is not recommended.
- [x] Ref: https://dev.mysql.com/doc/refman/5.7/en/identifier-case-sensitivity.html


#### Simulation
```bash
# check for schema and table names containing uppercase characters
sql > select TABLE_NAME, if(sha(TABLE_NAME) !=sha(lower(TABLE_NAME)),'Yes','No') as UpperCase from information_schema.tables;

+------------------------------------------------------+-----------+
| TABLE_NAME                                           | UpperCase |
+------------------------------------------------------+-----------+
| customers                                            | No        |
| employees                                            | No        |
| offices                                              | No        |
| orderdetails                                         | No        |
| orders                                               | No        |
| payments                                             | No        |
| productlines                                         | No        |
| products                                             | No        |
| myview                                               | No        |
| t1                                                   | No        |
| t2                                                   | No        |
| t3                                                   | No        |
| v                                                    | No        |
| ADMINISTRABLE_ROLE_AUTHORIZATIONS                    | Yes       |
| APPLICABLE_ROLES                                     | Yes       |
| CHARACTER_SETS                                       | Yes       |
| CHECK_CONSTRAINTS                                    | Yes       |
| COLLATION_CHARACTER_SET_APPLICABILITY                | Yes       |
| COLLATIONS                                           | Yes       |

340 rows in set (0.0079 sec)

# Use lower_case_table_names=0 on Unix and lower_case_table_names=2 on Windows/Mac. This preserves the lettercase of database and table names.
sql > show variables like 'lower_Case_table_names';
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| lower_case_table_names | 2     |
+------------------------+-------+

```


### Priliminary Checklist 07: SQL Modes
- [x] With MySQL 5.7, STRICT_TRANS_TABLES mode is used by default. 
  - [ ] This makes MYSQL behavior much less forgiving when it comes to handling invalid data like zeroed date or skipping column in IN SERT when column doesn't have an explicit DEFAULT value. 
  - [ ] So, this is for the application to make sure ensuring 'good practices'

```bash
# Check if STRICT_TRANS_TABLES mode is on or not
# In my case, as we could see, its on.
# List all sql_mode enabled
sql> show variables like 'sql_mode';
+---------------+-----------------------------------------------------------------------------------------------------------------------+
| Variable_name | Value                                                                                                                 |
+---------------+-----------------------------------------------------------------------------------------------------------------------+
| sql_mode      | ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION |
+---------------+-----------------------------------------------------------------------------------------------------------------------+
1 row in set (0.0042 sec)

# To disable strict_mode, run below sql
sql > set global sql_mode=''; or
    > set global sql_mode='NO_ENGINE_SUBSTITUTION'; # any mode except STRICT_TRANS_TABLES or
    > set global sql_mode='STRICT_TRANS_TABLES'; # to enable strict mode again 


```

### Priliminary Checklist 08: Authentication Changes
- [x] Password column has been removed and all authentication data along with passowrds, have been moved to the 'authentication_string'
- [x] Meantime, in MySQL 5.7 anmd MySQl 8.0, the 'plugin' column has to be non-empty, otherwise the account will be disabled.
- [x] Both MySQL 5.7 and 8.0 has password_expired which was not there in 5.6. This is a great way to achieve a better level of security, where you can force periodic password changes on users. 
  - [x] But this introduced some undesired side effects after an upgrade. 
  - [x] Password expiration data is stored in the mysql.user table in passowrd_lifetime cloumn. 
  - [x] When we perform an upgrade to MySQL 5.7, this column is set to NULL, means there's no per-user setting in use. Earlier in MySQL 5.7 after the upgrade the default_password_lifetime was set to 360 days which had some disadvantages. But later in MySQL 5.7.11, the default_password_lifewtime defaults to 0
![test](./mysql_auth_changes.png)

```bash
# Simulation 3.1 Check the authentication_string, plugin, password_expred and password_lifetime columns in mysql.user
sql> describe mysql.user

# Simulation 3.2: Check the default_password_lifetime and adjust it
# See, here default_password_lifetime is DEFAUILT to 0, means password never expires
# Adjust it to 180 days 
# But in this case you would not be able to query the database and all account on your newly upgraded MySQL 5.7 will expire after 180 days.
sql > SHOW GLOBAL VARIABLES LIKE 'default_password_lifetime';
    +---------------------------+-------+
    | Variable_name             | Value |
    +---------------------------+-------+
    | default_password_lifetime | 0     |
    +---------------------------+-------+
    > SET Global default_password_lifetime=180;
    > SHOW GLOBAL VARIABLES LIKE 'default_password_lifetime';

    +---------------------------+-------+
    | Variable_name             | Value |
    +---------------------------+-------+
    | default_password_lifetime | 180   |
    +---------------------------+-------+

# Now suppose 180 days passed and all your account in  newly upgraded MySQL 5.7 has expired. Now if you try to query, this supposed to fail. Lets see
sql > select 1;
ERROR 1820 (HY000): You must reset your password using ALTER
USER statement before executing this statement.

# To avoid this issue, ensure you have altered every user with desired password expiration settings; or disable the assword expiration for a particular host.
sql > ALTER USER demouser@localhost PASSWORD EXPIRE INTERVAL 10 DAY; or
    > ALTER USER demouser@localhost PASSWORD EXPIRE NEVER; or
    > SET Global default_password_lifetime=0; # This is not the best opition to choose 

```

### Priliminary Checklist: Other Changes in InnoDB
Ref: https://dev.mysql.com/doc/refman/5.7/en/innodb-row-format.html
- [x] A couple of changes introduced in MySQl 5.7 affect the InnoDB enginer.
- [ ] Both redo log and undd log format changed a little bit between 5.6 and 5.7 
- [ ] Use innodb_fast_shutdown=0 when stopping the previous MySQL version to ensure all data as been flushed correctly before attempt the uprade.
- [ ] With MySQL 5.7, the default row  format has changed to DYNAMIC. If you want to retain the previous COMPACT format as default one, you need to make chnages in MYSQL configuration (innodb_default_row_format).
- [ ] Valid innodb_default_row_format options include DYNAMIC, COMPACT, and REDUNDANT.


```bash
# Check the defaull row format; For MySQL 5.7 and 8 this should be 'DYNAMIC'
sql > SHOW GLOBAL VARIABLES LIKE 'innodb_default_row_format';
    > SELECT @@innodb_default_row_format;
+---------------------------+---------+
| Variable_name             | Value   |
+---------------------------+---------+
| innodb_default_row_format | dynamic |
+---------------------------+---------+


# Set the default row format to be 'COMPRESSED'
# The COMPRESSED row format, which is not supported for use in the system tablespace, cannot be defined as the default. It can only be specified explicitly in a CREATE TABLE or ALTER TABLE statement.
# The following query thereby trigger an error
sql > SET GLOBAL innodb_default_row_format=COMPRESSED;
#ERROR: 1231: Variable 'innodb_default_row_format' can't be set to the value of 'COMPRESSED'

# But you can create a new table with this 'COMPRESSED' row format
sql > create database demo;
    > create table demo.t1 (c1 INT);
    > create table demo.t2 (c1 INT) ROW_FORMAT=DEFAULT;
    > create table demo.t3(c1 INT) ROW_FORMAT=COMPRESSED;
    > SHOW table status in demo\G

#Output
*************************** 1. row ***************************
           Name: t1
         Engine: InnoDB
        Version: 10
     Row_format: Dynamic
           Rows: 0
 Avg_row_length: 0
    Data_length: 16384
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: NULL
    Create_time: 2022-04-28 18:02:49
    Update_time: NULL
     Check_time: NULL
      Collation: utf8mb4_0900_ai_ci
       Checksum: NULL
 Create_options: 
        Comment: 
*************************** 2. row ***************************
           Name: t2
         Engine: InnoDB
        Version: 10
     Row_format: Dynamic
           Rows: 0
 Avg_row_length: 0
    Data_length: 16384
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: NULL
    Create_time: 2022-04-28 18:03:32
    Update_time: NULL
     Check_time: NULL
      Collation: utf8mb4_0900_ai_ci
       Checksum: NULL
 Create_options: 
        Comment: 
*************************** 3. row ***************************
           Name: t3
         Engine: InnoDB
        Version: 10
     Row_format: Compressed
           Rows: 0
 Avg_row_length: 0
    Data_length: 8192
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: NULL
    Create_time: 2022-04-28 19:43:27
    Update_time: NULL
     Check_time: NULL
      Collation: utf8mb4_0900_ai_ci
       Checksum: NULL
 Create_options: row_format=COMPRESSED
        Comment: 
3 rows in set (0.0055 sec)

```