const mongoose = require('mongoose');

const DisasterPrecautionSchema = new mongoose.Schema({
  title: { type: String, required: true },
  precaution: { type: String, required: true },
  response: { type: String, required: true },
  image: { type: String, required: true } // e.g. earthquake.png
}, { timestamps: true });

module.exports = mongoose.model("DisasterPrecaution", DisasterPrecautionSchema);
