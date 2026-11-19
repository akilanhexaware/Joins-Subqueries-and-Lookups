# Logistics Shipment Analysis

The official brief supplies examples. The ten questions below cover those examples and add scenario-specific questions for this submission.

## Ten business questions

### Q01 Which shipments were over two days late, and who carried them?

INNER JOIN finds the carrier row for each qualifying shipment.

### Q02 Which hubs had no outbound shipments?

LEFT JOIN followed by a missing shipment check preserves unused hubs.

### Q03 Who supervises each employee?

A LEFT self join maps each supervisor ID to an employee and preserves the root.

### Q04 Where do outbound and inbound hub totals differ or lack a match?

FULL JOIN keeps directional totals from either side, including West with inbound traffic only.

### Q05 Which origin and destination belong to each shipment?

Two INNER JOIN aliases give the hub table two distinct roles.

### Q06 How many delivery events does each shipment have?

LEFT JOIN retains shipments with zero events; COUNT counts the non-NULL event key.

### Q07 Which customers sent shipments to every hub?

Double NOT EXISTS asks whether there is any hub the customer has never reached.

### Q08 Which carriers average more delay than the overall shipment average?

INNER JOIN groups shipments by carrier. ALL compares against the single shipment-weighted benchmark.

### Q09 Which customers shipped to West?

IN checks customer membership without duplicating rows for repeat shipments.

### Q10 Which shipments cost more than at least one shipment on the same route?

ANY compares against eligible peer costs; an empty peer list cannot match.

## Supplementary exercises

### S01 Rewrite Q9 using joins

INNER JOIN gathers West shipments and DISTINCT restores one row per customer.

### S02 Which shipments have a Delivered event?

EXISTS expresses a yes/no test directly.

### S03 Rewrite the Delivered-event subquery using a join

INNER JOIN plus DISTINCT has the same grain even if multiple delivery events match.

### S04 What is each hub’s second-highest distinct outbound shipping cost?

The inner MAX sets the ceiling; the outer MAX finds the greatest strictly lower value. NULL means fewer than two distinct costs.

## Interpretation and assumptions

Q9 is shorter as an IN membership check. The join is useful if a report also needs shipment columns. For the Delivered test, EXISTS reads closer to the question because a single event is enough, while the join needs DISTINCT. A customer must reach every listed destination hub, including hubs with no outbound shipments. Average delay includes on-time rows as zero; the overall shipment average is 2.00 days. For MongoDB, embed bounded events that are normally read with and belong exclusively to one shipment. Keep independently queried or growing histories and shared entities separate, then use $lookup as needed.

## MongoDB

### M1 Shipments with delivery events

Join event shipment IDs to the shipment key. Sorting gives a reproducible event list and missing events give an empty array.

### M2 Customers with shipments

Start from customers so Dune remains visible with an empty shipment list.

### M3 Carriers with delay statistics

Compute the count, mean and maximum from joined shipments. A carrier with no work has a count of zero and null delay statistics.
