// EventSummary.jsx with Modal Add/Edit Support
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import {
  Container, Table, Button, Modal, Form, Row, Col, Alert
} from 'react-bootstrap';

const EventSummary = () => {
  const [events, setEvents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;

  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({
    title: '', organization: '', location: '', date: '', time: '', spots: '', description: '', image: null,
  });
  const [imagePreview, setImagePreview] = useState(null);
  const [message, setMessage] = useState('');

  useEffect(() => {
    fetchEvents();
  }, []);

  const fetchEvents = async () => {
    try {
      setLoading(true);
      const res = await axios.get('http://localhost:3000/api/events/admin/summary');
      setEvents(res.data);
      setLoading(false);
    } catch (err) {
      console.error("❌ Error fetching summary:", err.message);
      setError('Failed to load event summary');
      setLoading(false);
    }
  };

  const deleteEvent = async (eventId) => {
    const confirm = window.confirm('Are you sure you want to delete this event? This cannot be undone.');
    if (!confirm) return;

    try {
      const res = await axios.delete(`http://localhost:3000/api/events/${eventId}`);
      if (res.status === 200) {
        alert("✅ Event deleted successfully");
        fetchEvents();
      } else {
        alert("❌ Failed to delete event");
      }
    } catch (err) {
      console.error('❌ Failed to delete event:', err);
      alert('Failed to delete event');
    }
  };

  const handleEdit = (event) => {
    setEditing(event);
    setForm({
      title: event.title,
      organization: event.organization,
      location: event.location,
      date: event.date,
      time: event.time,
      spots: event.spots,
      description: event.description,
      image: null,
    });
    setImagePreview(`http://localhost:3000${event.image}`);
    setShowModal(true);
  };

  const handleAdd = () => {
    setEditing(null);
    setForm({ title: '', organization: '', location: '', date: '', time: '', spots: '', description: '', image: null });
    setImagePreview(null);
    setShowModal(true);
  };

  const handleChange = (e) => {
    const { name, value, files } = e.target;
    if (files) {
      setForm({ ...form, image: files[0] });
      setImagePreview(URL.createObjectURL(files[0]));
    } else {
      setForm({ ...form, [name]: value });
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const data = new FormData();
    Object.keys(form).forEach(key => {
      if (form[key]) data.append(key, form[key]);
    });

    try {
      if (editing) {
        await axios.put(`http://localhost:3000/api/events/${editing._id}`, data);
        setMessage("✅ Event updated successfully!");
      } else {
        await axios.post('http://localhost:3000/api/events', data);
        setMessage("✅ Event added successfully!");
      }
      fetchEvents();
      handleClose();
    } catch (error) {
      console.error(error);
      setMessage("❌ Failed to save event");
    }
  };

  const handleClose = () => {
    setShowModal(false);
    setEditing(null);
    setMessage('');
  };

  const filteredEvents = events.filter(event =>
    event.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    event.location.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentItems = filteredEvents.slice(indexOfFirstItem, indexOfLastItem);
  const totalPages = Math.ceil(filteredEvents.length / itemsPerPage);

  if (loading) return <p>⏳ Loading event summary...</p>;
  if (error) return <p style={{ color: 'red' }}>{error}</p>;

  return (
    <Container className="mt-4">
      <h2>📋 Event Summary</h2>
      <Button variant="success" className="mb-3" onClick={handleAdd}>➕ Add New Event</Button>

      <input
        type="text"
        className="form-control mb-3"
        placeholder="🔍 Search by title or location..."
        value={searchTerm}
        onChange={e => setSearchTerm(e.target.value)}
        style={{ maxWidth: '300px' }}
      />

      <Table bordered striped hover>
        <thead className="table-dark">
          <tr>
            <th>Title</th>
            <th>Location</th>
            <th>Date</th>
            <th>Enrolled</th>
            <th>Volunteers</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {currentItems.map(event => (
            <tr key={event._id}>
              <td>{event.title}</td>
              <td>{event.location}</td>
              <td>{event.date}</td>
              <td>{event.enrolledCount}</td>
              <td>
                <ul className="mb-0">
                  {event.enrolledVolunteers.length === 0 ? (
                    <li>No one enrolled</li>
                  ) : (
                    event.enrolledVolunteers.map(v => (
                      <li key={v._id}>{v.username} ({v.email})</li>
                    ))
                  )}
                </ul>
              </td>
              <td>
                <Button className="btn-sm me-2" onClick={() => handleEdit(event)}>✏ Edit</Button>
                <Button variant="danger" className="btn-sm" onClick={() => deleteEvent(event._id)}>🗑 Delete</Button>
              </td>
            </tr>
          ))}
        </tbody>
      </Table>

      <div className="d-flex justify-content-center mt-3">
        {Array.from({ length: totalPages }, (_, i) => i + 1).map(page => (
          <Button
            key={page}
            onClick={() => setCurrentPage(page)}
            className={`btn-sm mx-1 ${currentPage === page ? 'btn-primary text-white' : 'btn-outline-secondary'}`}
          >
            {page}
          </Button>
        ))}
      </div>

      {/* Modal */}
      <Modal show={showModal} onHide={handleClose} size="lg">
        <Form onSubmit={handleSubmit} encType="multipart/form-data">
          <Modal.Header closeButton>
            <Modal.Title>{editing ? "Edit Event" : "Add Event"}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            {message && <Alert variant="info">{message}</Alert>}
            <Form.Group className="mb-3">
              <Form.Label>Title</Form.Label>
              <Form.Control name="title" value={form.title} onChange={handleChange} required />
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Organization</Form.Label>
              <Form.Control name="organization" value={form.organization} onChange={handleChange} required />
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Location</Form.Label>
              <Form.Control name="location" value={form.location} onChange={handleChange} required />
            </Form.Group>

            <Row className="mb-3">
              <Col>
                <Form.Label>Date</Form.Label>
                <Form.Control type="date" name="date" value={form.date} onChange={handleChange} required />
              </Col>
              <Col>
                <Form.Label>Time</Form.Label>
                <Form.Control type="time" name="time" value={form.time} onChange={handleChange} required />
              </Col>
            </Row>

            <Form.Group className="mb-3">
              <Form.Label>Available Spots</Form.Label>
              <Form.Control type="number" name="spots" value={form.spots} onChange={handleChange} required />
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Description</Form.Label>
              <Form.Control as="textarea" rows={3} name="description" value={form.description} onChange={handleChange} required />
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Upload Image</Form.Label>
              <Form.Control type="file" name="image" onChange={handleChange} />
              {imagePreview && (
                <img src={imagePreview} alt="Preview" className="img-fluid mt-2" style={{ maxHeight: '200px' }} />
              )}
            </Form.Group>
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={handleClose}>Cancel</Button>
            <Button variant="success" type="submit">{editing ? "Update" : "Add"}</Button>
          </Modal.Footer>
        </Form>
      </Modal>
    </Container>
  );
};

export default EventSummary;
