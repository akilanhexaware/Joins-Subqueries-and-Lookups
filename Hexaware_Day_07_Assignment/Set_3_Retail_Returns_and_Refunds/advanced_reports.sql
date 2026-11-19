-- Hexaware Python Track Day 7 | Set 3 | Retail Returns and Refunds

-- Run in a clean training database with no tables of these names.

-- Each set uses its own training database.

SET NOCOUNT ON;

CREATE TABLE Customers (
  CustomerID int PRIMARY KEY, Name nvarchar(40) NOT NULL
);

INSERT INTO Customers (CustomerID, Name) VALUES
  (1, N'Ana'),
  (2, N'Ben'),
  (3, N'Chao'),
  (4, N'Dara'),
  (5, N'Eli');

CREATE TABLE Products (
  ProductID int PRIMARY KEY, Name nvarchar(40) NOT NULL, UnitsSold int NOT NULL CHECK (UnitsSold >= 0)
);

INSERT INTO Products (ProductID, Name, UnitsSold) VALUES
  (1, N'Mug', 10),
  (2, N'Bag', 20),
  (3, N'Lamp', 5),
  (4, N'Pen', 0);

CREATE TABLE Stores (
  StoreID int PRIMARY KEY, Name nvarchar(40) NOT NULL, Region nvarchar(40) NOT NULL
);

INSERT INTO Stores (StoreID, Name, Region) VALUES
  (1, N'Harbor', N'Coast'),
  (2, N'Bay', N'Coast'),
  (3, N'Pier', N'Coast'),
  (4, N'Hill', N'Inland'),
  (5, N'Ridge', N'Inland'),
  (6, N'Solo', N'Island');

CREATE TABLE Employees (
  EmployeeID int PRIMARY KEY, Name nvarchar(40) NOT NULL, ManagerID int NULL REFERENCES Employees(EmployeeID)
);

INSERT INTO Employees (EmployeeID, Name, ManagerID) VALUES
  (1, N'Nia', NULL),
  (2, N'Omar', 1),
  (3, N'Pia', 1);

CREATE TABLE Returns (
  ReturnID int PRIMARY KEY, CustomerID int NOT NULL REFERENCES Customers(CustomerID), ProductID int NOT NULL REFERENCES Products(ProductID), StoreID int NOT NULL REFERENCES Stores(StoreID), Units int NOT NULL CHECK (Units > 0)
);

INSERT INTO Returns (ReturnID, CustomerID, ProductID, StoreID, Units) VALUES
  (301, 1, 1, 1, 1),
  (302, 2, 1, 2, 1),
  (303, 3, 2, 2, 1),
  (304, 1, 3, 4, 1),
  (305, 4, 1, 3, 1),
  (306, 1, 2, 1, 1);

CREATE TABLE Refunds (
  RefundID int PRIMARY KEY, ReturnID int NULL REFERENCES Returns(ReturnID), Amount decimal(10,2) NOT NULL CHECK (Amount > 0)
);

INSERT INTO Refunds (RefundID, ReturnID, Amount) VALUES
  (1, 301, 50),
  (2, 303, 30),
  (3, 304, 60),
  (4, 306, 40),
  (5, NULL, 15);

CREATE TABLE ReturnsFeedback (
  FeedbackID int PRIMARY KEY, ReturnID int NOT NULL REFERENCES Returns(ReturnID), Rating int NOT NULL CHECK (Rating BETWEEN 1 AND 5), Comment nvarchar(80) NOT NULL
);

INSERT INTO ReturnsFeedback (FeedbackID, ReturnID, Rating, Comment) VALUES
  (1, 301, 4, N'Quick refund'),
  (2, 302, 2, N'Waiting'),
  (3, 305, 3, N'Staff helped'),
  (4, 301, 5, N'Good support');

-- Compute one comparable total per store, including stores with no refunds.
SELECT s.StoreID, s.Name AS Store, s.Region, COALESCE(SUM(f.Amount), 0) AS RefundTotal
INTO #StoreTotals
FROM Stores AS s LEFT JOIN Returns AS r ON r.StoreID = s.StoreID
LEFT JOIN Refunds AS f ON f.ReturnID = r.ReturnID
GROUP BY s.StoreID, s.Name, s.Region;

-- Q01 Which products have a return rate above 10 percent?
SELECT p.Name AS Product, CAST(100.0 * SUM(r.Units) / NULLIF(p.UnitsSold, 0) AS decimal(10,2)) AS ReturnRate
FROM Products AS p LEFT JOIN Returns AS r ON r.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name, p.UnitsSold
HAVING 100.0 * SUM(r.Units) / NULLIF(p.UnitsSold, 0) > 10 ORDER BY p.ProductID;

