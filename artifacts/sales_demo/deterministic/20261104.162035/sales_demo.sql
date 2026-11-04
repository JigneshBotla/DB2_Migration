-- This CLP file was created using DB2LOOK Version "12.1" 
-- Timestamp: Wed Nov  4 10:36:53 2026
-- Database Name: TESTDB         
-- Database Manager Version: DB2/LINUXX8664 Version 12.1.5.0
-- Database Codepage: 1208
-- Database Collating Sequence is: IDENTITY
-- Alternate collating sequence(alt_collate): null
-- varchar2 compatibility(varchar2_compat): OFF


CONNECT TO TESTDB !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'ToConnectionTarget' NODE ***/!!!;

------------------------------------------------
-- DDL Statements for Schemas
------------------------------------------------


/* <sc-schema>SALES_DEMO</sc-schema> */
CREATE SCHEMA "SALES_DEMO" AUTHORIZATION "DB2INST1" !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'CreateSchema' NODE ***/!!!;



------------------------------------------------
-- DDL Statements for Table "SALES_DEMO"."CUSTOMERS"
------------------------------------------------


/* <sc-table>SALES_DEMO.CUSTOMERS</sc-table> */
CREATE TABLE "SALES_DEMO"."CUSTOMERS" (
		  "CUSTOMER_ID" INTEGER NOT NULL,
		  "CUSTOMER_NAME" VARCHAR(100) NOT NULL )
--		 --** SSC-FDM-0027 - REMOVED NEXT STATEMENT, NOT APPLICABLE IN SNOWFLAKE.  **
--		 IN "USERSPACE1"
--		 --** SSC-FDM-0027 - REMOVED NEXT STATEMENT, NOT APPLICABLE IN SNOWFLAKE.  **
--		 ORGANIZE BY ROW
		 COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "1-Pr" }, "attributes": {  "component": "db2",  "convertedOn": "11/04/2026",  "domain": "no-domain-provided",  "migrationid": "LqahAXGu8HC3iCIZEq39Ww==" }}';


-- DDL Statements for Primary Key on Table "SALES_DEMO"."CUSTOMERS"

/* <sc-table>SALES_DEMO.CUSTOMERS</sc-table> */
ALTER TABLE "SALES_DEMO"."CUSTOMERS"
	ADD PRIMARY KEY
		("CUSTOMER_ID")
	ENFORCED;



------------------------------------------------
-- DDL Statements for Table "SALES_DEMO"."ORDERS"
------------------------------------------------


/* <sc-table>SALES_DEMO.ORDERS</sc-table> */
CREATE TABLE "SALES_DEMO"."ORDERS" (
		  "ORDER_ID" INTEGER NOT NULL,
		  "CUSTOMER_ID" INTEGER NOT NULL,
		  "ORDER_DATE" DATE NOT NULL,
		  "AMOUNT" DECIMAL(10,2) NOT NULL )
--		 --** SSC-FDM-0027 - REMOVED NEXT STATEMENT, NOT APPLICABLE IN SNOWFLAKE.  **
--		 IN "USERSPACE1"
--		 --** SSC-FDM-0027 - REMOVED NEXT STATEMENT, NOT APPLICABLE IN SNOWFLAKE.  **
--		 ORGANIZE BY ROW
		 COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "1-Pr" }, "attributes": {  "component": "db2",  "convertedOn": "11/04/2026",  "domain": "no-domain-provided",  "migrationid": "LqahAXGu8HC3iCIZEq39Ww==" }}';


-- DDL Statements for Primary Key on Table "SALES_DEMO"."ORDERS"

/* <sc-table>SALES_DEMO.ORDERS</sc-table> */
ALTER TABLE "SALES_DEMO"."ORDERS"
	ADD PRIMARY KEY
		("ORDER_ID")
	ENFORCED;



-- DDL Statements for Foreign Keys on Table "SALES_DEMO"."ORDERS"

/* <sc-table>SALES_DEMO.ORDERS</sc-table> */
ALTER TABLE "SALES_DEMO"."ORDERS"
	ADD CONSTRAINT "FK_ORDER_CUSTOMER" FOREIGN KEY
		("CUSTOMER_ID")
	REFERENCES "SALES_DEMO"."CUSTOMERS"
		("CUSTOMER_ID")
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
	ENFORCED;

-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '86' COLUMN '1' OF THE SOURCE CODE STARTING AT 'SET'. EXPECTED 'STATEMENT' GRAMMAR. LAST MATCHING TOKEN WAS ';' ON LINE '82' COLUMN '27'. **
---- DDL Statements for Check Constraints on Table "SALES_DEMO"."ORDERS"

