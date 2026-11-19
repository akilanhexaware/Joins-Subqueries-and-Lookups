// Hexaware Day 7 | Set 1 | Logistics Shipment Analysis
// Load these fixtures only in a dedicated training instance.
const demo = db.getSiblingDB("HexawareDay07_Logistics");
const fixtures = {
  customers: [
    {"_id": 1, "name": "Aster"},
    {"_id": 2, "name": "Birch"},
    {"_id": 3, "name": "Cedar"},
    {"_id": 4, "name": "Dune"}
  ],
  shipments: [
    {"_id": 101, "customerId": 1, "originId": 1, "destinationId": 2, "carrierId": 1, "delayDays": 4, "cost": 120},
    {"_id": 102, "customerId": 1, "originId": 1, "destinationId": 3, "carrierId": 1, "delayDays": 3, "cost": 100},
    {"_id": 103, "customerId": 1, "originId": 2, "destinationId": 1, "carrierId": 2, "delayDays": 0, "cost": 80},
    {"_id": 104, "customerId": 2, "originId": 2, "destinationId": 3, "carrierId": 2, "delayDays": 2, "cost": 70},
    {"_id": 105, "customerId": 3, "originId": 1, "destinationId": 2, "carrierId": 2, "delayDays": 1, "cost": 100}
  ],
  deliveryEvents: [
    {"_id": 1, "shipmentId": 101, "event": "Dispatched"},
    {"_id": 2, "shipmentId": 101, "event": "Delivered"},
    {"_id": 3, "shipmentId": 102, "event": "Dispatched"},
    {"_id": 4, "shipmentId": 103, "event": "Delivered"}
  ],
  carriers: [
    {"_id": 1, "name": "Swift"},
    {"_id": 2, "name": "Trail"},
    {"_id": 3, "name": "Idle"}
  ],
};

for (const [name, rows] of Object.entries(fixtures)) {
  for (const row of rows) {
    demo.getCollection(name).replaceOne({ _id: row._id }, row, { upsert: true });
  }
}

// M1 Shipments with delivery events
const result1 = demo.shipments.aggregate([
  {
    "$lookup": {
      "from": "deliveryEvents",
      "localField": "_id",
      "foreignField": "shipmentId",
      "as": "events"
    }
  },
  {
    "$project": {
      "_id": 0,
      "shipmentId": "$_id",
      "events": {
        "$map": {
          "input": {"$sortArray": {"input": "$events", "sortBy": {"_id": 1}}},
          "as": "row",
          "in": "$$row.event"
        }
      }
    }
  },
  {"$sort": {"shipmentId": 1}}
]).toArray();
print(JSON.stringify({ query: "M1", rows: result1 }));

// M2 Customers with shipments
const result2 = demo.customers.aggregate([
  {
    "$lookup": {
      "from": "shipments",
      "localField": "_id",
      "foreignField": "customerId",
      "as": "shipments"
    }
  },
  {
    "$project": {
      "_id": 0,
      "customerId": "$_id",
      "customer": "$name",
      "shipmentIds": {"$sortArray": {"input": "$shipments._id", "sortBy": 1}}
    }
  },
  {"$sort": {"customerId": 1}}
]).toArray();
print(JSON.stringify({ query: "M2", rows: result2 }));

// M3 Carriers with delay statistics
const result3 = demo.carriers.aggregate([
  {
    "$lookup": {
      "from": "shipments",
      "localField": "_id",
      "foreignField": "carrierId",
      "as": "shipments"
    }
  },
  {
    "$project": {
      "_id": 0,
      "carrierId": "$_id",
      "carrier": "$name",
      "shipments": {"$size": "$shipments"},
      "averageDelay": {"$avg": "$shipments.delayDays"},
      "maxDelay": {"$max": "$shipments.delayDays"}
    }
  },
  {"$sort": {"carrierId": 1}}
]).toArray();
print(JSON.stringify({ query: "M3", rows: result3 }));
