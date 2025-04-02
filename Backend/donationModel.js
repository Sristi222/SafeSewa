const mongoose = require("mongoose");

const donationSchema = new mongoose.Schema({
  donorName: { type: String, required: true },
  amount: { type: Number, required: true },
  paymentMethod: { type: String, enum: ["khalti"], required: true },
  status: { type: String, enum: ["pending", "completed"], default: "pending" },
  transactionId: { type: String, default: null },
  pidx: { type: String, unique: true, sparse: true },
  fundraiserId: { type: mongoose.Schema.Types.ObjectId, ref: "Fundraiser" }, // ✅ Add this
  createdAt: { type: Date, default: Date.now },
}, { timestamps: true });

const Donation = mongoose.model("Donation", donationSchema);
module.exports = Donation;
