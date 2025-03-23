const mongoose = require('mongoose');
const locationSchema = new mongoose.Schema({
  name: String,
  type: { type: String, enum: ['hospital', 'shelter'], required: true },
  location: {
    lat: Number,
    lng: Number,
  },
});
module.exports = mongoose.model('Location', locationSchema);