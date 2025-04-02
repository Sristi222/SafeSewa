const mongoose = require("mongoose");

const HelplineSchema = new mongoose.Schema({
  title: { type: String, required: true },
  number: { type: String, required: true },
}, { timestamps: true });

module.exports = mongoose.model("Helpline", HelplineSchema);
