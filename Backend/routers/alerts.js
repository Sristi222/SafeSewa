const express = require('express');
const Alert = require('../model/alert');
const router = express.Router();
router.get('/', async (req, res) => {
  const alerts = await Alert.find().sort({ timestamp: -1 });
  res.json(alerts);
});
module.exports = router;