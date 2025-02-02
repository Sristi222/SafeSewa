const express = require('express');
const router = express.Router();
const sosController = require('../controller/sos.controller');

// SOS API endpoint
router.post('/', sosController.sendSos);

module.exports = router;
