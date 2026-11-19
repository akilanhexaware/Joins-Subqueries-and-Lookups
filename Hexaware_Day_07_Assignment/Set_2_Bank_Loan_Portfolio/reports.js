// Hexaware Day 7 | Set 2 | Bank Loan Portfolio
// Load these fixtures only in a dedicated training instance.
const demo = db.getSiblingDB("HexawareDay07_Bank");
const fixtures = {
  customers: [
    {"_id": 1, "name": "Asha"},
    {"_id": 2, "name": "Bala"},
    {"_id": 3, "name": "Chen"},
    {"_id": 4, "name": "Diya"},
    {"_id": 5, "name": "Evan"}
  ],
  loans: [
    {"_id": 201, "customerId": 1, "branchId": 1, "amount": 1000, "overdueInstalments": 4},
    {"_id": 202, "customerId": 1, "branchId": 2, "amount": 500, "overdueInstalments": 0},
    {"_id": 203, "customerId": 2, "branchId": 1, "amount": 300, "overdueInstalments": 1},
    {"_id": 204, "customerId": 3, "branchId": 1, "amount": 200, "overdueInstalments": 0},
    {"_id": 205, "customerId": 4, "branchId": 2, "amount": 700, "overdueInstalments": 5},
    {"_id": 206, "customerId": 1, "branchId": 1, "amount": 400, "overdueInstalments": 0}
  ],
  repayments: [
    {"_id": 1, "loanId": 201, "paidOn": "2026-08-01", "amount": 50},
    {"_id": 2, "loanId": 201, "paidOn": "2026-09-01", "amount": 70},
    {"_id": 3, "loanId": 203, "paidOn": "2026-10-10", "amount": 30},
    {"_id": 4, "loanId": 203, "paidOn": "2026-10-10", "amount": 20},
    {"_id": 5, "loanId": 202, "paidOn": "2026-08-15", "amount": 25}
  ],
};

for (const [name, rows] of Object.entries(fixtures)) {
  for (const row of rows) {
    if (name === "repayments") row.paidOn = ISODate(row.paidOn + "T00:00:00Z");
    demo.getCollection(name).replaceOne({ _id: row._id }, row, { upsert: true });
  }
}

// M1 Loan details with customer details
const result1 = demo.loans.aggregate([
  {
    "$lookup": {
      "from": "customers",
      "localField": "customerId",
      "foreignField": "_id",
      "as": "customer"
    }
  },
  {"$unwind": "$customer"},
  {
    "$project": {
      "_id": 0,
      "loanId": "$_id",
      "customerId": "$customer._id",
      "borrower": "$customer.name",
      "branchId": 1,
      "amount": 1,
      "overdueInstalments": 1
    }
  },
  {"$sort": {"loanId": 1}}
]).toArray();
print(JSON.stringify({ query: "M1", rows: result1 }));

// M2 Loans with repayment history
const result2 = demo.loans.aggregate([
  {
    "$lookup": {
      "from": "repayments",
      "localField": "_id",
      "foreignField": "loanId",
      "pipeline": [
        {"$sort": {"paidOn": 1, "_id": 1}},
        {
          "$project": {
            "_id": 0,
            "repaymentId": "$_id",
            "paidOn": {
              "$dateToString": {"date": "$paidOn", "format": "%Y-%m-%d", "timezone": "UTC"}
            },
            "amount": 1
          }
        }
      ],
      "as": "history"
    }
  },
  {"$project": {"_id": 0, "loanId": "$_id", "history": 1}},
  {"$sort": {"loanId": 1}}
]).toArray();
print(JSON.stringify({ query: "M2", rows: result2 }));

// M3 Most recent repayment for each loan
const result3 = demo.loans.aggregate([
  {
    "$lookup": {
      "from": "repayments",
      "localField": "_id",
      "foreignField": "loanId",
      "pipeline": [
        {"$sort": {"paidOn": -1, "_id": -1}},
        {"$limit": 1},
        {
          "$project": {
            "_id": 0,
            "repaymentId": "$_id",
            "paidOn": {
              "$dateToString": {"date": "$paidOn", "format": "%Y-%m-%d", "timezone": "UTC"}
            },
            "amount": 1
          }
        }
      ],
      "as": "repayment"
    }
  },
  {
    "$project": {
      "_id": 0,
      "loanId": "$_id",
      "lastRepayment": {"$ifNull": [{"$arrayElemAt": ["$repayment", 0]}, null]}
    }
  },
  {"$sort": {"loanId": 1}}
]).toArray();
print(JSON.stringify({ query: "M3", rows: result3 }));
