// src/pages/Users.jsx
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Card, Col, Container, Form, Row, Spinner, Button } from 'react-bootstrap';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axios.get('http://localhost:3000/api/users')
      .then(res => setUsers(res.data))
      .catch(err => console.error('Error fetching users', err))
      .finally(() => setLoading(false));
  }, []);

  const filteredUsers = users.filter(user =>
    user.username?.toLowerCase().includes(search.toLowerCase()) ||
    user.email?.toLowerCase().includes(search.toLowerCase())
  );

  const deleteUser = async (userId) => {
    if (!window.confirm("Are you sure you want to delete this user?")) return;
    try {
      await axios.delete(`http://localhost:3000/api/users/${userId}`);
      setUsers(users.filter(user => user._id !== userId));
    } catch (error) {
      console.error("Failed to delete user:", error);
    }
  };

  return (
    <Container className="my-4">
      <h2>Registered Users</h2>
      <Form.Control
        type="text"
        placeholder="Search by username or email"
        className="my-3"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />
      {loading ? (
        <div className="text-center my-5">
          <Spinner animation="border" />
        </div>
      ) : (
        <Row xs={1} sm={2} md={3} lg={4} className="g-4">
          {filteredUsers.map((user) => (
            <Col key={user._id}>
              <Card className="h-100">
                <Card.Body>
                  <Card.Title>{user.username || 'No Username'}</Card.Title>
                  <Card.Text>
                    <strong>Email:</strong> {user.email || 'N/A'}<br />
                    <strong>Phone:</strong> {user.phone || 'N/A'}<br />
                    <strong>Role:</strong> {user.role || 'N/A'}<br />
                    <strong>Address:</strong> {user.address || 'N/A'}<br />
                    <strong>Registered:</strong> {new Date(user.createdAt).toLocaleDateString()}
                  </Card.Text>
                  <div className="d-flex justify-content-end gap-2">
                    <Button variant="primary" size="sm">Edit</Button>
                    <Button variant="danger" size="sm" onClick={() => deleteUser(user._id)}>Delete</Button>
                  </div>
                </Card.Body>
              </Card>
            </Col>
          ))}
        </Row>
      )}
    </Container>
  );
};

export default Users;