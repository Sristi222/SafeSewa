const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');

// Test push route
router.get('/test-push', async (req, res) => {
  try {
    const message = {
      topic: 'disaster_alerts',
      notification: {
        title: '⚠️ Earthquake Alert',
        body: 'This is a test notification from the backend!',
      },
    };

    await admin.messaging().send(message);
    console.log("✅ Test push sent to topic 'disaster_alerts'");
    res.send('✅ Push notification sent!');
  } catch (error) {
    console.error("❌ Failed to send push:", error);
    res.status(500).send('❌ Failed to send push');
  }
});

module.exports = router;
