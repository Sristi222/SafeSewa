import React, { useState } from 'react';
import axios from 'axios';

const AddEvent = () => {
  const [formData, setFormData] = useState({
    title: '',
    organization: '',
    image: '',
    location: '',
    date: '',
    time: '',
    spots: '',
    description: '',
  });

  const handleChange = (e) => {
    setFormData({...formData, [e.target.name]: e.target.value});
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.post('http://localhost:3000/api/events', formData);
      alert('Event added successfully!');
      setFormData({
        title: '',
        organization: '',
        image: '',
        location: '',
        date: '',
        time: '',
        spots: '',
        description: '',
      });
    } catch (error) {
      console.error(error);
      alert('Error adding event');
    }
  };

  return (
    <div className="container mt-5">
      <h2>Add New Event</h2>
      <form onSubmit={handleSubmit}>
        <input type="text" name="title" placeholder="Event Title" className="form-control my-2" value={formData.title} onChange={handleChange} required />
        <input type="text" name="organization" placeholder="Organization Name" className="form-control my-2" value={formData.organization} onChange={handleChange} required />
        <input type="text" name="image" placeholder="Image URL" className="form-control my-2" value={formData.image} onChange={handleChange} />
        <input type="text" name="location" placeholder="Location" className="form-control my-2" value={formData.location} onChange={handleChange} required />
        <input type="date" name="date" className="form-control my-2" value={formData.date} onChange={handleChange} required />
        <input type="time" name="time" className="form-control my-2" value={formData.time} onChange={handleChange} required />
        <input type="number" name="spots" placeholder="Available Spots" className="form-control my-2" value={formData.spots} onChange={handleChange} required />
        <textarea name="description" placeholder="Event Description" className="form-control my-2" value={formData.description} onChange={handleChange} required></textarea>
        <button type="submit" className="btn btn-primary">Add Event</button>
      </form>
    </div>
  );
};

export default AddEvent;
