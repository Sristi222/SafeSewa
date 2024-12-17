const express = require('express'); // Import express
const bodyParser = require('body-parser'); // Import body-parser
const cors = require('cors'); // Import CORS middleware
const floodAlertRoutes = require('./routers/floodAlertRoutes');

// Import routers
const userRouter = require('./routers/user.router'); // User routes


const app = express(); // Initialize express app

// Middleware
app.use(bodyParser.json()); // Parse incoming JSON payloads
app.use(cors()); // Enable CORS for API access
app.use(express.json());//Mildeware

// Routes
app.use('/', userRouter); // Routes for user registration/login
app.use('/api', floodAlertRoutes); // Routes for flood alerts

// Root Route
app.get('/', (req, res) => {
  res.send('Welcome to SafeSewa API');
});

// Export app for server initialization
module.exports = app;


