# Bank Loan Portfolio

The official brief supplies examples. The ten questions below cover those examples and add scenario-specific questions for this submission.

## Ten business questions

### Q01 Which loans are overdue by more than three instalments?

INNER JOIN adds the borrower to qualifying loans.

### Q02 Who borrowed from more than one branch?

INNER JOIN groups borrowers; DISTINCT counts each branch once.

### Q03 Which guarantors are also borrowers?

The loan self join links a guaranteed loan to a different loan held by its guarantor.

### Q04 Which branches have no loans?

LEFT JOIN preserves every branch, then an absent loan key identifies empty branches.

### Q05 Which customer exposures exceed their branch average?

A correlated scalar subquery recomputes the average borrower total for the current branch.

### Q06 Who has a loan but no repayment in the last 60 days?

EXISTS requires any loan and NOT EXISTS excludes a recent payment on any of the customer’s loans.

### Q07 Which branches have a maximum loan above the average of branch maxima?

A nested subquery averages the maxima and the outer HAVING applies that benchmark.

### Q08 How much lending does each branch have?

LEFT JOIN keeps empty branches; COALESCE displays their exposure as zero.

### Q09 How much was repaid on each loan?

LEFT JOIN retains loans that have never been repaid.

### Q10 Which customers have no loans?

LEFT JOIN keeps non-borrowing customers and the missing loan key filters borrowers out.

## Supplementary exercises

### S01 Rewrite Q5 using uncorrelated subqueries

Each derived table runs independently. Join customer totals to their precomputed branch averages.

## Interpretation and assumptions

Exposure is the sum of original principal for one borrower in one branch. The average uses borrower totals, so Asha’s two Central loans count as one borrower total. Branch averages are 633.33 and 600.00. The branch maxima average is 850.00 across branches with loans. The repayment window is inclusive from 2026-09-20 through 2026-11-19. Customers with an older payment and those who never repaid qualify; non-borrowers do not. For same-day repayment ties, the greatest repayment ID is treated as later.

## MongoDB

### M1 Loan details with customer details

A loan links to one customer. Unwind converts the one-element customer array into a row, like an inner join on these fixtures.

### M2 Loans with repayment history

Look up all payments in chronological order, with the ID breaking same-day ties. Keep loans that have no payments.

### M3 Most recent repayment for each loan

Within each loan, sort by date descending and ID descending before taking one. Loans 204–206 return null. Loan 203 tests the tie rule.
