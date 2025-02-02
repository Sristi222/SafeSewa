const mongoose = require('mongoose');

const postSchema = new mongoose.Schema({
    username: { type: String, required: true },
    content: { type: String, required: true },
    createdAt: { type: String, required: true },  // Ensure createdAt is always stored as a String (ISO format)
    updatedAt: { type: String }  // Optional field for updates
});

module.exports = mongoose.model('Post', postSchema);
