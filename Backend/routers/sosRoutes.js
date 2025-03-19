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

router.post("/sos/accept", async (req, res) => {
  try {
    const { sosId, volunteerId, latitude, longitude } = req.body;
    const sos = await SOS.findByIdAndUpdate(
      sosId,
      { accepted: true, volunteerId, volunteerLocation: { latitude, longitude } },
      { new: true }
    );

    if (!sos) return res.status(404).json({ success: false, message: "SOS not found" });

    // ✅ Notify user that a volunteer has accepted
    io.emit(`sos-accepted-${sos.userId}`, {
      message: "Volunteer is coming!",
      volunteerLatitude: latitude,
      volunteerLongitude: longitude,
    });

    res.status(200).json({ success: true, message: "SOS Accepted", sos });
  } catch (error) {
    console.error("❌ Error accepting SOS:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

module.exports = router;
