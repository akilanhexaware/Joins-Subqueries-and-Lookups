# Expected outputs

SQL rows below are expected from the supplied fixtures, in SELECT column order. NULL denotes a missing SQL value. MongoDB rows use JSON field names. See README.md at the workspace root for execution status.

## SQL Server

### Q01 Which loans are overdue by more than three instalments?

```text
201 | Asha | 4
205 | Diya | 5
```

### Q02 Who borrowed from more than one branch?

```text
Asha | 2
```

### Q03 Which guarantors are also borrowers?

```text
Asha
Bala
```

### Q04 Which branches have no loans?

```text
West
```

### Q05 Which customer exposures exceed their branch average?

```text
Central | Asha | 1400
East | Diya | 700
```

### Q06 Who has a loan but no repayment in the last 60 days?

```text
Asha
Chen
Diya
```

### Q07 Which branches have a maximum loan above the average of branch maxima?

```text
Central | 1000
```

### Q08 How much lending does each branch have?

```text
Central | 4 | 1900
East | 2 | 1200
West | 0 | 0
```

### Q09 How much was repaid on each loan?

```text
201 | 120
202 | 25
203 | 50
204 | 0
205 | 0
206 | 0
```

### Q10 Which customers have no loans?

```text
Evan
```

### S01 Rewrite Q5 using uncorrelated subqueries

```text
Central | Asha | 1400
East | Diya | 700
```

## MongoDB

### M1 Loan details with customer details

```json
[
  {"loanId": 201, "customerId": 1, "borrower": "Asha", "branchId": 1, "amount": 1000, "overdueInstalments": 4},
  {"loanId": 202, "customerId": 1, "borrower": "Asha", "branchId": 2, "amount": 500, "overdueInstalments": 0},
  {"loanId": 203, "customerId": 2, "borrower": "Bala", "branchId": 1, "amount": 300, "overdueInstalments": 1},
  {"loanId": 204, "customerId": 3, "borrower": "Chen", "branchId": 1, "amount": 200, "overdueInstalments": 0},
  {"loanId": 205, "customerId": 4, "borrower": "Diya", "branchId": 2, "amount": 700, "overdueInstalments": 5},
  {"loanId": 206, "customerId": 1, "borrower": "Asha", "branchId": 1, "amount": 400, "overdueInstalments": 0}
]
```

### M2 Loans with repayment history

```json
[
  {"loanId": 201, "history": [{"repaymentId": 1, "paidOn": "2026-08-01", "amount": 50}, {"repaymentId": 2, "paidOn": "2026-09-01", "amount": 70}]},
  {"loanId": 202, "history": [{"repaymentId": 5, "paidOn": "2026-08-15", "amount": 25}]},
  {"loanId": 203, "history": [{"repaymentId": 3, "paidOn": "2026-10-10", "amount": 30}, {"repaymentId": 4, "paidOn": "2026-10-10", "amount": 20}]},
  {"loanId": 204, "history": []},
  {"loanId": 205, "history": []},
  {"loanId": 206, "history": []}
]
```

### M3 Most recent repayment for each loan

```json
[
  {"loanId": 201, "lastRepayment": {"repaymentId": 2, "paidOn": "2026-09-01", "amount": 70}},
  {"loanId": 202, "lastRepayment": {"repaymentId": 5, "paidOn": "2026-08-15", "amount": 25}},
  {"loanId": 203, "lastRepayment": {"repaymentId": 4, "paidOn": "2026-10-10", "amount": 20}},
  {"loanId": 204, "lastRepayment": null},
  {"loanId": 205, "lastRepayment": null},
  {"loanId": 206, "lastRepayment": null}
]
```
