const mongoose = require('mongoose');
const alertSchema = new mongoose.Schema({
  type: { type: String, enum: ['earthquake', 'flood'], required: true },
  location: {
    lat: Number,
    lng: Number,
  },
  description: String,
  timestamp: { type: Date, default: Date.now },
});
module.exports = mongoose.model('Alert', alertSchema);
