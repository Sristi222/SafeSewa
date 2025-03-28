const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
  title: String,
  organization: String,
  image: String,
  location: String,
  date: String,
  time: String,
  spots: Number,
  description: String,
  enrolled: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }]
});

module.exports = mongoose.model('Event', eventSchema);
