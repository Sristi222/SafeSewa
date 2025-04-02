import React, { useState, useEffect } from "react";
import {
  Container,
  Table,
  Button,
  Modal,
  Form,
  Row,
  Col,
} from "react-bootstrap";
import axios from "axios";

const API = "http://localhost:3000"; // Change IP if needed

const HelplineAdmin = () => {
  const [helplines, setHelplines] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({
    title: "",
    number: "",
  });

  useEffect(() => {
    fetchHelplines();
  }, []);

  const fetchHelplines = async () => {
    const res = await axios.get(`${API}/api/helplines`);
    setHelplines(res.data);
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editing) {
        await axios.put(`${API}/api/helplines/${editing._id}`, form);
      } else {
        await axios.post(`${API}/api/helplines`, form);
      }
      fetchHelplines();
      handleClose();
    } catch (err) {
      console.error("Error submitting form:", err);
    }
  };

  const handleEdit = (item) => {
    setEditing(item);
    setForm({ title: item.title, number: item.number });
    setShowModal(true);
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure you want to delete this helpline?")) return;
    await axios.delete(`${API}/api/helplines/${id}`);
    fetchHelplines();
  };

  const handleClose = () => {
    setShowModal(false);
    setEditing(null);
    setForm({ title: "", number: "" });
  };

  return (
    <Container className="my-4">
      <h2>📞 Emergency Helpline Manager</h2>
      <Button variant="success" className="mb-3" onClick={() => setShowModal(true)}>
        ➕ Add Helpline
      </Button>

      <Table striped bordered hover>
        <thead>
          <tr>
            <th>Service Name</th>
            <th>Contact Number</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {helplines.map((item) => (
            <tr key={item._id}>
              <td>{item.title}</td>
              <td>{item.number}</td>
              <td>
                <Button size="sm" variant="primary" onClick={() => handleEdit(item)}>✏️ Edit</Button>{' '}
                <Button size="sm" variant="danger" onClick={() => handleDelete(item._id)}>🗑 Delete</Button>
              </td>
            </tr>
          ))}
        </tbody>
      </Table>

      {/* Modal Form */}
      <Modal show={showModal} onHide={handleClose}>
        <Form onSubmit={handleSubmit}>
          <Modal.Header closeButton>
            <Modal.Title>{editing ? "Edit Helpline" : "Add Helpline"}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <Form.Group className="mb-3">
              <Form.Label>Service Title</Form.Label>
              <Form.Control
                name="title"
                value={form.title}
                onChange={handleChange}
                required
              />
            </Form.Group>
            <Form.Group>
              <Form.Label>Phone Number</Form.Label>
              <Form.Control
                name="number"
                value={form.number}
                onChange={handleChange}
                required
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

export default HelplineAdmin;

/*{'title': 'Police Emergency', 'number': '100'},
    {'title': 'Ambulance', 'number': '102'},
    {'title': 'Fire Brigade', 'number': '101'},
    {'title': 'Nepal Red Cross', 'number': '4228094'},
    {'title': 'Child Helpline', 'number': '1098'},
    {'title': 'Women Helpline', 'number': '1145'},
    {'title': 'Traffic Police', 'number': '103'},
    {'title': 'Tourist Police', 'number': '1144'},
    {'title': 'Nepal Telecom', 'number': '1498'},
    {'title': 'Electricity Emergency', 'number': '1150'},
    {'title': 'Electricity Emergency', 'number': '9841370926'},*/
