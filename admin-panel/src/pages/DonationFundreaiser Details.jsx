import React, { useEffect, useState } from 'react';
import axios from 'axios';
import AdminFundraiserDetail from './DonarSummary';
import { Modal, Button, Form } from 'react-bootstrap';

const AdminFundraiserSummary = () => {
  const [summary, setSummary] = useState([]);
  const [selectedFundraiser, setSelectedFundraiser] = useState(null);
  const [editFundraiser, setEditFundraiser] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;
  const [sortBy, setSortBy] = useState('fundraiserTitle');
  const [sortOrder, setSortOrder] = useState('asc');
  const [showModal, setShowModal] = useState(false);
  const [editForm, setEditForm] = useState({ title: '', goal: '' });

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

  const handleDelete = async (id) => {
    if (window.confirm("Are you sure you want to delete this fundraiser?")) {
      try {
        await axios.delete(`http://localhost:3000/fundraisers/${id}`);
        fetchSummary();
      } catch (err) {
        console.error("❌ Error deleting fundraiser", err);
      }
    }
  };

  const handleEditClick = (fundraiser) => {
    setEditFundraiser(fundraiser);
    setEditForm({ title: fundraiser.fundraiserTitle, goal: fundraiser.goal });
    setShowModal(true);
  };

  const handleEditSave = async () => {
    try {
      await axios.put(`http://localhost:3000/fundraisers/${editFundraiser.fundraiserId}`, {
        title: editForm.title,
        goalAmount: parseInt(editForm.goal)
      });
      setShowModal(false);
      fetchSummary();
    } catch (err) {
      console.error("❌ Error updating fundraiser", err);
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
                <th>Actions</th>
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
                    <button className="btn btn-primary btn-sm me-1" onClick={() => setSelectedFundraiser(f)}>View Donors</button>
                    <button className="btn btn-warning btn-sm me-1" onClick={() => handleEditClick(f)}>Edit</button>
                    <button className="btn btn-danger btn-sm" onClick={() => handleDelete(f.fundraiserId)}>Delete</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

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

          <Modal show={showModal} onHide={() => setShowModal(false)}>
            <Modal.Header closeButton>
              <Modal.Title>Edit Fundraiser</Modal.Title>
            </Modal.Header>
            <Modal.Body>
              <Form>
                <Form.Group className="mb-3">
                  <Form.Label>Title</Form.Label>
                  <Form.Control
                    type="text"
                    value={editForm.title}
                    onChange={(e) => setEditForm({ ...editForm, title: e.target.value })}
                  />
                </Form.Group>
                <Form.Group className="mb-3">
                  <Form.Label>Goal Amount</Form.Label>
                  <Form.Control
                    type="number"
                    value={editForm.goal}
                    onChange={(e) => setEditForm({ ...editForm, goal: e.target.value })}
                  />
                </Form.Group>
              </Form>
            </Modal.Body>
            <Modal.Footer>
              <Button variant="secondary" onClick={() => setShowModal(false)}>Cancel</Button>
              <Button variant="primary" onClick={handleEditSave}>Save Changes</Button>
            </Modal.Footer>
          </Modal>
        </>
      )}
    </div>
  );
};

export default AdminFundraiserSummary;
