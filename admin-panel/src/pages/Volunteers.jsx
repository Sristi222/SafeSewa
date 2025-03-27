// src/pages/Volunteers.jsx
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Table, Container, Button, Spinner } from 'react-bootstrap';

const Volunteers = () => {
  const [volunteers, setVolunteers] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchVolunteers = () => {
    setLoading(true);
    axios.get('http://localhost:3000/api/volunteers/pending')
      .then(res => setVolunteers(res.data.volunteers))
      .catch(err => console.error('Error fetching volunteers', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchVolunteers();
  }, []);

  const approveVolunteer = (id) => {
    axios.put(`http://localhost:3000/api/volunteers/approve/${id}`)
      .then(() => {
        setVolunteers(volunteers.filter(v => v._id !== id));
      })
      .catch(err => console.error('Error approving volunteer', err));
  };

  return (
    <Container className="my-4">
      <h2>Pending Volunteers</h2>
      {loading ? (
        <div className="text-center my-5">
          <Spinner animation="border" />
        </div>
      ) : (
        volunteers.length > 0 ? (
          <Table striped bordered hover>
            <thead>
              <tr>
                <th>Username</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {volunteers.map(vol => (
                <tr key={vol._id}>
                  <td>{vol.username || 'N/A'}</td>
                  <td>{vol.email || 'N/A'}</td>
                  <td>{vol.phone || 'N/A'}</td>
                  <td>
                    <Button
                      variant="success"
                      onClick={() => approveVolunteer(vol._id)}
                    >
                      Approve
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </Table>
        ) : <p>No pending volunteers.</p>
      )}
    </Container>
  );
};

export default Volunteers;
