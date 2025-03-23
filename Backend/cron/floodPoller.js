const { fetchFloodAlerts } = require('../utils/fetchFloodAlerts');
function startFloodPolling() {
  setInterval(() => {
    fetchFloodAlerts().catch(console.error);
  }, 5 * 60 * 1000);
}
module.exports = { startFloodPolling };