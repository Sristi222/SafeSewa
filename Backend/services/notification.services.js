const admin = require('firebase-admin');

// Function to send notifications using Firebase
const sendNotification = async (title, body) => {
  const message = {
    notification: { title, body },
    topic: 'flood-alerts', // Topic name to broadcast notifications
  };

  try {
    await admin.messaging().send(message);
    console.log('Notification sent:', title);
  } catch (error) {
    console.error('Error sending notification:', error);
  }
};

module.exports = { sendNotification };
