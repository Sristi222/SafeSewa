const express = require('express');
const { getCurrentAlerts } = require('../controller/notification.controller');

const router = express.Router();

// Route to fetch current alerts
router.get('/alerts', getCurrentAlerts);

module.exports = router;
