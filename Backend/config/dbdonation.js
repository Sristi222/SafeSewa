const mongoose = require("mongoose");

const connectToMongo = async () => {
  const MONGO_URI = process.env.MONGO_URI || "mongodb://localhost:27017/newauth";

  try {
    await mongoose.connect(MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log("✅ Connected to MongoDB");
  } catch (err) {
    console.error("❌ MongoDB Connection Error:", err.message);
    process.exit(1);
  }
};

module.exports = connectToMongo;
