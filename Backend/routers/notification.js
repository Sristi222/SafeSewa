const express = require('express');
const router = express.Router();
const Notification = require('../model/notification');
const controller = require('../controller/notificationController');

// ✅ Save notification (for both flood & earthquake)
router.post('/', async (req, res) => {
  try {
    const { title, body, type = 'general', timestamp } = req.body;

    const notif = new Notification({
      title,
      body,
      type, // ✅ now saves type (earthquake, flood, etc.)
      timestamp: timestamp ? new Date(timestamp) : new Date(),
    });

    await notif.save();
    res.status(201).json({ message: 'Notification saved' });
  } catch (err) {
    console.error('❌ Error saving notification:', err);
    res.status(500).json({ error: 'Failed to save notification' });
  }
});

// 🔁 Existing flood-specific endpoint (optional, still works)
router.post('/flood', controller.createFloodNotification);

// 📥 Get all notifications
router.get('/', async (req, res) => {
  try {
    const notifs = await Notification.find().sort({ timestamp: -1 });
    res.json(notifs);
  } catch (err) {
    console.error('❌ Error fetching notifications:', err);
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});

module.exports = router;