--SET SYSIBM.NLS_STRING_UNITS = 'SYSTEM'
                                      ;

/* <sc-table>SALES_DEMO.ORDERS</sc-table> */
ALTER TABLE "SALES_DEMO"."ORDERS"
	ADD
 	   !!!RESOLVE EWI!!! /*** SSC-EWI-0035 - CHECK STATEMENT NOT SUPPORTED ***/!!! CONSTRAINT "SQL261104100421070" CHECK
		(AMOUNT >= 0)
	ENFORCED
	ENABLE QUERY OPTIMIZATION;






-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '105' COLUMN '1' OF THE SOURCE CODE STARTING AT 'SET'. EXPECTED 'STATEMENT' GRAMMAR. LAST MATCHING TOKEN WAS ';' ON LINE '93' COLUMN '27'. **
-----------------------------------
---- DDL Statements for User Defined Functions
-----------------------------------


--SET SYSIBM.NLS_STRING_UNITS = 'SYSTEM'
                                      ;
-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '106' COLUMN '1' OF THE SOURCE CODE STARTING AT 'SET'. EXPECTED 'STATEMENT' GRAMMAR. LAST MATCHING TOKEN WAS ';' ON LINE '105' COLUMN '39'. **
--SET CURRENT SCHEMA = "DB2INST1"
                               ;
-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '107' COLUMN '1' OF THE SOURCE CODE STARTING AT 'SET'. EXPECTED 'STATEMENT' GRAMMAR. LAST MATCHING TOKEN WAS ';' ON LINE '106' COLUMN '32'. **
--SET CURRENT PATH = "SYSIBM","SYSFUN","SYSPROC","SYSIBMADM","SYSHADOOP","DB2INST1"
                                                                                 ;

/* <sc-function>SALES_DEMO.FN_ORDER_COUNT</sc-function> */
CREATE FUNCTION SALES_DEMO.FN_ORDER_COUNT (P_CUSTOMER_ID INTEGER)
RETURNS INTEGER
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "1-Pr" }, "attributes": {  "component": "db2",  "convertedOn": "11/04/2026",  "domain": "no-domain-provided",  "migrationid": "LqahAXGu8HC3iCIZEq39Ww==" }}'
AS
$$
		      SELECT
		COUNT(*)
		      FROM
		SALES_DEMO.ORDERS O
		      WHERE O.CUSTOMER_ID = :P_CUSTOMER_ID
$$;


-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '126' COLUMN '1' OF THE SOURCE CODE STARTING AT 'SET'. EXPECTED 'STATEMENT' GRAMMAR. LAST MATCHING TOKEN WAS ';' ON LINE '118' COLUMN '2'. **
------------------------------

---- DDL Statements for Views

------------------------------
--SET CURRENT SCHEMA = "DB2INST1"
                               ;
-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '127' COLUMN '1' OF THE SOURCE CODE STARTING AT 'SET'. EXPECTED 'STATEMENT' GRAMMAR. LAST MATCHING TOKEN WAS ';' ON LINE '126' COLUMN '32'. **
--SET CURRENT PATH = "SYSIBM","SYSFUN","SYSPROC","SYSIBMADM","SYSHADOOP","DB2INST1"
                                                                                 ;
/* <sc-view>SALES_DEMO.V_CUSTOMER_SALES</sc-view> */
CREATE VIEW SALES_DEMO.V_CUSTOMER_SALES
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "1-Pr" }, "attributes": {  "component": "db2",  "convertedOn": "11/04/2026",  "domain": "no-domain-provided",  "migrationid": "LqahAXGu8HC3iCIZEq39Ww==" }}'
AS
SELECT C.CUSTOMER_ID, C.CUSTOMER_NAME,
		  COUNT(O.ORDER_ID) AS ORDER_COUNT,
		  COALESCE(SUM(O.AMOUNT), 0) AS TOTAL_SALES
FROM
		  SALES_DEMO.CUSTOMERS C
LEFT JOIN
		SALES_DEMO.ORDERS O ON O.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID, C.CUSTOMER_NAME;





COMMIT WORK !!!RESOLVE EWI!!! /*** SSC-EWI-0073 - PENDING FUNCTIONAL EQUIVALENCE REVIEW FOR 'Commit' NODE ***/!!!;

CONNECT;
--         RESET
              ;
-- ** SSC-EWI-0001 - UNRECOGNIZED TOKEN ON LINE '145' COLUMN '1' OF THE SOURCE CODE STARTING AT 'TERMINATE'. EXPECTED 'STATEMENT' GRAMMAR. LAST MATCHING TOKEN WAS ';' ON LINE '143' COLUMN '13'. **
--                RESET

--TERMINATE
         ;