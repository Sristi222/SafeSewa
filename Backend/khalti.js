const axios = require("axios");

async function initializeKhaltiPayment({
  return_url,
  website_url,
  amount,
  purchase_order_id,
  purchase_order_name,
}) {
  try {
    const headers = {
      Authorization: `Key ${process.env.KHALTI_SECRET_KEY}`,
      "Content-Type": "application/json",
    };

    const body = JSON.stringify({
      return_url: `${process.env.BACKEND_URI}/donation-success`, // ✅ Updated return URL
      website_url,
      amount,
      purchase_order_id,
      purchase_order_name,
    });

    const response = await axios.post(
      `${process.env.KHALTI_GATEWAY_URL}/api/v2/epayment/initiate/`,
      body,
      { headers }
    );
    return response.data;
  } catch (error) {
    throw error.response?.data || { message: "Khalti payment init failed" };
  }
}

async function verifyKhaltiPayment(pidx) {
  try {
    const headers = {
      Authorization: `Key ${process.env.KHALTI_SECRET_KEY}`,
      "Content-Type": "application/json",
    };

    const body = JSON.stringify({ pidx });

    const response = await axios.post(
      `${process.env.KHALTI_GATEWAY_URL}/api/v2/epayment/lookup/`,
      body,
      { headers }
    );
    return response.data;
  } catch (error) {
    throw error.response?.data || { message: "Khalti verification failed" };
  }
}

module.exports = { initializeKhaltiPayment, verifyKhaltiPayment };