-- Q02 Which customers made a return but received no refund on any return?
SELECT c.Name AS Customer FROM Customers AS c
WHERE c.CustomerID IN (SELECT CustomerID FROM Returns)
AND NOT EXISTS (
  SELECT 1 FROM Returns AS r INNER JOIN Refunds AS f ON f.ReturnID = r.ReturnID
  WHERE r.CustomerID = c.CustomerID
)
ORDER BY c.CustomerID;

-- Q03 Which store or stores have the highest refund value?
SELECT s.Name AS Store, SUM(f.Amount) AS RefundTotal
FROM Stores AS s INNER JOIN Returns AS r ON r.StoreID = s.StoreID
INNER JOIN Refunds AS f ON f.ReturnID = r.ReturnID
GROUP BY s.StoreID, s.Name
HAVING SUM(f.Amount) = (
  SELECT MAX(t.RefundTotal) FROM (
    SELECT SUM(f2.Amount) AS RefundTotal FROM Returns AS r2
    INNER JOIN Refunds AS f2 ON f2.ReturnID = r2.ReturnID GROUP BY r2.StoreID
  ) AS t
)
ORDER BY s.StoreID;

-- Q04 Who manages each employee?
SELECT e.Name AS Employee, m.Name AS Manager FROM Employees AS e
LEFT JOIN Employees AS m ON m.EmployeeID = e.ManagerID ORDER BY e.EmployeeID;

-- Q05 Which returns have no linked refund?
SELECT r.ReturnID FROM Returns AS r
WHERE NOT EXISTS (SELECT 1 FROM Refunds AS f WHERE f.ReturnID = r.ReturnID)
ORDER BY r.ReturnID;

-- Q06 Does each store beat any or all of its regional peers by refund total?
SELECT a.StoreID, a.Store, a.Region, a.RefundTotal,
  CASE WHEN NOT EXISTS (SELECT 1 FROM #StoreTotals AS b WHERE b.Region = a.Region AND b.StoreID <> a.StoreID) THEN NULL
       WHEN a.RefundTotal > ANY (SELECT b.RefundTotal FROM #StoreTotals AS b WHERE b.Region = a.Region AND b.StoreID <> a.StoreID) THEN 1 ELSE 0 END AS BeatsAny,
  CASE WHEN NOT EXISTS (SELECT 1 FROM #StoreTotals AS b WHERE b.Region = a.Region AND b.StoreID <> a.StoreID) THEN NULL
       WHEN a.RefundTotal > ALL (SELECT b.RefundTotal FROM #StoreTotals AS b WHERE b.Region = a.Region AND b.StoreID <> a.StoreID) THEN 1 ELSE 0 END AS BeatsAll
FROM #StoreTotals AS a ORDER BY a.StoreID;

-- Q07 Which refunds exceed the average refund at their own store?
SELECT f.RefundID, f.Amount FROM Refunds AS f
INNER JOIN Returns AS r ON r.ReturnID = f.ReturnID
WHERE f.Amount > (
  SELECT AVG(peer.Amount) FROM Refunds AS peer
  WHERE peer.ReturnID IN (SELECT cohort.ReturnID FROM Returns AS cohort WHERE cohort.StoreID = r.StoreID)
) ORDER BY f.RefundID;

-- Q08 How many feedback entries does each return have?
SELECT r.ReturnID, COUNT(f.FeedbackID) AS FeedbackCount FROM Returns AS r
LEFT JOIN ReturnsFeedback AS f ON f.ReturnID = r.ReturnID
GROUP BY r.ReturnID ORDER BY r.ReturnID;

-- Q09 Which products have no returns?
SELECT p.Name AS Product FROM Products AS p LEFT JOIN Returns AS r ON r.ProductID = p.ProductID
WHERE r.ReturnID IS NULL ORDER BY p.ProductID;

-- Q10 Which refunds are still unlinked to a return?
SELECT f.RefundID, f.Amount FROM Refunds AS f LEFT JOIN Returns AS r ON r.ReturnID = f.ReturnID
WHERE r.ReturnID IS NULL ORDER BY f.RefundID;

-- S01 Demonstrate NOT IN with a NULL refund reference
SELECT r.ReturnID FROM Returns AS r
WHERE r.ReturnID NOT IN (SELECT ReturnID FROM Refunds) ORDER BY r.ReturnID;

-- S02 Remove NULL from NOT IN and compare with Q5
SELECT r.ReturnID FROM Returns AS r
WHERE r.ReturnID NOT IN (SELECT ReturnID FROM Refunds WHERE ReturnID IS NOT NULL) ORDER BY r.ReturnID;

-- Remove the session-local comparison table.
DROP TABLE #StoreTotals;
