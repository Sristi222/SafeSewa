// src/pages/Donations.jsx
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Container, Card, Button, Spinner } from 'react-bootstrap';

const Donations = () => {
  const [fundraisers, setFundraisers] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchFundraisers = () => {
    setLoading(true);
    axios.get('http://localhost:3000/pending-fundraisers')
      .then(res => {
        if (res.data.success) {
          setFundraisers(res.data.fundraisers);
        }
      })
      .catch(err => console.error('Error fetching fundraisers', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchFundraisers();
  }, []);

  const approveFundraiser = (id) => {
    axios.put(`http://localhost:3000/approve-fundraiser/${id}`)
      .then(() => {
        fetchFundraisers();
      })
      .catch(err => console.error('Error approving fundraiser', err));
  };

  return (
    <Container className="my-4">
      <h2>Pending Fundraisers</h2>
      {loading ? (
        <div className="text-center my-5">
          <Spinner animation="border" />
        </div>
      ) : (
        fundraisers.length > 0 ? (
          fundraisers.map(fundraiser => (
            <Card key={fundraiser._id} className="mb-3">
              <Card.Body>
                <Card.Title>{fundraiser.title}</Card.Title>
                <Card.Text>{fundraiser.description}</Card.Text>
                <Button variant="primary" onClick={() => approveFundraiser(fundraiser._id)}>
                  Approve
                </Button>
              </Card.Body>
            </Card>
          ))
        ) : <p>No pending fundraisers.</p>
      )}
    </Container>
  );
};

export default Donations;
