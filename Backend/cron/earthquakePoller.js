const axios = require('axios');
const Alert = require('../model/alert');
const { broadcastAlert } = require('../sockets/alertSocket');

function startEarthquakePolling() {
  setInterval(async () => {
    const { data } = await axios.get(
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_hour.geojson'
    );
    for (let feature of data.features) {
      const coords = feature.geometry.coordinates;
      const desc = feature.properties.title;
      const already = await Alert.findOne({ description: desc });
      if (!already) {
        const newAlert = await Alert.create({
          type: 'earthquake',
          location: { lat: coords[1], lng: coords[0] },
          description: desc,
        });
        broadcastAlert(newAlert);
      }
    }
  }, 60000);
}
module.exports = { startEarthquakePolling };
