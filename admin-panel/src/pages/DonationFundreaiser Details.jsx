import React, { useEffect, useState } from 'react';
import axios from 'axios';
import AdminFundraiserDetail from './DonarSummary';

const AdminFundraiserSummary = () => {
  const [summary, setSummary] = useState([]);
  const [selectedFundraiser, setSelectedFundraiser] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;
  const [sortBy, setSortBy] = useState('fundraiserTitle');
  const [sortOrder, setSortOrder] = useState('asc');

  useEffect(() => {
    fetchSummary();
  }, []);

  const fetchSummary = async () => {
    try {
      const res = await axios.get('http://localhost:3000/admin/donations-summary');
      if (res.data.success) {
        setSummary(res.data.summary);
      }
    } catch (err) {
      console.error("❌ Failed to fetch summary", err);
    }
  };

  const filteredSummary = summary.filter(f =>
    f.fundraiserTitle.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const sortedSummary = filteredSummary.sort((a, b) => {
    const valA = a[sortBy];
    const valB = b[sortBy];
    if (sortOrder === 'asc') return valA > valB ? 1 : -1;
    return valA < valB ? 1 : -1;
  });

  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentItems = sortedSummary.slice(indexOfFirstItem, indexOfLastItem);
  const totalPages = Math.ceil(sortedSummary.length / itemsPerPage);

  const handleSort = (key) => {
    if (sortBy === key) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(key);
      setSortOrder('asc');
    }
  };

  return (
    <div style={{ padding: '20px' }}>
      <h2>📟 Fundraiser Summary</h2>

      {selectedFundraiser ? (
        <AdminFundraiserDetail fundraiser={selectedFundraiser} onBack={() => setSelectedFundraiser(null)} />
      ) : (
        <>
          <input
            type="text"
            placeholder="🔍 Search by fundraiser title..."
            value={searchTerm}
            onChange={e => setSearchTerm(e.target.value)}
            style={{ marginBottom: '15px', padding: '8px', width: '300px' }}
          />

          <table className="table table-bordered table-striped">
            <thead className="table-dark">
              <tr>
                <th onClick={() => handleSort('fundraiserTitle')} style={{ cursor: 'pointer' }}>Title {sortBy === 'fundraiserTitle' ? (sortOrder === 'asc' ? '⬆' : '⬇') : ''}</th>
                <th onClick={() => handleSort('goal')} style={{ cursor: 'pointer' }}>Goal Amount {sortBy === 'goal' ? (sortOrder === 'asc' ? '⬆' : '⬇') : ''}</th>
                <th onClick={() => handleSort('raised')} style={{ cursor: 'pointer' }}>Raised {sortBy === 'raised' ? (sortOrder === 'asc' ? '⬆' : '⬇') : ''}</th>
                <th onClick={() => handleSort('donationCount')} style={{ cursor: 'pointer' }}>Donations {sortBy === 'donationCount' ? (sortOrder === 'asc' ? '⬆' : '⬇') : ''}</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {currentItems.map(f => (
                <tr key={f.fundraiserId}>
                  <td>{f.fundraiserTitle}</td>
                  <td>Rs. {f.goal.toLocaleString()}</td>
                  <td><strong>Rs. {f.raised.toLocaleString()}</strong></td>
                  <td>{f.donationCount}</td>
                  <td>
                    <button className="btn btn-primary btn-sm" onClick={() => setSelectedFundraiser(f)}>View Donors</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {/* Pagination */}
          <div className="d-flex justify-content-center mt-3">
            {Array.from({ length: totalPages }, (_, i) => i + 1).map(page => (
              <button
                key={page}
                onClick={() => setCurrentPage(page)}
                className={`btn btn-sm mx-1 ${currentPage === page ? 'btn-primary text-white' : 'btn-outline-secondary'}`}
              >
                {page}
              </button>
            ))}
          </div>
        </>
      )}
    </div>
  );
};

export default AdminFundraiserSummary;
