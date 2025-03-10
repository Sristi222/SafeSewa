const app = require("./app");
const db = require("./config/db");
const dbdonation = require("./config/dbdonation");
require("dotenv").config();
const bodyParser = require("body-parser");
const UserModel = require('./model/user.model');
const os = require('os'); // Import os module to fetch network interfaces
const userRouter = require("./routers/user.router");
const { initializeKhaltiPayment, verifyKhaltiPayment } = require("./khalti");
const Donation = require("./donationModel");
const mongoose = require('mongoose');
const connectToMongo = require("./config/dbdonation");

connectToMongo();

// Define the port
const port = process.env.PORT || 3000;

// ✅ Connect to MongoDB before starting the server
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/newauth';
mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log("✅ Connected to MongoDB"))
    .catch(err => {
        console.error("❌ MongoDB Connection Error:", err);
        process.exit(1); // Exit the app if DB connection fails
    });

// Function to get the local IP address
function getLocalIpAddress() {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                return iface.address; // Return the first non-internal IPv4 address
            }
        }
    }
    return '127.0.0.1'; // Fallback to localhost if no IP is found
}

// ✅ Middleware
app.use(bodyParser.json());
app.use("/api", userRouter);

// Root route
app.get('/', (req, res) => {
    res.send("Hello World !!!");
});



// ✅ IP Configuration Route
app.get('/ipconfig', (req, res) => {
    const interfaces = os.networkInterfaces();
    const ipConfig = Object.entries(interfaces).map(([name, addresses]) => ({
        interface: name,
        addresses: addresses.filter(addr => addr.family === 'IPv4').map(addr => ({
            address: addr.address,
            netmask: addr.netmask,
            internal: addr.internal
        }))
    }));
    res.json(ipConfig);
});

// ✅ Fundraiser Schema
const FundraiserSchema = new mongoose.Schema({
    title: { type: String, required: true },
    description: { type: String, required: true },
    goalAmount: { type: Number, required: true },
    raisedAmount: { type: Number, default: 0 },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    status: { type: String, default: "pending" }
});
const Fundraiser = mongoose.model("Fundraiser", FundraiserSchema);

// ✅ Apply for Fundraising
app.post("/fundraise", async (req, res) => {
    try {
        const { title, description, goalAmount, userId } = req.body;
        if (!title || !description || !goalAmount || !userId) {
            return res.status(400).json({ success: false, message: "All fields are required" });
        }

        const fundraiser = new Fundraiser({
            title,
            description,
            goalAmount,
            userId: new mongoose.Types.ObjectId(userId)
        });

        await fundraiser.save();
        res.status(201).json({ success: true, message: "Fundraiser application submitted", fundraiser });
    } catch (error) {
        console.error("❌ Error Saving Fundraiser:", error);
        res.status(500).json({ success: false, message: "Error saving fundraiser", error });
    }
});

// ✅ Get Pending Fundraisers
app.get("/pending-fundraisers", async (req, res) => {
    try {
        const fundraisers = await Fundraiser.find({ status: "pending" });
        res.json({ success: true, fundraisers });
    } catch (error) {
        console.error("❌ Error Fetching Pending Fundraisers:", error);
        res.status(500).json({ success: false, message: "Error fetching pending fundraisers" });
    }
});

app.put("/approve-fundraiser/:id", async (req, res) => {
    try {
        const fundraiser = await Fundraiser.findByIdAndUpdate(req.params.id, { status: "approved" }, { new: true });
        if (!fundraiser) {
            return res.status(404).json({ message: "Fundraiser not found" });
        }
        res.json({ success: true, message: "Fundraiser approved", fundraiser });
    } catch (error) {
        console.error("❌ Error approving fundraiser:", error);
        res.status(500).json({ success: false, message: "Error approving fundraiser" });
    }
});


