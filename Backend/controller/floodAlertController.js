const { scrapeWaterLevels } = require('../services/scrapper');
const { sendFloodNotification } = require('../services/notificationServices');

const fetchFloodAlerts = async (req, res) => {
  try {
    // Call scrapeWaterLevels
    const alerts = await scrapeWaterLevels();

    // Send notifications for flood alerts
    alerts.forEach((alert) => {
      if (alert.status === 'Flood Alert!') {
        sendFloodNotification(alert.stationName, alert.waterLevel);
      }
    });

    res.json({ success: true, data: alerts });
  } catch (error) {
    console.error('Error fetching flood alerts:', error.message);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

module.exports = { fetchFloodAlerts };
