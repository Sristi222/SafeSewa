const express = require('express');
const router = express.Router();
const Event = require('../model/event');
const Volunteer = require('../model/volunteer');

// Create Event (Admin)
router.post('/', async (req, res) => {
  try {
    const event = new Event(req.body);
    await event.save();
    res.status(201).json(event);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get All Events
router.get('/', async (req, res) => {
  const events = await Event.find();
  res.json(events);
});

// Get Event Details
router.get('/:id', async (req, res) => {
  const event = await Event.findById(req.params.id);
  res.json(event);
});

// Enroll Volunteer in Event
router.post('/:id/enroll', async (req, res) => {
  const { volunteerId } = req.body;
  const event = await Event.findById(req.params.id);
  const volunteer = await Volunteer.findById(volunteerId);

  if (!event || !volunteer) return res.status(404).json({ error: 'Not found' });

  if (!event.enrolled.includes(volunteerId)) {
    event.enrolled.push(volunteerId);
    volunteer.enrolledEvents.push(event._id);
    await event.save();
    await volunteer.save();
  }

  res.json({ message: 'Enrolled successfully' });
});

// Get Enrolled Events for a Volunteer
router.get('/volunteer/:id', async (req, res) => {
  const volunteer = await Volunteer.findById(req.params.id).populate('enrolledEvents');
  if (!volunteer) return res.status(404).json({ error: 'Volunteer not found' });
  res.json(volunteer.enrolledEvents);
});

module.exports = router;
