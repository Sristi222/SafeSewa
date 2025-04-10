// src/pages/Donations.jsx
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Container, Card, Button, Spinner, Row, Col, Badge } from 'react-bootstrap';

const Donations = () => {
  const [fundraisers, setFundraisers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [approvingId, setApprovingId] = useState(null);

  const fetchFundraisers = async () => {
    setLoading(true);
    try {
      const res = await axios.get('http://localhost:3000/pending-fundraisers');
      if (res.data.success && Array.isArray(res.data.fundraisers)) {
        setFundraisers(res.data.fundraisers);
      } else {
        console.warn("⚠️ No fundraisers returned.");
      }
    } catch (err) {
      console.error("❌ Error fetching fundraisers:", err);
    } finally {
      setLoading(false);
    }
  };

  const approveFundraiser = async (id) => {
    setApprovingId(id);
    try {
      await axios.put(`http://localhost:3000/approve-fundraiser/${id}`);
      fetchFundraisers();
    } catch (err) {
      console.error('❌ Error approving fundraiser:', err);
    } finally {
      setApprovingId(null);
    }
  };

  useEffect(() => {
    fetchFundraisers();
  }, []);

  return (
    <Container className="my-4">
      <div className="d-flex justify-content-between align-items-center mb-3">
        <h2>📝 Pending Fundraisers</h2>
        <Button onClick={fetchFundraisers} variant="outline-primary" size="sm">Refresh</Button>
      </div>

      {loading ? (
        <div className="text-center my-5">
          <Spinner animation="border" />
        </div>
      ) : fundraisers.length > 0 ? (
        fundraisers.map(f => (
          <Card key={f._id} className="mb-4 shadow-sm">
            <Card.Body>
              <Row>
                <Col md={9}>
                  <Card.Title className="mb-2">{f.title}</Card.Title>
                  <div className="mb-2">
                    <Badge bg="info" className="me-2">{f.category || 'N/A'}</Badge>
                    <Badge bg="warning" text="dark">Goal: ₹{f.goalAmount}</Badge>
                  </div>
                  <Card.Text><strong>Description:</strong> {f.description}</Card.Text>
                  {f.usage && <Card.Text><strong>Usage:</strong> {f.usage}</Card.Text>}
                  {f.location && <Card.Text><strong>Location:</strong> {f.location}</Card.Text>}
                  {f.contactNumber && <Card.Text><strong>Contact:</strong> {f.contactNumber}</Card.Text>}
                  {f.bankInfo && <Card.Text><strong>Bank Info:</strong> {f.bankInfo}</Card.Text>}
                  <Card.Text className="text-muted">
                    <strong>Submitted by:</strong> {f.userId?.name || f.userId || "N/A"}
                  </Card.Text>
                </Col>

                <Col md={3} className="d-flex align-items-center justify-content-end">
                  <Button
                    variant="success"
                    onClick={() => approveFundraiser(f._id)}
                    disabled={approvingId === f._id}
                  >
                    {approvingId === f._id ? (
                      <Spinner size="sm" animation="border" />
                    ) : 'Approve'}
                  </Button>
                </Col>
              </Row>
            </Card.Body>
          </Card>
        ))
      ) : (
        <p className="text-muted">No pending fundraisers to approve.</p>
      )}
    </Container>
  );
};

export default Donations;
