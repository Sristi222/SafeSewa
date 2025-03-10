const axios = require("axios");

async function initializeKhaltiPayment({ return_url, website_url, amount, purchase_order_id, purchase_order_name }) {
  try {
    let headers = {
      Authorization: `Key ${process.env.KHALTI_SECRET_KEY}`,
      "Content-Type": "application/json",
    };

    let body = JSON.stringify({
      return_url,
      website_url,
      amount,
      purchase_order_id,
      purchase_order_name,
    });

    let response = await axios.post(`${process.env.KHALTI_GATEWAY_URL}/api/v2/epayment/initiate/`, body, { headers });
    return response.data;
  } catch (error) {
    throw error.response.data;
  }
}

async function verifyKhaltiPayment(pidx) {
  try {
    let headers = {
      Authorization: `Key ${process.env.KHALTI_SECRET_KEY}`,
      "Content-Type": "application/json",
    };

    let body = JSON.stringify({ pidx });

    let response = await axios.post(`${process.env.KHALTI_GATEWAY_URL}/api/v2/epayment/lookup/`, body, { headers });
    return response.data;
  } catch (error) {
    throw error.response.data;
  }
}

module.exports = { initializeKhaltiPayment, verifyKhaltiPayment };
