const mongoose = require('mongoose');

const disasterSchema = new mongoose.Schema({
  type: { type: String, enum: ['earthquake', 'flood', 'fire', 'curfew'], required: true },
  location: {
    lat: Number,
    lng: Number,
  },
  description: String,
  timestamp: { type: Date, default: Date.now },
}, { timestamps: true });

module.exports = mongoose.model('Disaster', disasterSchema);
