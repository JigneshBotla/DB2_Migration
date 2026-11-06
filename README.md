# DB2 → Snowflake Migration

Converted IBM DB2 SQL to Snowflake SQL using Snowflake AIM / SnowConvert AI (`scai`).

**Status:** conversion complete, deployed and verified against the source.

---

## 1. What was migrated

Source: IBM DB2 LUW 12.1.5, database `testdb`, schema `SALES_DEMO`.

| Object | Type | Notes |
|---|---|---|
| `CUSTOMERS` | Table | `CUSTOMER_ID` PK |
| `ORDERS` | Table | `ORDER_ID` PK, FK to `CUSTOMERS`, CHECK `AMOUNT >= 0` |
| `V_CUSTOMER_SALES` | View | Per-customer order count and total sales (LEFT JOIN) |
| `FN_ORDER_COUNT` | Function | Returns order count for a customer id |

All four converted successfully. Target: `TESTDB.SALES_DEMO` in Snowflake.

---

## 2. Repository layout

```
source/sales_demo.sql      Original DB2 DDL (from db2look)
snowflake/sales_demo.sql   Converted Snowflake SQL  <-- deploy this
.scai/reports/SnowConvert/ Conversion reports (Issues, Assessment, Elements)
.scai/config/              Project config (shared, non-secret)
.scai/bindings/            Source DB -> Snowflake DB name mapping
artifacts/, reports/       Conversion intermediates and summaries
```

Not in the repo, by design: session transcripts, connection credentials,
local profile settings, logs. See `.gitignore`.

---

## 3. Important: DB2 is conversion-only

This toolchain converts DB2 SQL but **cannot** do the rest of the migration.
Four commands refuse a DB2 source:

| Command | Error | Meaning |
|---|---|---|
| `scai code extract` | `EXT0003` | Cannot pull DDL from DB2 — use `db2look` |
| `scai test validate` | `TST0003` | No equivalence testing for DB2 |
| `scai data migrate` | `PRJ0020` / `CRG1001` | No data migration framework for DB2 |
| `scai code deploy` | `DEP0008` | Cannot deploy — run the SQL yourself |

Cause: `scai init` sets `project_type: code_conversion_only` for DB2. There is
no supported way to change this after project creation. The full pipeline is
available only for SQL Server, Redshift, Teradata, Oracle, PostgreSQL,
BigQuery and Azure Synapse.

**Practical effect:** extraction, deployment and data loading were done
manually. See sections 5 and 6.

---

## 4. Manual fixes applied to the converted SQL

`snowflake/sales_demo.sql` was edited by hand after conversion. Four changes:

1. **`FN_ORDER_COUNT` parameter reference** — changed `:P_CUSTOMER_ID` to
   `P_CUSTOMER_ID`. Snowflake rejects bind variables in UDF bodies
   (`Bind variables not allowed in view and UDF definitions`). Note this
   passed a compile-only check and failed only on actual creation.

2. **CHECK constraint `AMOUNT >= 0`** — commented out. Snowflake parses CHECK
   constraints but never enforces them, so deploying it would advertise a rule
   that does nothing. Enforce this in whatever loads `ORDERS`.

3. **`CREATE SCHEMA`** — removed the DB2 `AUTHORIZATION "DB2INST1"` clause,
   which Snowflake rejects. Schema ownership goes to the executing role.

4. **DB2 CLP commands** — commented out `CONNECT TO TESTDB`, `COMMIT WORK` and
   `CONNECT RESET`. These are `db2look` script commands, not SQL.

> **Warning:** `snowflake/` is generated output. Running `scai code convert`
> again **overwrites these fixes**. If you re-convert, re-apply them.

### Workflow rule: always push corrected code

The generated SQL only becomes safe once it is committed. After every
conversion and fix cycle:

```bash
git add snowflake/ source/
git commit -m "Fix <what> in converted SQL"
git push
```

Do this before moving on to deployment. Fixes that live only in a working
directory are one re-conversion away from being lost, and nobody else can see
what was corrected or why.

---

## 5. How to deploy the converted code

