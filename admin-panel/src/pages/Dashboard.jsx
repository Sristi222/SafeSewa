// src/pages/Dashboard.jsx
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Card, Row, Col, Container } from 'react-bootstrap';

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalUsers: 0,
    pendingVolunteers: 0,
    pendingFundraisers: 0,
    sosAlerts: 0,
  });

  useEffect(() => {
    axios.get('http://localhost:3000/api/admin/stats')
      .then(res => setStats(res.data))
      .catch(err => console.error('Error fetching stats', err));
  }, []);

  return (
    <Container className="my-4">
      <h2 className="mb-4">Admin Dashboard</h2>
      <Row className="g-4">
        <Col md={3}>
          <Card className="text-white bg-primary">
            <Card.Body>
              <Card.Title>Total Users</Card.Title>
              <Card.Text>{stats.totalUsers}</Card.Text>
            </Card.Body>
          </Card>
        </Col>
        <Col md={3}>
          <Card className="text-white bg-success">
            <Card.Body>
              <Card.Title>Pending Volunteers</Card.Title>
              <Card.Text>{stats.pendingVolunteers}</Card.Text>
            </Card.Body>
          </Card>
        </Col>
        <Col md={3}>
          <Card className="text-white bg-warning">
            <Card.Body>
              <Card.Title>Pending Fundraisers</Card.Title>
              <Card.Text>{stats.pendingFundraisers}</Card.Text>
            </Card.Body>
          </Card>
        </Col>
        <Col md={3}>
          <Card className="text-white bg-danger">
            <Card.Body>
              <Card.Title>SOS Alerts</Card.Title>
              <Card.Text>{stats.sosAlerts}</Card.Text>
            </Card.Body>
          </Card>
        </Col>
      </Row>
    </Container>
  );
};

export default Dashboard;
