const app = require("./app");
const db = require("./config/db");
const UserModel = require('./model/user.model');
const os = require('os'); // Import os module to fetch network interfaces
const userRouter = require("./routers/user.router");

// Define the port
const port = process.env.PORT || 3000;

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
app.use("/api", userRouter); 

// Root route
app.get('/', (req, res) => {
    res.send("Hello World !!!");
});

// API endpoint to send SOS
app.post('/api/send-sms', async (req, res) => {
    const { contacts, message } = req.body;

    if (!contacts || !message) {
        return res.status(400).json({ error: 'Contacts and message are required.' });
    }

    try {
        console.log(`Sending message to contacts: ${JSON.stringify(contacts)}`);

        // Nodemailer email as an alternative (for debugging)
        const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: process.env.EMAIL,
                pass: process.env.PASSWORD,
            },
        });

        for (let contact of contacts) {
            console.log(`Sending SOS to ${contact.phone}: ${message}`);
            await transporter.sendMail({
                from: process.env.EMAIL,
                to: process.env.EMAIL,
                subject: `SOS Alert for ${contact.name}`,
                text: `Message: ${message}`,
            });
        }

        res.status(200).json({ success: true, message: 'SOS sent to contacts.' });
    } catch (error) {
        console.error('Error sending SOS:', error);
        res.status(500).json({ error: 'Failed to send SOS.' });
    }
});
// Additional route to show IP configuration
app.get('/ipconfig', (req, res) => {
    const interfaces = os.networkInterfaces();
    const ipConfig = Object.entries(interfaces).map(([name, addresses]) => {
        return {
            interface: name,
            addresses: addresses.filter(addr => addr.family === 'IPv4').map(addr => ({
                address: addr.address,
                netmask: addr.netmask,
                internal: addr.internal
            }))
        };
    });
    res.json(ipConfig);
});



const INFOBIP_API_KEY = "227e7805be7a2b2a006dfb06b217e50f-5eef9cbc-075f-4559-838f-f405c1cabfee";
const INFOBIP_URL = "https://api.infobip.com/sms/2/text/advanced";


// Start the server and allow external connections
app.listen(port, '0.0.0.0', () => {
    const localIp = getLocalIpAddress();
    console.log(`Server is running on:`);
    console.log(` - Local: http://localhost:${port}`);
    console.log(` - Network: http://${localIp}:${port}`);
});
