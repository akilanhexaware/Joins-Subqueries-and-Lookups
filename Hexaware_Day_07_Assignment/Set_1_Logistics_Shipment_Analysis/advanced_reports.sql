-- Hexaware Python Track Day 7 | Set 1 | Logistics Shipment Analysis

-- Run in a clean training database with no tables of these names.

-- Each set uses its own training database.

SET NOCOUNT ON;

CREATE TABLE Customers (
  CustomerID int PRIMARY KEY, Name nvarchar(40) NOT NULL
);

INSERT INTO Customers (CustomerID, Name) VALUES
  (1, N'Aster'),
  (2, N'Birch'),
  (3, N'Cedar'),
  (4, N'Dune');

CREATE TABLE Hubs (
  HubID int PRIMARY KEY, Name nvarchar(40) NOT NULL
);

INSERT INTO Hubs (HubID, Name) VALUES
  (1, N'North'),
  (2, N'South'),
  (3, N'West');

CREATE TABLE Carriers (
  CarrierID int PRIMARY KEY, Name nvarchar(40) NOT NULL
);

INSERT INTO Carriers (CarrierID, Name) VALUES
  (1, N'Swift'),
  (2, N'Trail'),
  (3, N'Idle');

CREATE TABLE Employees (
  EmployeeID int PRIMARY KEY, Name nvarchar(40) NOT NULL, SupervisorID int NULL REFERENCES Employees(EmployeeID)
);

INSERT INTO Employees (EmployeeID, Name, SupervisorID) VALUES
  (1, N'Mira', NULL),
  (2, N'Anil', 1),
  (3, N'Leah', 1);

CREATE TABLE Shipments (
  ShipmentID int PRIMARY KEY, CustomerID int NOT NULL REFERENCES Customers(CustomerID), OriginID int NOT NULL REFERENCES Hubs(HubID), DestinationID int NOT NULL REFERENCES Hubs(HubID), CarrierID int NOT NULL REFERENCES Carriers(CarrierID), DelayDays int NOT NULL CHECK (DelayDays >= 0), Cost decimal(10,2) NOT NULL CHECK (Cost >= 0)
);

INSERT INTO Shipments (ShipmentID, CustomerID, OriginID, DestinationID, CarrierID, DelayDays, Cost) VALUES
  (101, 1, 1, 2, 1, 4, 120),
  (102, 1, 1, 3, 1, 3, 100),
  (103, 1, 2, 1, 2, 0, 80),
  (104, 2, 2, 3, 2, 2, 70),
  (105, 3, 1, 2, 2, 1, 100);

CREATE TABLE DeliveryEvents (
  EventID int PRIMARY KEY, ShipmentID int NOT NULL REFERENCES Shipments(ShipmentID), EventName nvarchar(40) NOT NULL
);

INSERT INTO DeliveryEvents (EventID, ShipmentID, EventName) VALUES
  (1, 101, N'Dispatched'),
  (2, 101, N'Delivered'),
  (3, 102, N'Dispatched'),
  (4, 103, N'Delivered');

-- Q01 Which shipments were over two days late, and who carried them?
SELECT s.ShipmentID, c.Name AS Carrier, s.DelayDays
FROM Shipments AS s INNER JOIN Carriers AS c ON c.CarrierID = s.CarrierID
WHERE s.DelayDays > 2 ORDER BY s.ShipmentID;

-- Q02 Which hubs had no outbound shipments?
SELECT h.Name AS Hub
FROM Hubs AS h LEFT JOIN Shipments AS s ON s.OriginID = h.HubID
WHERE s.ShipmentID IS NULL ORDER BY h.HubID;

-- Q03 Who supervises each employee?
SELECT e.Name AS Employee, m.Name AS Supervisor
FROM Employees AS e LEFT JOIN Employees AS m ON m.EmployeeID = e.SupervisorID
ORDER BY e.EmployeeID;

-- Q04 Where do outbound and inbound hub totals differ or lack a match?
SELECT h.Name AS Hub, o.OutboundCount, i.InboundCount
FROM (SELECT OriginID, COUNT(*) AS OutboundCount FROM Shipments GROUP BY OriginID) AS o
FULL JOIN (SELECT DestinationID, COUNT(*) AS InboundCount FROM Shipments GROUP BY DestinationID) AS i
  ON o.OriginID = i.DestinationID
