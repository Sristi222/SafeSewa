const Notification = require('../model/notification');

exports.createFloodNotification = async (req, res) => {
  try {
    const { title, body } = req.body;

    const notification = new Notification({
      title,
      body,
      type: 'flood',
      timestamp: new Date()
    });

    await notification.save();
    res.status(201).json({ success: true, message: 'Flood notification saved.' });
  } catch (error) {
    console.error('❌ Error saving flood notification:', error);
    res.status(500).json({ success: false, message: 'Failed to save notification.' });
  }
};


exports.getAllNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find().sort({ timestamp: -1 });
    res.json(notifications);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
};
