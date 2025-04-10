const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    body: { type: String, required: true },
    type: {
      type: String,
      enum: ['flood', 'earthquake'],
      required: true,
    },
    metadata: { type: Object },
    timestamp: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

const Notification =
  mongoose.models.Notification || mongoose.model('Notification', notificationSchema);

module.exports = Notification;
