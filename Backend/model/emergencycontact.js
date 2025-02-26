const mongoose = require("mongoose");

const EmergencyContactSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, required: true, ref: "User" }, // ✅ Ensure `required: true`
  name: { type: String, required: true },
  phone: { type: String, required: true }
});

module.exports = mongoose.model("EmergencyContact", EmergencyContactSchema);
