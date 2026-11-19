# Expected outputs

SQL rows below are expected from the supplied fixtures, in SELECT column order. NULL denotes a missing SQL value. MongoDB rows use JSON field names. See README.md at the workspace root for execution status.

## SQL Server

### Q01 Which products have a return rate above 10 percent?

```text
Mug | 30
Lamp | 20
```

### Q02 Which customers made a return but received no refund on any return?

```text
Ben
Dara
```

### Q03 Which store or stores have the highest refund value?

```text
Harbor | 90
```

### Q04 Who manages each employee?

```text
Nia | NULL
Omar | Nia
Pia | Nia
```

### Q05 Which returns have no linked refund?

```text
302
305
```

### Q06 Does each store beat any or all of its regional peers by refund total?

```text
1 | Harbor | Coast | 90 | 1 | 1
2 | Bay | Coast | 30 | 1 | 0
3 | Pier | Coast | 0 | 0 | 0
4 | Hill | Inland | 60 | 1 | 1
5 | Ridge | Inland | 0 | 0 | 0
6 | Solo | Island | 0 | NULL | NULL
```

### Q07 Which refunds exceed the average refund at their own store?

```text
1 | 50
```

### Q08 How many feedback entries does each return have?

```text
301 | 2
302 | 1
303 | 0
304 | 0
305 | 1
306 | 0
```

### Q09 Which products have no returns?

```text
Pen
```

### Q10 Which refunds are still unlinked to a return?

```text
5 | 15
```

### S01 Demonstrate NOT IN with a NULL refund reference

No rows.

### S02 Remove NULL from NOT IN and compare with Q5

```text
302
305
```

## MongoDB

### M1 Feedback with the corresponding return details

```json
[
  {"feedbackId": 1, "returnId": 301, "rating": 4, "comment": "Quick refund", "productId": 1, "storeId": 1},
  {"feedbackId": 2, "returnId": 302, "rating": 2, "comment": "Waiting", "productId": 1, "storeId": 2},
  {"feedbackId": 3, "returnId": 305, "rating": 3, "comment": "Staff helped", "productId": 1, "storeId": 3},
  {"feedbackId": 4, "returnId": 301, "rating": 5, "comment": "Good support", "productId": 1, "storeId": 1}
]
```

### M2 Returns with feedback IDs and average rating

```json
[
  {"returnId": 301, "feedbackIds": [1, 4], "averageRating": 4.5},
  {"returnId": 302, "feedbackIds": [2], "averageRating": 2},
  {"returnId": 303, "feedbackIds": [], "averageRating": null},
  {"returnId": 304, "feedbackIds": [], "averageRating": null},
  {"returnId": 305, "feedbackIds": [3], "averageRating": 3},
  {"returnId": 306, "feedbackIds": [], "averageRating": null}
]
```

### M3 Feedback with refund totals for its return

```json
[
  {"feedbackId": 1, "returnId": 301, "refundCount": 1, "refundTotal": 50},
  {"feedbackId": 2, "returnId": 302, "refundCount": 0, "refundTotal": 0},
  {"feedbackId": 3, "returnId": 305, "refundCount": 0, "refundTotal": 0},
  {"feedbackId": 4, "returnId": 301, "refundCount": 1, "refundTotal": 50}
]
```
