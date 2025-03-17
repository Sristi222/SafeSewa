const express = require("express");
const { SOS } = require("../model/SOS"); // ✅ Correct import

const router = express.Router();

router.post("/sos", async (req, res) => {
  try {
    const { userId, latitude, longitude } = req.body;

    if (!userId || !latitude || !longitude) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const newSOS = new SOS({ userId, latitude, longitude });
    await newSOS.save(); // ✅ Save to database

    // ✅ Notify volunteers via WebSocket
    const io = req.app.get("io");
    if (io) {
      io.emit("sos_alert", { userId, latitude, longitude, timestamp: new Date() });
      console.log("🚨 SOS Alert sent to volunteers");
    }

    return res.status(201).json({ message: "SOS sent successfully!" });
  } catch (error) {
    console.error("Error sending SOS:", error);
    return res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
