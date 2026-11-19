# Sample data

The SQL fixtures are fictional and listed in column order below.

## Customers

| CustomerID | Name |
| --- | --- |
| 1 | Asha |
| 2 | Bala |
| 3 | Chen |
| 4 | Diya |
| 5 | Evan |

## Branches

| BranchID | Name |
| --- | --- |
| 1 | Central |
| 2 | East |
| 3 | West |

## Loans

| LoanID | CustomerID | BranchID | Amount | OverdueInstalments |
| --- | --- | --- | --- | --- |
| 201 | 1 | 1 | 1000 | 4 |
| 202 | 1 | 2 | 500 | 0 |
| 203 | 2 | 1 | 300 | 1 |
| 204 | 3 | 1 | 200 | 0 |
| 205 | 4 | 2 | 700 | 5 |
| 206 | 1 | 1 | 400 | 0 |

## Repayments

| RepaymentID | LoanID | PaidOn | Amount |
| --- | --- | --- | --- |
| 1 | 201 | 2026-08-01 | 50 |
| 2 | 201 | 2026-09-01 | 70 |
| 3 | 203 | 2026-10-10 | 30 |
| 4 | 203 | 2026-10-10 | 20 |
| 5 | 202 | 2026-08-15 | 25 |

## Guarantors

| LoanID | CustomerID |
| --- | --- |
| 201 | 2 |
| 203 | 5 |
| 205 | 1 |

## MongoDB

The script loads HexawareDay07_Bank with the same values for the fields and entities it uses. Repayment date strings in the JavaScript fixture are converted to BSON dates at load time.
