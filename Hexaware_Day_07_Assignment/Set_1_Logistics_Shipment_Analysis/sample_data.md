# Sample data

The SQL fixtures are fictional and listed in column order below.

## Customers

| CustomerID | Name |
| --- | --- |
| 1 | Aster |
| 2 | Birch |
| 3 | Cedar |
| 4 | Dune |

## Hubs

| HubID | Name |
| --- | --- |
| 1 | North |
| 2 | South |
| 3 | West |

## Carriers

| CarrierID | Name |
| --- | --- |
| 1 | Swift |
| 2 | Trail |
| 3 | Idle |

## Employees

| EmployeeID | Name | SupervisorID |
| --- | --- | --- |
| 1 | Mira | NULL |
| 2 | Anil | 1 |
| 3 | Leah | 1 |

## Shipments

| ShipmentID | CustomerID | OriginID | DestinationID | CarrierID | DelayDays | Cost |
| --- | --- | --- | --- | --- | --- | --- |
| 101 | 1 | 1 | 2 | 1 | 4 | 120 |
| 102 | 1 | 1 | 3 | 1 | 3 | 100 |
| 103 | 1 | 2 | 1 | 2 | 0 | 80 |
| 104 | 2 | 2 | 3 | 2 | 2 | 70 |
| 105 | 3 | 1 | 2 | 2 | 1 | 100 |

## DeliveryEvents

| EventID | ShipmentID | EventName |
| --- | --- | --- |
| 1 | 101 | Dispatched |
| 2 | 101 | Delivered |
| 3 | 102 | Dispatched |
| 4 | 103 | Delivered |

## MongoDB

The script loads HexawareDay07_Logistics with the same values for the fields and entities it uses.
