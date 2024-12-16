const scrapper = require('../services/scrapper'); // Import the scrapper module
const { sendNotification } = require('../services/notification.services'); // Import the notification sender

// Function to scrape data and send flood notifications
const scrapeAndSendNotifications = async () => {
  try {
    console.log('Starting water level scraping and notification process...');
    await scrapper.scrapeWaterLevels(); // Call scrapeWaterLevels from scrapper.js

    // Fetch the alerts after scraping
    const floodAlerts = scrapper.getFloodAlerts();

    // Loop through flood alerts and send notifications
    floodAlerts.forEach((alert) => {
      if (alert.status === 'Flood Alert') {
        sendNotification(
          `Flood Alert at ${alert.stationName}`,
          `Water Level: ${alert.waterLevel} meters`
        );
      }
    });

    console.log('Scraping and notifications completed successfully!');
  } catch (error) {
    console.error('Error during scraping and sending notifications:', error.message);
  }
};

// Function to get current flood and safe alerts
const getCurrentAlerts = (req, res) => {
  try {
    const floodAlerts = scrapper.getFloodAlerts(); // Fetch flood alerts
    const safeAlerts = scrapper.getSafeAlerts();   // Fetch safe alerts

    res.status(200).json({ floodAlerts, safeAlerts }); // Return as JSON response
  } catch (error) {
    console.error('Error fetching current alerts:', error.message);
    res.status(500).json({ message: 'Error fetching alerts', error: error.message });
  }
};

module.exports = { scrapeAndSendNotifications, getCurrentAlerts };
