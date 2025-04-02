// src/pages/DonationHistory.jsx
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Container, Table, Spinner, Form, Row, Col, Pagination } from 'react-bootstrap';

const DonationHistory = () => {
  const [donations, setDonations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('All');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;

  useEffect(() => {
    axios.get('http://localhost:3000/donations')
      .then(res => setDonations(res.data))
      .catch(err => console.error('Error fetching donations:', err))
      .finally(() => setLoading(false));
  }, []);

  const filteredDonations = donations.filter(donation => {
    const matchesSearch = donation.donorName?.toLowerCase().includes(search.toLowerCase());
    const matchesStatus = statusFilter === 'All' || donation.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentDonations = filteredDonations.slice(indexOfFirstItem, indexOfLastItem);
  const totalPages = Math.ceil(filteredDonations.length / itemsPerPage);

  return (
    <Container className="my-4">
      <h2>Donation History</h2>

      <Row className="mb-3">
        <Col md={6}>
          <Form.Control
            type="text"
            placeholder="Search by donor name"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </Col>
        <Col md={4}>
          <Form.Select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
            <option value="All">All Statuses</option>
            <option value="pending">Pending</option>
            <option value="completed">Completed</option>
            <option value="failed">Failed</option>
          </Form.Select>
        </Col>
      </Row>

      {loading ? (
        <div className="text-center my-5">
          <Spinner animation="border" />
        </div>
      ) : (
        <>
          <Table striped bordered hover responsive>
            <thead>
              <tr>
                <th>Donation ID</th>
                <th>Donor Name</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Payment Method</th>
                <th>Transaction ID</th>
                <th>PIDX</th>
                <th>Created At</th>
                <th>Updated At</th>
              </tr>
            </thead>
            <tbody>
              {currentDonations.map((donation) => (
                <tr key={donation._id}>
                  <td>{donation._id}</td>
                  <td>{donation.donorName || 'N/A'}</td>
                  <td>Rs. {donation.amount}</td>
                  <td>{donation.status || 'N/A'}</td>
                  <td>{donation.paymentMethod || 'N/A'}</td>
                  <td>{donation.transactionId || 'N/A'}</td>
                  <td>{donation.pidx || 'N/A'}</td>
                  <td>{new Date(donation.createdAt).toLocaleString()}</td>
                  <td>{new Date(donation.updatedAt).toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </Table>

          {totalPages > 1 && (
            <Pagination className="justify-content-center">
              {[...Array(totalPages)].map((_, idx) => (
                <Pagination.Item
                  key={idx + 1}
                  active={idx + 1 === currentPage}
                  onClick={() => setCurrentPage(idx + 1)}
                >
                  {idx + 1}
                </Pagination.Item>
              ))}
            </Pagination>
          )}
        </>
      )}
    </Container>
  );
};

export default DonationHistory;