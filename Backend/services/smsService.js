const axios = require("axios");

async function sendSMS(phone, message) {
  try {
    await axios.post("https://api.infobip.com/sms/2/text/advanced", {
      messages: [{ destinations: [{ to: phone }], text: message }],
    }, { headers: { Authorization: `App ${process.env.INFOBIP_API_KEY}`, "Content-Type": "application/json" }});
  } catch (error) {
    console.error("❌ Failed to send SMS:", error.message);
  }
}

module.exports = sendSMS;
