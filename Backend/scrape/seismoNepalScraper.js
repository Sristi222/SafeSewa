const axios = require('axios');
const cheerio = require('cheerio');
const mongoose = require('mongoose');
const Disaster = require('../model/disaster');

mongoose.connect('mongodb://localhost:27017/newauth', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

async function scrapeEarthquakeData() {
  try {
    const { data } = await axios.get('https://seismonepal.gov.np/', {
      headers: { 'User-Agent': 'Mozilla/5.0' },
      timeout: 10000
    });

    const $ = cheerio.load(data);
    const rows = $('table tbody tr');

    for (let i = 0; i < rows.length; i++) {
      const cols = $(rows[i]).find('td');

      const dateRaw = $(cols[1]).text().trim().split('\n')[1]?.replace('A.D.:', '').trim();
      const timeRaw = $(cols[2]).text().trim().split('\n')[0]?.replace('Local:', '').trim();
      const latitude = parseFloat($(cols[3]).text().trim());
      const longitude = parseFloat($(cols[4]).text().trim());
      const magnitude = parseFloat($(cols[5]).text().trim());
      const epicenter = $(cols[6]).text().trim();

      if (!dateRaw || !timeRaw || isNaN(latitude) || isNaN(longitude) || isNaN(magnitude)) continue;

      if (magnitude >= 4.0) {
        const exists = await Disaster.findOne({
          type: 'earthquake',
          'location.lat': latitude,
          'location.lng': longitude,
          description: new RegExp(epicenter, 'i'),
        });

        if (!exists) {
          await Disaster.create({
            type: 'earthquake',
            location: { lat: latitude, lng: longitude },
            description: `Mag ${magnitude} at ${epicenter}`,
            timestamp: new Date(`${dateRaw} ${timeRaw}`)
          });
          console.log(`✅ Saved: Mag ${magnitude} at ${epicenter}`);
        }
      }
    }
  } catch (err) {
    console.error('❌ Error scraping earthquake data:', err.message);
  } finally {
    mongoose.connection.close();
  }
}

module.exports = scrapeEarthquakeData;
