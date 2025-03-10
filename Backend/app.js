const express = require('express'); // Import express
const bodyParser = require('body-parser'); // Import body-parser
const cors = require('cors'); // Import CORS middleware
const floodAlertRoutes = require('./routers/floodAlertRoutes');

const postRoutes = require('./routers/postRoutes');
const connectDB = require('./config/dbpost');
const { createAdminIfNotExists } = require("./model/user.model");
const userRouter = require("./routers/user.router");
// Import routers



const app = express(); // Initialize express app

// Middleware
app.use(bodyParser.json()); // Parse incoming JSON payloads
app.use(cors()); // Enable CORS for API access
app.use(express.json());//Mildeware

// Routes
app.use("/api", userRouter);
app.use('/', userRouter); // Routes for user registration/login
app.use('/api', floodAlertRoutes); // Routes for flood alerts
require('dotenv').config();



// Ensure admin exists
// ✅ Ensure Admin Exists on Startup
createAdminIfNotExists().then(() => {
  console.log("🚀 Admin check complete!");
}).catch((err) => {
  console.error("❌ Error creating admin:", err);
});



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


