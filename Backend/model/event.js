const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
  },
  organization: {
    type: String,
    required: true,
    trim: true,
  },
  image: {
    type: String,
    default: '',
  },
  location: {
    type: String,
    required: true,
    trim: true,
  },
  date: {
    type: String,
    required: true,
  },
  time: {
    type: String,
    required: true,
  },
  spots: {
    type: Number,
    required: true,
    min: 0, // 🔄 allow 0 to support full events
  },
  description: {
    type: String,
    required: true,
  },
  enrolled: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
  ],
}, {
  timestamps: true,
});

module.exports = mongoose.model('Event', eventSchema);
