import React, { useEffect, useState } from 'react';
import axios from 'axios';

const AdminFundraiserDetail = ({ fundraiser, onBack }) => {
  const [donations, setDonations] = useState([]);

  useEffect(() => {
    fetchDonations();
  }, []);

  const fetchDonations = async () => {
    try {
      const res = await axios.get(`http://localhost:3000/admin/fundraiser-donations/${fundraiser.fundraiserId}`);
      if (res.data.success) {
        setDonations(res.data.donations);
      }
    } catch (err) {
      console.error("❌ Failed to fetch donations", err);
    }
  };

  return (
    <div>
      <h3>Donations for: {fundraiser.fundraiserTitle}</h3>
      <button onClick={onBack}>⬅ Back to Summary</button>
      <table border="1" cellPadding="8" style={{ marginTop: 10 }}>
        <thead>
          <tr>
            <th>Donor</th>
            <th>Amount (Rs.)</th>
            <th>Date</th>
          </tr>
        </thead>
        <tbody>
          {donations.map(d => (
            <tr key={d._id}>
              <td>{d.donorName}</td>
              <td>{d.amount}</td>
              <td>{new Date(d.createdAt).toLocaleString()}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default AdminFundraiserDetail;
