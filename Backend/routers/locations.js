const express = require('express');
const Location = require('../model/Location');
const router = express.Router();
router.get('/', async (req, res) => {
  const locations = await Location.find();
  res.json(locations);
});
module.exports = router;