# Expected outputs

SQL rows below are expected from the supplied fixtures, in SELECT column order. NULL denotes a missing SQL value. MongoDB rows use JSON field names. See README.md at the workspace root for execution status.

## SQL Server

### Q01 Which shipments were over two days late, and who carried them?

```text
101 | Swift | 4
102 | Swift | 3
```

### Q02 Which hubs had no outbound shipments?

```text
West
```

### Q03 Who supervises each employee?

```text
Mira | NULL
Anil | Mira
Leah | Mira
```

### Q04 Where do outbound and inbound hub totals differ or lack a match?

```text
North | 3 | 1
West | NULL | 2
```

### Q05 Which origin and destination belong to each shipment?

```text
101 | North | South
102 | North | West
103 | South | North
104 | South | West
105 | North | South
```

### Q06 How many delivery events does each shipment have?

```text
101 | 2
102 | 1
103 | 1
104 | 0
105 | 0
```

### Q07 Which customers sent shipments to every hub?

```text
Aster
```

### Q08 Which carriers average more delay than the overall shipment average?

```text
Swift | 3.5
```

### Q09 Which customers shipped to West?

```text
1 | Aster
2 | Birch
```

### Q10 Which shipments cost more than at least one shipment on the same route?

```text
101 | 120
```

### S01 Rewrite Q9 using joins

```text
1 | Aster
2 | Birch
```

### S02 Which shipments have a Delivered event?

```text
101
103
```

### S03 Rewrite the Delivered-event subquery using a join

```text
101
103
```

### S04 What is each hub’s second-highest distinct outbound shipping cost?

```text
North | 100
South | 70
West | NULL
```

## MongoDB

### M1 Shipments with delivery events

```json
[
  {"shipmentId": 101, "events": ["Dispatched", "Delivered"]},
  {"shipmentId": 102, "events": ["Dispatched"]},
  {"shipmentId": 103, "events": ["Delivered"]},
  {"shipmentId": 104, "events": []},
  {"shipmentId": 105, "events": []}
]
```

### M2 Customers with shipments

```json
[
  {"customerId": 1, "customer": "Aster", "shipmentIds": [101, 102, 103]},
  {"customerId": 2, "customer": "Birch", "shipmentIds": [104]},
  {"customerId": 3, "customer": "Cedar", "shipmentIds": [105]},
  {"customerId": 4, "customer": "Dune", "shipmentIds": []}
]
```

### M3 Carriers with delay statistics

```json
[
  {"carrierId": 1, "carrier": "Swift", "shipments": 2, "averageDelay": 3.5, "maxDelay": 4},
  {"carrierId": 2, "carrier": "Trail", "shipments": 3, "averageDelay": 1, "maxDelay": 2},
  {"carrierId": 3, "carrier": "Idle", "shipments": 0, "averageDelay": null, "maxDelay": null}
]
```
