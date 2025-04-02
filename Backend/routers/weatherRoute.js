const express = require('express');
const axios = require('axios');
const router = express.Router();

const API_KEY = 'efb624a05830a779117ef7f83133567c';
const CITY = 'Kathmandu'; // or use lat/lon

router.get('/', async (req, res) => {
  try {
    const url = `https://api.openweathermap.org/data/2.5/weather?q=${CITY}&appid=${API_KEY}&units=metric`;
    const { data } = await axios.get(url);
    res.json({
      temp: data.main.temp,
      description: data.weather[0].description,
      icon: data.weather[0].icon,
      city: data.name
    });
  } catch (err) {
    console.error('❌ Weather API error:', err.message);
    res.status(500).json({ error: 'Unable to fetch weather data' });
  }
});

module.exports = router;
