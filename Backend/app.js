const express = require('express'); // Import express
const bodyParser = require('body-parser'); // Import body-parser
const cors = require('cors'); // Import CORS middleware

// Import routers
const userRouter = require('./routers/user.router'); // User routes
const alertRouter = require('./routers/alert.routes'); // Flood alert routes

const app = express(); // Initialize express app

// Middleware
app.use(bodyParser.json()); // Parse incoming JSON payloads
app.use(cors()); // Enable CORS for API access

// Routes
app.use('/', userRouter); // Routes for user registration/login
app.use('/', alertRouter); // Routes for flood alerts

// Root Route
app.get('/', (req, res) => {
  res.send('Welcome to SafeSewa API');
});

// Export app for server initialization
module.exports = app;


