const express = require('express');
const router = express.Router();
const Disaster = require('../model/disaster');

// GET all earthquake disasters
router.get('/', async (req, res) => {
    try {
      console.log("📥 GET /api/disasters called");
      const disasters = await Disaster.find().sort({ timestamp: -1 });
      console.log("📤 Disasters fetched:", disasters.length);
      res.json(disasters);
    } catch (error) {
      console.error('🔥 Error fetching disasters:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });

module.exports = router;


  
