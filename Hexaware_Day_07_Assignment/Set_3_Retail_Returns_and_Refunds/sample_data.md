# Sample data

The SQL fixtures are fictional and listed in column order below.

## Customers

| CustomerID | Name |
| --- | --- |
| 1 | Ana |
| 2 | Ben |
| 3 | Chao |
| 4 | Dara |
| 5 | Eli |

## Products

| ProductID | Name | UnitsSold |
| --- | --- | --- |
| 1 | Mug | 10 |
| 2 | Bag | 20 |
| 3 | Lamp | 5 |
| 4 | Pen | 0 |

## Stores

| StoreID | Name | Region |
| --- | --- | --- |
| 1 | Harbor | Coast |
| 2 | Bay | Coast |
| 3 | Pier | Coast |
| 4 | Hill | Inland |
| 5 | Ridge | Inland |
| 6 | Solo | Island |

## Employees

| EmployeeID | Name | ManagerID |
| --- | --- | --- |
| 1 | Nia | NULL |
| 2 | Omar | 1 |
| 3 | Pia | 1 |

## Returns

| ReturnID | CustomerID | ProductID | StoreID | Units |
| --- | --- | --- | --- | --- |
| 301 | 1 | 1 | 1 | 1 |
| 302 | 2 | 1 | 2 | 1 |
| 303 | 3 | 2 | 2 | 1 |
| 304 | 1 | 3 | 4 | 1 |
| 305 | 4 | 1 | 3 | 1 |
| 306 | 1 | 2 | 1 | 1 |

## Refunds

| RefundID | ReturnID | Amount |
| --- | --- | --- |
| 1 | 301 | 50 |
| 2 | 303 | 30 |
| 3 | 304 | 60 |
| 4 | 306 | 40 |
| 5 | NULL | 15 |

## ReturnsFeedback

| FeedbackID | ReturnID | Rating | Comment |
| --- | --- | --- | --- |
| 1 | 301 | 4 | Quick refund |
| 2 | 302 | 2 | Waiting |
| 3 | 305 | 3 | Staff helped |
| 4 | 301 | 5 | Good support |

## MongoDB

The script loads HexawareDay07_Retail with the same values for the fields and entities it uses.
