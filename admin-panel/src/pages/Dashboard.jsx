// src/pages/Dashboard.jsx
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Card, Row, Col, Container, Spinner } from 'react-bootstrap';

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axios.get('http://localhost:3000/api/admin/stats')
      .then(res => {
        setStats(res.data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Error fetching stats', err);
        setLoading(false);
      });
  }, []);

  const cards = [
    {
      title: "Total Users",
      value: stats?.totalUsers || 0,
      bg: "primary",
    },
    {
      title: "Pending Volunteers",
      value: stats?.pendingVolunteers || 0,
      bg: "success",
    },
    {
      title: "Pending Fundraisers",
      value: stats?.pendingFundraisers || 0,
      bg: "warning",
    },
    {
      title: "SOS Alerts",
      value: stats?.sosAlerts || 0,
      bg: "danger",
    },
  ];

  return (
    <Container className="my-4">
      <h2 className="mb-4">📊 Admin Dashboard</h2>
      {loading ? (
        <div className="text-center mt-5">
          <Spinner animation="border" variant="primary" />
          <p className="mt-2">Loading dashboard...</p>
        </div>
      ) : (
        <Row className="g-4">
          {cards.map((card, index) => (
            <Col md={3} sm={6} key={index}>
              <Card className={`text-white bg-${card.bg} shadow`}>
                <Card.Body>
                  <Card.Title>{card.title}</Card.Title>
                  <h2>{card.value}</h2>
                </Card.Body>
              </Card>
            </Col>
          ))}
        </Row>
      )}
    </Container>
  );
};

export default Dashboard;
