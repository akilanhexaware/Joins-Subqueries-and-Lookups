// Hexaware Day 7 | Set 3 | Retail Returns and Refunds
// Load these fixtures only in a dedicated training instance.
const demo = db.getSiblingDB("HexawareDay07_Retail");
const fixtures = {
  returns: [
    {"_id": 301, "customerId": 1, "productId": 1, "storeId": 1, "units": 1},
    {"_id": 302, "customerId": 2, "productId": 1, "storeId": 2, "units": 1},
    {"_id": 303, "customerId": 3, "productId": 2, "storeId": 2, "units": 1},
    {"_id": 304, "customerId": 1, "productId": 3, "storeId": 4, "units": 1},
    {"_id": 305, "customerId": 4, "productId": 1, "storeId": 3, "units": 1},
    {"_id": 306, "customerId": 1, "productId": 2, "storeId": 1, "units": 1}
  ],
  returnsFeedback: [
    {"_id": 1, "returnId": 301, "rating": 4, "comment": "Quick refund"},
    {"_id": 2, "returnId": 302, "rating": 2, "comment": "Waiting"},
    {"_id": 3, "returnId": 305, "rating": 3, "comment": "Staff helped"},
    {"_id": 4, "returnId": 301, "rating": 5, "comment": "Good support"}
  ],
  refunds: [
    {"_id": 1, "returnId": 301, "amount": 50},
    {"_id": 2, "returnId": 303, "amount": 30},
    {"_id": 3, "returnId": 304, "amount": 60},
    {"_id": 4, "returnId": 306, "amount": 40},
    {"_id": 5, "returnId": null, "amount": 15}
  ],
};

for (const [name, rows] of Object.entries(fixtures)) {
  for (const row of rows) {
    demo.getCollection(name).replaceOne({ _id: row._id }, row, { upsert: true });
  }
}

// M1 Feedback with the corresponding return details
const result1 = demo.returnsFeedback.aggregate([
  {
    "$lookup": {
      "from": "returns",
      "localField": "returnId",
      "foreignField": "_id",
      "as": "linkedReturn"
    }
  },
  {"$unwind": "$linkedReturn"},
  {
    "$project": {
      "_id": 0,
      "feedbackId": "$_id",
      "returnId": 1,
      "rating": 1,
      "comment": 1,
      "productId": "$linkedReturn.productId",
      "storeId": "$linkedReturn.storeId"
    }
  },
  {"$sort": {"feedbackId": 1}}
]).toArray();
print(JSON.stringify({ query: "M1", rows: result1 }));

// M2 Returns with feedback IDs and average rating
const result2 = demo.returns.aggregate([
  {
    "$lookup": {
      "from": "returnsFeedback",
      "localField": "_id",
      "foreignField": "returnId",
      "as": "feedback"
    }
  },
  {
    "$project": {
      "_id": 0,
      "returnId": "$_id",
      "feedbackIds": {"$sortArray": {"input": "$feedback._id", "sortBy": 1}},
      "averageRating": {"$avg": "$feedback.rating"}
    }
  },
  {"$sort": {"returnId": 1}}
]).toArray();
print(JSON.stringify({ query: "M2", rows: result2 }));

// M3 Feedback with refund totals for its return
const result3 = demo.returnsFeedback.aggregate([
  {
    "$lookup": {
      "from": "refunds",
      "localField": "returnId",
      "foreignField": "returnId",
      "as": "refunds"
    }
  },
  {
    "$project": {
      "_id": 0,
      "feedbackId": "$_id",
      "returnId": 1,
      "refundCount": {"$size": "$refunds"},
      "refundTotal": {"$sum": "$refunds.amount"}
    }
  },
  {"$sort": {"feedbackId": 1}}
]).toArray();
print(JSON.stringify({ query: "M3", rows: result3 }));
