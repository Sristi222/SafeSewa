const express = require('express');
const { fetchFloodAlerts } = require('../controller/floodAlertController');

const router = express.Router();

router.get('/flood-alerts', fetchFloodAlerts);

module.exports = router;
