import React, { useEffect, useState } from 'react';
import axios from 'axios';
import {
  Container, Table, Button, Modal, Form, Row, Col
} from 'react-bootstrap';

const API = "http://localhost:3000"; // Change to your backend IP if needed

const DisasterAdmin = () => {
  const [precautions, setPrecautions] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({
    title: '', precaution: '', response: '', image: null,
  });

  useEffect(() => {
    fetchPrecautions();
  }, []);

  const fetchPrecautions = async () => {
    const res = await axios.get(`${API}/api/precautions`);
    setPrecautions(res.data);
  };

  const handleChange = (e) => {
    const { name, value, files } = e.target;
    setForm(prev => ({
      ...prev,
      [name]: files ? files[0] : value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const data = new FormData();
    data.append('title', form.title);
    data.append('precaution', form.precaution);
    data.append('response', form.response);
    if (form.image) data.append('image', form.image);

    try {
      if (editing) {
        await axios.put(`${API}/api/precautions/${editing._id}`, data);
      } else {
        await axios.post(`${API}/api/precautions`, data);
      }
      fetchPrecautions();
      handleClose();
    } catch (err) {
      console.error("❌ Failed to submit:", err);
    }
  };

  const handleClose = () => {
    setShowModal(false);
    setEditing(null);
    setForm({ title: '', precaution: '', response: '', image: null });
  };

  const handleEdit = (item) => {
    setEditing(item);
    setForm({
      title: item.title,
      precaution: item.precaution,
      response: item.response,
      image: null, // image preview can be added
    });
    setShowModal(true);
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure you want to delete this precaution?")) return;
    await axios.delete(`${API}/api/precautions/${id}`);
    fetchPrecautions();
  };

  return (
    <Container className="my-4">
      <h2>Disaster Precautions (Admin)</h2>
      <Button variant="success" className="mb-3" onClick={() => setShowModal(true)}>
        ➕ Add Precaution
      </Button>
      <Table striped bordered hover responsive>
        <thead>
          <tr>
            <th>Title</th>
            <th>Image</th>
            <th>Precaution</th>
            <th>Response</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {precautions.map((item) => (
            <tr key={item._id}>
              <td>{item.title}</td>
              <td>
                <img
                  src={`${API}/uploads/${item.image}`}
                  alt={item.title}
                  width="80"
                />
              </td>
              <td style={{ whiteSpace: 'pre-wrap' }}>{item.precaution}</td>
              <td style={{ whiteSpace: 'pre-wrap' }}>{item.response}</td>
              <td>
                <Button variant="primary" size="sm" onClick={() => handleEdit(item)}>✏️ Edit</Button>{' '}
                <Button variant="danger" size="sm" onClick={() => handleDelete(item._id)}>🗑 Delete</Button>
              </td>
            </tr>
          ))}
        </tbody>
      </Table>

      {/* ✅ Add/Edit Modal */}
      <Modal show={showModal} onHide={handleClose} size="lg">
        <Form onSubmit={handleSubmit}>
          <Modal.Header closeButton>
            <Modal.Title>{editing ? "Edit Precaution" : "Add Precaution"}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <Row>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>Title</Form.Label>
                  <Form.Control name="title" required value={form.title} onChange={handleChange} />
                </Form.Group>
              </Col>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>Image</Form.Label>
                  <Form.Control type="file" name="image" onChange={handleChange} />
                </Form.Group>
              </Col>
            </Row>
            <Form.Group className="mb-3">
              <Form.Label>Precaution (Before)</Form.Label>
              <Form.Control
                name="precaution"
                as="textarea"
                rows={3}
                required
                value={form.precaution}
                onChange={handleChange}
              />
            </Form.Group>
            <Form.Group>
              <Form.Label>Response (After)</Form.Label>
              <Form.Control
                name="response"
                as="textarea"
                rows={3}
                required
                value={form.response}
                onChange={handleChange}
              />
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

export default DisasterAdmin;
