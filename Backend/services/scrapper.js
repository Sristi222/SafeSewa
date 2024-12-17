const axios = require('axios');
const cheerio = require('cheerio');

const scrapeWaterLevels = async () => {
  try {
    const url = 'http://www.dhm.gov.np/';
    const response = await axios.get(url);
    const html = response.data;

    const $ = cheerio.load(html);
    const waterLevels = [];

    console.log('Scraping water level data...');

    $('table tr').each((index, element) => {
      if (index > 0) { // Skip the table header
        const stationName = $(element).find('td').eq(0).text().trim();
        const waterLevelRaw = $(element).find('td').eq(1).text().trim();
        const waterLevel = parseFloat(waterLevelRaw.replace(/[^\d.-]/g, '')) || 0;

        if (stationName) {
          waterLevels.push({
            stationName: stationName,
            waterLevel: waterLevel,
            status: waterLevel >= 1 ? 'Flood Alert!' : 'No Flood',
          });
        }
      }
    });

    console.log('Water Levels Scraped:', waterLevels);
    return waterLevels;
  } catch (error) {
    console.error('Error scraping data:', error.message);
    return [];
  }
};

// Export the function
module.exports = { scrapeWaterLevels };
