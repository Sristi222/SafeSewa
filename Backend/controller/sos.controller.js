exports.sendSos = (req, res) => {
    const { latitude, longitude, emergencyContact, volunteer } = req.body;

    if (!latitude || !longitude || !emergencyContact || !volunteer) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    console.log(`SOS Alert Received:`);
    console.log(`Location: https://www.google.com/maps?q=${latitude},${longitude}`);
    console.log(`Emergency Contact: ${emergencyContact}`);
    console.log(`Volunteer: ${volunteer}`);

    res.status(200).json({ message: 'SOS alert sent successfully!' });
};