Requires a Snowflake connection, a warehouse, and a target database.

```sql
USE WAREHOUSE <your_warehouse>;
USE DATABASE <your_target_database>;
```

Then run `snowflake/sales_demo.sql`. Order matters — execute top to bottom:

1. `CREATE SCHEMA SALES_DEMO`
2. `CREATE TABLE CUSTOMERS` + primary key
3. `CREATE TABLE ORDERS` + primary key + foreign key
4. `CREATE FUNCTION FN_ORDER_COUNT`
5. `CREATE VIEW V_CUSTOMER_SALES`

The view and function depend on both tables, so they must come last.
`scai code deploy` does **not** work here (see section 3).

---

## 6. How to load the data

There is no data migration framework for DB2. For the small demo dataset,
plain inserts are enough:

```sql
INSERT INTO SALES_DEMO.CUSTOMERS (CUSTOMER_ID, CUSTOMER_NAME)
VALUES (1,'Asha'),(2,'Ravi'),(3,'Meera');

INSERT INTO SALES_DEMO.ORDERS (ORDER_ID, CUSTOMER_ID, ORDER_DATE, AMOUNT)
VALUES (101,1,'2026-01-05',120.00),
       (102,1,'2026-01-07',80.00),
       (103,2,'2026-01-08',150.00);
```

**This does not scale.** For real volume use:
DB2 `EXPORT` → compressed CSV/Parquet in S3/ADLS/GCS → Snowflake external
stage → `COPY INTO`. Aim for 100–250 MB compressed per file.

---

## 7. How to verify the migration

Run on **both** sides and compare:

```sql
SELECT CUSTOMER_ID, CUSTOMER_NAME, ORDER_COUNT, TOTAL_SALES
FROM SALES_DEMO.V_CUSTOMER_SALES
ORDER BY CUSTOMER_ID;
```

Expected result, confirmed identical in DB2 and Snowflake:

| CUSTOMER_ID | CUSTOMER_NAME | ORDER_COUNT | TOTAL_SALES |
|---|---|---|---|
| 1 | Asha | 2 | 200.00 |
| 2 | Ravi | 1 | 150.00 |
| 3 | Meera | 0 | 0.00 |

Customer 3 is the useful case: no orders, so it exercises the `LEFT JOIN` and
`COALESCE(SUM(...), 0)`.

Function check — returns 2, 1, 0 on both sides:

```sql
SELECT CUSTOMER_ID, SALES_DEMO.FN_ORDER_COUNT(CUSTOMER_ID)
FROM SALES_DEMO.CUSTOMERS ORDER BY CUSTOMER_ID;
```

This comparison was done by hand. There is no automated test suite, because
DB2 test generation is unsupported.

---

## 8. Known limitations

**Constraints are not enforced.** Snowflake enforces only `NOT NULL`. The
primary keys and `FK_ORDER_CUSTOMER` deploy as metadata only, and the CHECK is
commented out. Data integrity is the responsibility of whatever writes to
these tables.

**No automated equivalence testing.** Verification is manual and does not
scale past a trivial dataset.

**Compile checks are not sufficient.** The `:P_CUSTOMER_ID` defect compiled
cleanly and failed only at object creation. Always create objects, don't just
validate them.

---

## 9. Reproducing the conversion

Extract DDL from DB2 (needs the DB2 client, not AIM):

```bash
db2 connect to testdb user <user>
db2look -d testdb -e -o testdb_ddl.sql        # all schemas
db2look -d testdb -z SALES_DEMO -e -o out.sql # one schema
```

Import and convert:

```bash
scai code add -i <folder_with_ddl> --json
scai code convert --json
```

If a file holds more than one object, sc-tags must be injected before import
so the arrange engine can split it. Conversion reports land in
`.scai/reports/SnowConvert/`; `Issues.*.csv` lists every EWI and FDM.

Note: `db2look` output contains CLP commands (`CONNECT`, `SET CURRENT SCHEMA`,
`TERMINATE`). These appear as `SSC-EWI-0001` parse errors. They are script
commands, not objects, and are safely commented out — not conversion failures.
