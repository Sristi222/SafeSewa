const SOSRequest = require('../model/sosRequest');
const Volunteer = require('../model/volunteer');

// Create an SOS Request
exports.createSOSRequest = async (req, res) => {
    try {
        const { userId, latitude, longitude } = req.body;
        const newSOS = await SOSRequest.create({
            userId,
            userLocation: { latitude, longitude }
        });
        res.status(201).json({ success: true, data: newSOS });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error });
    }
};

// Get All Pending SOS Requests
exports.getPendingSOS = async (req, res) => {
    try {
        const pendingSOS = await SOSRequest.find({ status: 'pending' });
        res.status(200).json({ success: true, data: pendingSOS });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error });
    }
};

// Accept an SOS Request
exports.acceptSOSRequest = async (req, res) => {
    try {
        const { volunteerId, sosId } = req.body;
        const sosRequest = await SOSRequest.findByIdAndUpdate(
            sosId,
            { status: 'accepted', volunteerId },
            { new: true }
        );
        res.status(200).json({ success: true, data: sosRequest });
    } catch (error) {
        res.status(500).json({ success: false, message: "Server Error", error });
    }
};
