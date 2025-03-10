const express = require('express');
const { registerVolunteer } = require('../controller/volunteerController');
const router = express.Router();

router.post('/register', registerVolunteer);

module.exports = router;
