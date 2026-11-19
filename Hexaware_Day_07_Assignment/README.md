# Hexaware Python Track Day 7

This workspace covers all three sets in the official Day 7 Word brief, *Joins, Subqueries and Lookups*. Each set contains ten numbered SQL business questions, supplementary SQL exercises where required, and three MongoDB pipelines. The brief supplies examples. The remaining business questions and all sample records were written for this submission.

## Workspace

| Folder | SQL coverage | MongoDB coverage |
|---|---|---|
| Set_1_Logistics_Shipment_Analysis | 10 business queries, two join rewrites, the source EXISTS query and the second-highest distinct outbound cost | Shipment events, customer shipments and carrier delay statistics |
| Set_2_Bank_Loan_Portfolio | 10 business queries and the uncorrelated rewrite of the exposure comparison | Customer details, repayment history and latest repayment per loan |
| Set_3_Retail_Returns_and_Refunds | 10 business queries and two NOT IN demonstrations. The set includes a NULL-safe anti-join, ANY and ALL, and two nested subqueries. | Feedback with return data, returns with feedback ratings and feedback with refund totals |

Each set has the same six files.

- `advanced_reports.sql` creates tables, loads fixtures and runs the SQL reports.
- `reports.js` loads fixtures and runs exactly three executable mongosh pipelines.
- `MongoDB_Queries.docx` contains the same shell code with collection fields, explanations and sample output.
- `explanation.md` lists the business questions, join and subquery choices, and assumptions.
- `sample_data.md` documents the fixture records.
- `expected_outputs.md` shows all expected SQL and MongoDB results.

## Running the files

For SQL Server, select a different empty training database for each set and run its complete SQL file in one session. The schemas reuse some table names across sets. Set 3 uses a session-local temporary table for regional totals. The SQL files create tables and insert rows, so rerun them in clean training databases.

For MongoDB, run `mongosh --file reports.js` from the set directory against a dedicated training instance. Each script selects its own named database and upserts fixture documents by ID. Use fresh training databases for the first run so unrelated existing documents cannot change the results.

## Validation on macOS ARM64

- **SQL Server 2025 runtime pending.** No local SQL Server listener or supplied remote connection was available. All three scripts passed SQLFluff T-SQL parsing. An offline SQLite cross-check matched 37 of 37 result sets using the same fixtures and equivalent expressions for T-SQL-specific comparisons, dates and temporary table setup. Zero scripts ran on SQL Server. This leaves native SQL Server execution and the official request for executed SQL result evidence pending.
- **MongoDB 8.0.38 runtime passed.** Used the existing native mongod and mongosh 2.14.2 in a fresh, temporary localhost instance. All nine pipelines matched the expected result documents, including 44 rows per run. Repeating the three scripts produced the same results. The temporary instance was stopped after testing.
- **Dependencies.** The shell search path did not contain sqlcmd, mongosh or mongod. The three binaries were available in the earlier workspace. No Docker, emulation or package installation was needed. The unavailable dependency for runtime verification was a reachable SQL Server instance.
- **Word and Markdown.** All three Word files contain the full executable JavaScript. The Markdown files record expected outputs and modeling decisions. The source assignment document was read in place.

## Fixture conventions

Logistics treats every listed hub as an eligible destination and returns the second-highest distinct outbound shipping cost. The bank uses 19 November 2026 as the reporting date, aggregates principal per borrower and branch, and uses repayment ID to break date ties. Retail treats the unlinked refund as a staged adjustment and excludes it from store totals. A store without regional peers has NULL comparison flags.
