-- Hexaware Python Track Day 7 | Set 2 | Bank Loan Portfolio

-- Run in a clean training database with no tables of these names.

-- Each set uses its own training database.

SET NOCOUNT ON;

CREATE TABLE Customers (
  CustomerID int PRIMARY KEY, Name nvarchar(40) NOT NULL
);

INSERT INTO Customers (CustomerID, Name) VALUES
  (1, N'Asha'),
  (2, N'Bala'),
  (3, N'Chen'),
  (4, N'Diya'),
  (5, N'Evan');

CREATE TABLE Branches (
  BranchID int PRIMARY KEY, Name nvarchar(40) NOT NULL
);

INSERT INTO Branches (BranchID, Name) VALUES
  (1, N'Central'),
  (2, N'East'),
  (3, N'West');

CREATE TABLE Loans (
  LoanID int PRIMARY KEY, CustomerID int NOT NULL REFERENCES Customers(CustomerID), BranchID int NOT NULL REFERENCES Branches(BranchID), Amount decimal(10,2) NOT NULL CHECK (Amount > 0), OverdueInstalments int NOT NULL CHECK (OverdueInstalments >= 0)
);

INSERT INTO Loans (LoanID, CustomerID, BranchID, Amount, OverdueInstalments) VALUES
  (201, 1, 1, 1000, 4),
  (202, 1, 2, 500, 0),
  (203, 2, 1, 300, 1),
  (204, 3, 1, 200, 0),
  (205, 4, 2, 700, 5),
  (206, 1, 1, 400, 0);

CREATE TABLE Repayments (
  RepaymentID int PRIMARY KEY, LoanID int NOT NULL REFERENCES Loans(LoanID), PaidOn date NOT NULL, Amount decimal(10,2) NOT NULL CHECK (Amount > 0)
);

INSERT INTO Repayments (RepaymentID, LoanID, PaidOn, Amount) VALUES
  (1, 201, N'2026-08-01', 50),
  (2, 201, N'2026-09-01', 70),
  (3, 203, N'2026-10-10', 30),
  (4, 203, N'2026-10-10', 20),
  (5, 202, N'2026-08-15', 25);

CREATE TABLE Guarantors (
  LoanID int NOT NULL REFERENCES Loans(LoanID), CustomerID int NOT NULL REFERENCES Customers(CustomerID), PRIMARY KEY (LoanID, CustomerID)
);

INSERT INTO Guarantors (LoanID, CustomerID) VALUES
  (201, 2),
  (203, 5),
  (205, 1);

-- Fixed reporting date for repeatable results.
DECLARE @AsOfDate date = '2026-11-19';

-- Q01 Which loans are overdue by more than three instalments?
SELECT l.LoanID, c.Name AS Borrower, l.OverdueInstalments
FROM Loans AS l INNER JOIN Customers AS c ON c.CustomerID = l.CustomerID
WHERE l.OverdueInstalments > 3 ORDER BY l.LoanID;

-- Q02 Who borrowed from more than one branch?
SELECT c.Name AS Borrower, COUNT(DISTINCT l.BranchID) AS BranchCount
FROM Customers AS c INNER JOIN Loans AS l ON l.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.Name HAVING COUNT(DISTINCT l.BranchID) > 1 ORDER BY c.CustomerID;

-- Q03 Which guarantors are also borrowers?
SELECT DISTINCT c.Name AS Guarantor
FROM Loans AS guaranteed INNER JOIN Guarantors AS g ON g.LoanID = guaranteed.LoanID
INNER JOIN Loans AS own ON own.CustomerID = g.CustomerID AND own.LoanID <> guaranteed.LoanID
INNER JOIN Customers AS c ON c.CustomerID = g.CustomerID ORDER BY Guarantor;

-- Q04 Which branches have no loans?
SELECT b.Name AS Branch FROM Branches AS b
LEFT JOIN Loans AS l ON l.BranchID = b.BranchID
WHERE l.LoanID IS NULL ORDER BY b.BranchID;

-- Q05 Which customer exposures exceed their branch average?
SELECT b.Name AS Branch, c.Name AS Borrower, SUM(l.Amount) AS Exposure
FROM Loans AS l INNER JOIN Branches AS b ON b.BranchID = l.BranchID
INNER JOIN Customers AS c ON c.CustomerID = l.CustomerID
GROUP BY l.BranchID, b.Name, c.CustomerID, c.Name
HAVING SUM(l.Amount) > (
  SELECT AVG(t.Exposure)
  FROM (SELECT BranchID, CustomerID, SUM(Amount) AS Exposure FROM Loans GROUP BY BranchID, CustomerID) AS t
  WHERE t.BranchID = l.BranchID
)
ORDER BY b.Name, c.Name;

-- Q06 Who has a loan but no repayment in the last 60 days?
SELECT c.Name AS Borrower FROM Customers AS c
WHERE EXISTS (SELECT 1 FROM Loans AS l WHERE l.CustomerID = c.CustomerID)
AND NOT EXISTS (
  SELECT 1 FROM Loans AS l INNER JOIN Repayments AS r ON r.LoanID = l.LoanID
  WHERE l.CustomerID = c.CustomerID
  AND r.PaidOn >= DATEADD(day, -60, @AsOfDate) AND r.PaidOn <= @AsOfDate
)
ORDER BY c.CustomerID;

-- Q07 Which branches have a maximum loan above the average of branch maxima?
SELECT b.Name AS Branch, MAX(l.Amount) AS MaximumLoan
FROM Branches AS b INNER JOIN Loans AS l ON l.BranchID = b.BranchID
GROUP BY b.BranchID, b.Name
HAVING MAX(l.Amount) > (SELECT AVG(t.MaximumLoan)
  FROM (SELECT MAX(Amount) AS MaximumLoan FROM Loans GROUP BY BranchID) AS t)
ORDER BY b.BranchID;

-- Q08 How much lending does each branch have?
SELECT b.Name AS Branch, COUNT(l.LoanID) AS LoanCount, COALESCE(SUM(l.Amount), 0) AS Exposure
FROM Branches AS b LEFT JOIN Loans AS l ON l.BranchID = b.BranchID
GROUP BY b.BranchID, b.Name ORDER BY b.BranchID;

-- Q09 How much was repaid on each loan?
SELECT l.LoanID, COALESCE(SUM(r.Amount), 0) AS TotalRepaid
FROM Loans AS l LEFT JOIN Repayments AS r ON r.LoanID = l.LoanID
GROUP BY l.LoanID ORDER BY l.LoanID;

-- Q10 Which customers have no loans?
SELECT c.Name AS Customer FROM Customers AS c
LEFT JOIN Loans AS l ON l.CustomerID = c.CustomerID
WHERE l.LoanID IS NULL ORDER BY c.CustomerID;

-- S01 Rewrite Q5 using uncorrelated subqueries
SELECT b.Name AS Branch, c.Name AS Borrower, e.Exposure
FROM (SELECT BranchID, CustomerID, SUM(Amount) AS Exposure FROM Loans GROUP BY BranchID, CustomerID) AS e
INNER JOIN (
  SELECT BranchID, AVG(Exposure) AS BranchAverage
  FROM (SELECT BranchID, CustomerID, SUM(Amount) AS Exposure FROM Loans GROUP BY BranchID, CustomerID) AS t
  GROUP BY BranchID
) AS a ON a.BranchID = e.BranchID
INNER JOIN Branches AS b ON b.BranchID = e.BranchID
INNER JOIN Customers AS c ON c.CustomerID = e.CustomerID
WHERE e.Exposure > a.BranchAverage ORDER BY b.Name, c.Name;
