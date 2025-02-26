const EmergencyContact = require("../model/emergencycontact");
const sendSMS = require("../services/smsService");

exports.addEmergencyContact = async (req, res) => {
  try {
    const { userId, name, phone } = req.body;
    const contact = new EmergencyContact({ userId, name, phone });
    await contact.save();
    res.json({ message: "Emergency contact added successfully!" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getEmergencyContacts = async (req, res) => {
  try {
    const contacts = await EmergencyContact.find({ userId: req.params.userId });
    res.json(contacts);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.sendSOS = async (req, res) => {
  try {
    const { userId, latitude, longitude } = req.body;
    const contacts = await EmergencyContact.find({ userId });

    if (!contacts.length) return res.status(404).json({ error: "No emergency contacts found" });

    const message = `🚨 SOS Alert! Help needed at: https://www.google.com/maps?q=${latitude},${longitude}`;
    contacts.forEach(contact => sendSMS(contact.phone, message));

    res.json({ message: "SOS alert sent successfully!" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
