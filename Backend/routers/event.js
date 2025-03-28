const express = require('express');
const router = express.Router();
const Event = require('../model/event');
const { User } = require('../model/user.model'); // Make sure User model is exported properly

// ✅ Create Event (Admin)
router.post('/', async (req, res) => {
  try {
    const event = new Event(req.body);
    await event.save();
    res.status(201).json(event);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// ✅ Get All Events
router.get('/', async (req, res) => {
  try {
    const events = await Event.find();
    res.json(events);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Admin: Get all events with volunteer count (MUST COME BEFORE /:id)
router.get('/admin/summary', async (req, res) => {
  try {
    const events = await Event.find().populate('enrolled', 'username email');

    console.log("✅ Events Fetched:", events); // 👈 Add this

    const eventSummaries = events.map(event => ({
      _id: event._id,
      title: event.title,
      location: event.location,
      date: event.date,
      enrolledCount: event.enrolled.length,
      enrolledVolunteers: event.enrolled,
    }));

    res.json(eventSummaries);
  } catch (err) {
    console.error('🔥 Error in /admin/summary:', err);
    res.status(500).json({ error: err.message });
  }
});


// ✅ Get Enrolled Events for a Volunteer
router.get('/volunteer/:id', async (req, res) => {
  try {
    const volunteer = await User.findOne({
      _id: req.params.id,
      role: 'Volunteer'
    }).populate('enrolledEvents');

    if (!volunteer) {
      console.log('❌ Volunteer not found (or role mismatch)');
      return res.status(404).json({ error: 'Volunteer not found' });
    }

    res.json(volunteer.enrolledEvents || []);
  } catch (err) {
    console.error('🔥 Fetch Enrolled Events Error:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ✅ Get Event Details
router.get('/:id', async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);
    if (!event) return res.status(404).json({ error: 'Event not found' });
    res.json(event);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Enroll Volunteer in Event
router.post('/:id/enroll', async (req, res) => {
  try {
    const { volunteerId } = req.body;
    console.log('➡️ Enroll request for event:', req.params.id);
    console.log('➡️ Volunteer ID:', volunteerId);

    const event = await Event.findById(req.params.id);
    const volunteer = await User.findOne({ _id: volunteerId, role: 'Volunteer' });

    if (!event) {
      console.log('❌ Event not found');
      return res.status(404).json({ error: 'Event not found' });
    }

    if (!volunteer) {
      console.log('❌ Volunteer not found or role mismatch');
      return res.status(404).json({ error: 'Volunteer not found or invalid role' });
    }

    // Add volunteer to event if not already enrolled
    if (!event.enrolled.includes(volunteerId)) {
      event.enrolled.push(volunteerId);
      await event.save();
    }

    // Add event to volunteer's enrolledEvents
    if (!volunteer.enrolledEvents) volunteer.enrolledEvents = [];

    if (!volunteer.enrolledEvents.includes(event._id)) {
      volunteer.enrolledEvents.push(event._id);
      await volunteer.save();
    }

    console.log('✅ Enrolled successfully');
    res.json({ message: 'Enrolled successfully' });

  } catch (err) {
    console.error('🔥 Enroll Error:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
