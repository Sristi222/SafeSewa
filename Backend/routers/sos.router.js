const express = require("express");
const { addEmergencyContact, getEmergencyContacts, sendSOS } = require("../controller/sos.controller");

const router = express.Router();

router.post("/emergencycontacts", addEmergencyContact);
router.get("/emergencycontacts/:userId", getEmergencyContacts);
router.post("/sos", sendSOS);

module.exports = router;
