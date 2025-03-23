const axios = require('axios');
const xml2js = require('xml2js');
const Alert = require('../model/alert');
const { broadcastAlert } = require('../sockets/alertSocket');

async function fetchFloodAlerts() {
  const { data } = await axios.get('https://www.gdacs.org/xml/rss.xml');
  const parsed = await xml2js.parseStringPromise(data);
  const items = parsed.rss.channel[0].item || [];
  const floodAlerts = items.filter(i => i.title[0].toLowerCase().includes('flood'));

  for (let item of floodAlerts) {
    const title = item.title[0];
    const desc = item.description[0];
    const lat = parseFloat(item['geo:lat']?.[0] || '0');
    const lng = parseFloat(item['geo:long']?.[0] || '0');
    const exists = await Alert.findOne({ description: desc });
    if (!exists) {
      const newAlert = await Alert.create({
        type: 'flood',
        location: { lat, lng },
        description: title,
      });
      broadcastAlert(newAlert);
    }
  }
}
module.exports = { fetchFloodAlerts };