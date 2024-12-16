const axios = require('axios');
const cheerio = require('cheerio');

let floodAlerts = []; // Array to store flood alerts

// Function to scrape water level data
const scrapeWaterLevels = async () => {
  try {
    const url = 'https://dhm.gov.np/hydrology/realtime-stream'; // Replace with the target webpage URL
    const response = await axios.get(url);
    const html = response.data;

    const $ = cheerio.load(html);
    floodAlerts = []; // Reset the flood alerts array

    // Scrape table data
    $('table tr').each((index, element) => {
      if (index > 0) { // Skip the table header
        const stationName = $(element).find('td:nth-child(4)').text().trim();
        const waterLevelText = $(element).find('td:nth-child(6)').text().trim();
        const waterLevel = parseFloat(waterLevelText);

        if (!isNaN(waterLevel)) {
          if (waterLevel > 6) {
            floodAlerts.push({ stationName, waterLevel, status: 'Flood Alert' });
          } else if (waterLevel < 1) {
            floodAlerts.push({ stationName, waterLevel, status: 'Low Water Level' });
          }
        }
      }
    });

    console.log('Water Levels Scraped Successfully:', floodAlerts);
  } catch (error) {
    console.error('Error scraping water levels:', error.message);
  }
};

// Getter function to access flood alerts
const getFloodAlerts = () => floodAlerts;

module.exports = { scrapeWaterLevels, getFloodAlerts };
