const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = require('../config/serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Send flood alert notifications
const sendFloodNotification = (stationName, waterLevel) => {
  const message = {
    notification: {
      title: '⚠️ Flood Alert!',
      body: `${stationName} has a water level of ${waterLevel}.`,
    },
    topic: 'flood-alerts',
  };

  admin.messaging().send(message)
    .then((response) => {
      console.log(`Notification sent: ${response}`);
    })
    .catch((error) => {
      console.error('Error sending notification:', error.message);
    });
};

module.exports = { sendFloodNotification };
