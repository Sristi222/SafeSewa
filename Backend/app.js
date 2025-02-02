const express = require('express'); // Import express
const bodyParser = require('body-parser'); // Import body-parser
const cors = require('cors'); // Import CORS middleware
const floodAlertRoutes = require('./routers/floodAlertRoutes');
const sosRoutes = require('./routers/sos.router');
const postRoutes = require('./routers/postRoutes');
const connectDB = require('./config/dbpost');

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
app.use('/api/sos', sosRoutes);
require('dotenv').config();



// Middleware
app.use(cors());
app.use(bodyParser.json());

// Connect to MongoDB
connectDB();

// Routes
app.use('/posts', postRoutes);



// Root Route
app.get('/', (req, res) => {
  res.send('Welcome to SafeSewa API');
});

// Export app for server initialization
module.exports = app;


