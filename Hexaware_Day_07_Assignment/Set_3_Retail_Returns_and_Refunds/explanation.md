# Retail Returns and Refunds

The official brief supplies examples. The ten questions below cover those examples and add scenario-specific questions for this submission.

## Ten business questions

### Q01 Which products have a return rate above 10 percent?

LEFT JOIN retains the sales denominator; NULLIF handles products with zero sales.

### Q02 Which customers made a return but received no refund on any return?

IN finds customers with returns. NOT EXISTS excludes customers with any linked refund.

### Q03 Which store or stores have the highest refund value?

The inner grouping computes store totals; the nested MAX preserves ties.

### Q04 Who manages each employee?

LEFT self join keeps employees without a manager.

### Q05 Which returns have no linked refund?

NOT EXISTS evaluates matching rows and safely ignores unlinked refunds.

### Q06 Does each store beat any or all of its regional peers by refund total?

ANY finds at least one smaller peer total. ALL requires every peer total to be smaller. No-peer stores show NULL for both comparisons.

### Q07 Which refunds exceed the average refund at their own store?

The nested subquery gets return IDs for the current store, then averages refunds linked to those returns.

### Q08 How many feedback entries does each return have?

LEFT JOIN and COUNT of the feedback key preserve returns with no reviews.

### Q09 Which products have no returns?

LEFT JOIN finds unsighted return keys, including products with zero sales.

### Q10 Which refunds are still unlinked to a return?

LEFT JOIN preserves staged refund rows without a matching return.

## Supplementary exercises

### S01 Demonstrate NOT IN with a NULL refund reference

Intentionally returns zero rows. An unlinked refund supplies NULL, making the predicate UNKNOWN for nonmatching returns.

### S02 Remove NULL from NOT IN and compare with Q5

After NULL is filtered, NOT IN matches the NOT EXISTS result for these non-null return IDs.

## Interpretation and assumptions

Return rates use sold units for the same reporting sample and the threshold is strictly above 10 percent. Bag is exactly 10 percent and is excluded. Pen has no sales and therefore has no defined rate. The unlinked refund is an imported adjustment awaiting reconciliation and has no store attribution. For return 302, NOT IN behaves like a chain of unequal comparisons that includes 302 <> NULL. That comparison is UNKNOWN and WHERE keeps only TRUE. NOT EXISTS checks for an equal ReturnID and finds no match. Q3 and Q7 are the two nested queries; each has expected rows in expected_outputs.md.

## MongoDB

### M1 Feedback with the corresponding return details

Match feedback to its return. Unwind makes one row per feedback entry, like an INNER JOIN here.

### M2 Returns with feedback IDs and average rating

Start from returns and keep the feedback array. Empty arrays and null averages correspond to a LEFT JOIN with grouping.

### M3 Feedback with refund totals for its return

Join direct return IDs. Each feedback entry remains visible when no refund exists, like a LEFT JOIN followed by aggregation. Two reviews of the same return intentionally each show its refund total.
