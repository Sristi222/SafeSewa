const mongoose = require('mongoose');

const postSchema = new mongoose.Schema({
  userId: { type: String }, // optional but helpful
  username: { type: String, required: true },
  content: { type: String, required: true },
  image: { type: String }, // ✅ optional image field (file path or URL)
  createdAt: { type: String, required: true },
  updatedAt: { type: String },

  likes: {
    type: Number,
    default: 0,
  },

  replies: [
    {
      message: { type: String },
      repliedAt: { type: Date, default: Date.now },
    },
  ],
});

module.exports = mongoose.model('Post', postSchema);