app.put("/approve-fundraiser/:id", async (req, res) => {
    console.log(`📡 Approving fundraiser with ID: ${req.params.id}`);
    try {
        const fundraiser = await Fundraiser.findByIdAndUpdate(
            req.params.id,
            { status: "approved" },
            { new: true }
        );

        if (!fundraiser) {
            console.log("⚠️ Fundraiser not found!");
            return res.status(404).json({ message: "Fundraiser not found" });
        }

        console.log("✅ Fundraiser approved:", fundraiser);
        res.json({ message: "Fundraiser approved", fundraiser });
    } catch (error) {
        console.error("❌ Error approving fundraiser:", error);
        res.status(500).json({ message: "Error approving fundraiser", error });
    }
});
//approved fundraizer by admin
app.get('/approved-fundraisers', async (req, res) => {
    try {
      // Fetch approved fundraisers from the database
      const fundraisers = await Fundraiser.find({ status: 'approved' });
      res.json(fundraisers);
    } catch (err) {
      console.error("Error fetching fundraisers:", err);
      res.status(500).json({ error: "Internal server error" });
    }
  });

  app.get('/fundraisers/:id', async (req, res) => {
    const fundraiserId = req.params.id;
    
    try {
      const fundraiser = await Fundraiser.findById(fundraiserId);
      
      if (!fundraiser) {
        return res.status(404).send({ message: 'Fundraiser not found' });
      }
      
      res.status(200).json(fundraiser);
    } catch (error) {
      console.error('Error fetching fundraiser:', error);
      res.status(500).send({ message: 'Internal server error' });
    }
  });

  
  
  // ✅ Donation Routes with Khalti Integration
app.post("/donate", async (req, res) => {
    try {
        const { donorName, amount, website_url } = req.body;

        if (!donorName || !amount) {
            return res.status(400).json({ success: false, message: "Donor name and amount are required" });
        }

        console.log("🔹 Received Donation Request:", { donorName, amount });

        // ✅ Save donation in MongoDB with status "pending"
        const donation = await Donation.create({
            donorName,
            amount: amount * 100, // Khalti requires paisa
            paymentMethod: "khalti",
            status: "pending"
        });

        console.log("✅ Donation Saved in DB:", donation);

        // ✅ Convert `_id` to a string before sending to Khalti
        const paymentInit = await initializeKhaltiPayment({
            amount: amount * 100,
            purchase_order_id: donation._id.toString(),
            purchase_order_name: `Donation by ${donorName}`,
            return_url: `${process.env.BACKEND_URI}/verify-donation`,
            website_url,
        });

        console.log("✅ Payment Initialized:", paymentInit);

        // ✅ Store `pidx` in the donation record for verification
        await Donation.findByIdAndUpdate(donation._id, { pidx: paymentInit.pidx });

        res.json({ success: true, payment: paymentInit });
    } catch (error) {
        console.error("❌ Error Initializing Payment:", error);
        res.status(500).json({ success: false, message: "Error initializing payment", error });
    }
});

// ✅ Verify Khalti Payment
app.get("/verify-donation", async (req, res) => {
    try {
        console.log("🔹 Received Payment Verification Request:", req.query);

        // ✅ Verify Payment with Khalti
        const paymentInfo = await verifyKhaltiPayment(req.query.pidx);
        console.log("🔹 Khalti Payment Info:", paymentInfo);

        if (!paymentInfo || paymentInfo.status !== "Completed") {
            return res.status(400).json({ success: false, message: "Payment not completed", paymentInfo });
        }

        console.log("🔹 Searching for Donation with pidx:", req.query.pidx);

        // ✅ Find donation using `pidx` and update status
        const donation = await Donation.findOneAndUpdate(
            { pidx: req.query.pidx },
            { status: "completed", transactionId: req.query.transaction_id },
            { new: true }
        );

        if (!donation) {
            console.error("❌ Donation record NOT found in DB:", req.query.pidx);
            return res.status(400).json({ success: false, message: "Donation record not found" });
        }

        console.log("✅ Donation Verified and Updated:", donation);

        res.json({ success: true, message: "Donation Successful", donation });
    } catch (error) {
        console.error("❌ Error Verifying Payment:", error);
        res.status(500).json({ success: false, message: "Error verifying payment", error });
    }
});

// ✅ IP Configuration Route
app.get('/ipconfig', (req, res) => {
    const interfaces = os.networkInterfaces();
    const ipConfig = Object.entries(interfaces).map(([name, addresses]) => ({
        interface: name,
        addresses: addresses.filter(addr => addr.family === 'IPv4').map(addr => ({
            address: addr.address,
            netmask: addr.netmask,
            internal: addr.internal
        }))
    }));
    res.json(ipConfig);
});


// ✅ Start Server
app.listen(port, '0.0.0.0', () => {
    const localIp = getLocalIpAddress();
    console.log(`Server running on:`);
    console.log(` - Local: http://localhost:${port}`);
    console.log(` - Network: http://${localIp}:${port}`);
});