INNER JOIN Hubs AS h ON h.HubID = COALESCE(o.OriginID, i.DestinationID)
WHERE COALESCE(o.OutboundCount, 0) <> COALESCE(i.InboundCount, 0)
ORDER BY h.HubID;

-- Q05 Which origin and destination belong to each shipment?
SELECT s.ShipmentID, o.Name AS Origin, d.Name AS Destination
FROM Shipments AS s INNER JOIN Hubs AS o ON o.HubID = s.OriginID
INNER JOIN Hubs AS d ON d.HubID = s.DestinationID
ORDER BY s.ShipmentID;

-- Q06 How many delivery events does each shipment have?
SELECT s.ShipmentID, COUNT(e.EventID) AS EventCount
FROM Shipments AS s LEFT JOIN DeliveryEvents AS e ON e.ShipmentID = s.ShipmentID
GROUP BY s.ShipmentID ORDER BY s.ShipmentID;

-- Q07 Which customers sent shipments to every hub?
SELECT c.Name AS Customer
FROM Customers AS c
WHERE NOT EXISTS (
  SELECT 1 FROM Hubs AS h
  WHERE NOT EXISTS (
    SELECT 1 FROM Shipments AS s
    WHERE s.CustomerID = c.CustomerID AND s.DestinationID = h.HubID
  )
)
ORDER BY c.CustomerID;

-- Q08 Which carriers average more delay than the overall shipment average?
SELECT c.Name AS Carrier, CAST(AVG(CAST(s.DelayDays AS decimal(10,2))) AS decimal(10,2)) AS AverageDelay
FROM Carriers AS c INNER JOIN Shipments AS s ON s.CarrierID = c.CarrierID
GROUP BY c.CarrierID, c.Name
HAVING AVG(CAST(s.DelayDays AS decimal(10,2))) > ALL (
  SELECT AVG(CAST(DelayDays AS decimal(10,2))) FROM Shipments
)
ORDER BY c.CarrierID;

-- Q09 Which customers shipped to West?
SELECT c.CustomerID, c.Name AS Customer FROM Customers AS c
WHERE c.CustomerID IN (
  SELECT s.CustomerID FROM Shipments AS s
  INNER JOIN Hubs AS h ON h.HubID = s.DestinationID WHERE h.Name = N'West'
)
ORDER BY c.CustomerID;

-- Q10 Which shipments cost more than at least one shipment on the same route?
SELECT s.ShipmentID, s.Cost FROM Shipments AS s
WHERE s.Cost > ANY (
  SELECT peer.Cost FROM Shipments AS peer
  WHERE peer.OriginID = s.OriginID AND peer.DestinationID = s.DestinationID
    AND peer.ShipmentID <> s.ShipmentID
)
ORDER BY s.ShipmentID;

-- S01 Rewrite Q9 using joins
SELECT DISTINCT c.CustomerID, c.Name AS Customer FROM Customers AS c
INNER JOIN Shipments AS s ON s.CustomerID = c.CustomerID
INNER JOIN Hubs AS h ON h.HubID = s.DestinationID
WHERE h.Name = N'West' ORDER BY c.CustomerID;

-- S02 Which shipments have a Delivered event?
SELECT s.ShipmentID FROM Shipments AS s
WHERE EXISTS (SELECT 1 FROM DeliveryEvents AS e WHERE e.ShipmentID = s.ShipmentID AND e.EventName = N'Delivered')
ORDER BY s.ShipmentID;

-- S03 Rewrite the Delivered-event subquery using a join
SELECT DISTINCT s.ShipmentID FROM Shipments AS s
INNER JOIN DeliveryEvents AS e ON e.ShipmentID = s.ShipmentID
WHERE e.EventName = N'Delivered' ORDER BY s.ShipmentID;

-- S04 What is each hub’s second-highest distinct outbound shipping cost?
SELECT h.Name AS Hub, (
  SELECT MAX(s.Cost) FROM Shipments AS s
  WHERE s.OriginID = h.HubID AND s.Cost < (
    SELECT MAX(topShipment.Cost) FROM Shipments AS topShipment WHERE topShipment.OriginID = h.HubID
  )
) AS SecondCost
FROM Hubs AS h ORDER BY h.HubID;
