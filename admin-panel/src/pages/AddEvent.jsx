import React, { useState } from 'react';
import axios from 'axios';

const AddEvent = () => {
  const [formData, setFormData] = useState({
    title: '',
    organization: '',
    location: '',
    date: '',
    time: '',
    spots: '',
    description: '',
  });

  const [imageFile, setImageFile] = useState(null);
  const [imagePreview, setImagePreview] = useState(null);

  const handleChange = (e) => {
    setFormData({...formData, [e.target.name]: e.target.value});
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setImageFile(file);
      setImagePreview(URL.createObjectURL(file));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const data = new FormData();
    Object.keys(formData).forEach(key => {
      data.append(key, formData[key]);
    });
    if (imageFile) {
      data.append('image', imageFile);
    }

    try {
      await axios.post('http://localhost:3000/api/events', data, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      alert('Event added successfully!');
      setFormData({
        title: '',
        organization: '',
        location: '',
        date: '',
        time: '',
        spots: '',
        description: '',
      });
      setImageFile(null);
      setImagePreview(null);
    } catch (error) {
      console.error(error);
      alert('Error adding event');
    }
  };

  return (
    <div className="container mt-5">
      <div className="card shadow p-4">
        <h2 className="mb-4">Add New Event</h2>
        <form onSubmit={handleSubmit}>
          <div className="form-group mb-3">
            <input type="text" name="title" placeholder="Event Title" className="form-control" value={formData.title} onChange={handleChange} required />
          </div>
          <div className="form-group mb-3">
            <input type="text" name="organization" placeholder="Organization Name" className="form-control" value={formData.organization} onChange={handleChange} required />
          </div>
          <div className="form-group mb-3">
            <label>Upload Event Image:</label>
            <input type="file" accept="image/*" className="form-control" onChange={handleImageChange} />
            {imagePreview && (
              <img src={imagePreview} alt="Preview" className="img-fluid mt-2" style={{ maxHeight: '200px' }} />
            )}
          </div>
          <div className="form-group mb-3">
            <input type="text" name="location" placeholder="Location" className="form-control" value={formData.location} onChange={handleChange} required />
          </div>
          <div className="row">
            <div className="col-md-6 mb-3">
              <input type="date" name="date" className="form-control" value={formData.date} onChange={handleChange} required />
            </div>
            <div className="col-md-6 mb-3">
              <input type="time" name="time" className="form-control" value={formData.time} onChange={handleChange} required />
            </div>
          </div>
          <div className="form-group mb-3">
            <input type="number" name="spots" placeholder="Available Spots" className="form-control" value={formData.spots} onChange={handleChange} required />
          </div>
          <div className="form-group mb-4">
            <textarea name="description" placeholder="Event Description" className="form-control" rows="4" value={formData.description} onChange={handleChange} required></textarea>
          </div>
          <button type="submit" className="btn btn-success w-100">Add Event</button>
        </form>
      </div>
    </div>
  );
};

export default AddEvent;
