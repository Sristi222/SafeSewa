const express = require('express');
const router = express.Router();
const Event = require('../model/event');
const { User } = require('../model/user.model');
const multer = require('multer');
const path = require('path');

// ✅ Multer setup
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/events/');
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    cb(null, Date.now() + ext);
  },
});
const upload = multer({ storage: storage });

// ✅ POST: Create Event
router.post('/', upload.single('image'), async (req, res) => {
  try {
    const eventData = {
      ...req.body,
      image: req.file ? `/uploads/events/${req.file.filename}` : '',
    };

    const event = new Event(eventData);
    await event.save();
    res.status(201).json(event);
  } catch (err) {
    console.error('🔥 Event Creation Error:', err.message);
    res.status(400).json({ error: err.message });
  }
});

// ✅ GET: All Events
router.get('/', async (req, res) => {
  try {
    const events = await Event.find();
    res.json(events);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ GET: Admin Summary
router.get('/admin/summary', async (req, res) => {
  try {
    const events = await Event.find().populate('enrolled', 'username email');
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

// ✅ GET: Volunteer Enrolled Events
router.get('/volunteer/:id', async (req, res) => {
  try {
    const volunteer = await User.findOne({
      _id: req.params.id,
      role: 'Volunteer',
    }).populate('enrolledEvents');

    if (!volunteer) {
      return res.status(404).json({ error: 'Volunteer not found' });
    }

    res.json(volunteer.enrolledEvents || []);
  } catch (err) {
    console.error('🔥 Fetch Enrolled Events Error:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ✅ POST: Enroll Volunteer with spot decrement
router.post('/:id/enroll', async (req, res) => {
  try {
    const { volunteerId } = req.body;

    const event = await Event.findById(req.params.id);
    const volunteer = await User.findOne({ _id: volunteerId, role: 'Volunteer' });

    if (!event || !volunteer) {
      return res.status(404).json({ error: 'Event or Volunteer not found' });
    }

    if (event.enrolled.includes(volunteerId)) {
      return res.status(400).json({ error: 'Already enrolled' });
    }

    if (event.spots <= 0) {
      return res.status(400).json({ error: 'No spots available' });
    }

    // ✅ Update event and user
    event.enrolled.push(volunteerId);
    event.spots -= 1;
    await event.save();

    if (!volunteer.enrolledEvents) volunteer.enrolledEvents = [];
    if (!volunteer.enrolledEvents.includes(event._id)) {
      volunteer.enrolledEvents.push(event._id);
      await volunteer.save();
    }

    res.json({ message: 'Enrolled successfully', spotsLeft: event.spots });
  } catch (err) {
    console.error('🔥 Enroll Error:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ✅ GET: Event by ID
router.get('/:id', async (req, res) => {
  try {
    const event = await Event.findById(req.params.id).populate('enrolled', '_id');

    if (!event) return res.status(404).json({ error: 'Event not found' });

    const eventData = {
      ...event.toObject(),
      enrolled: event.enrolled.map(user => user._id.toString()),
    };

    res.json(eventData);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ POST: Cancel Enrollment
router.post('/:id/cancel', async (req, res) => {
  try {
    const { volunteerId } = req.body;

    const event = await Event.findById(req.params.id);
    const volunteer = await User.findOne({ _id: volunteerId, role: 'Volunteer' });

    if (!event || !volunteer) {
      return res.status(404).json({ error: 'Event or Volunteer not found' });
    }

    // ✅ Remove volunteer from event.enrolled
    event.enrolled = event.enrolled.filter(
      id => id.toString() !== volunteerId.toString()
    );
    event.spots += 1;
    await event.save();

    // ✅ Remove event from volunteer.enrolledEvents
    volunteer.enrolledEvents = volunteer.enrolledEvents.filter(
      id => id.toString() !== event._id.toString()
    );
    await volunteer.save();

    res.json({ message: 'Enrollment cancelled successfully', spotsLeft: event.spots });
  } catch (err) {
    console.error('🔥 Cancel Enrollment Error:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ✅ DELETE: Delete Event by ID
router.delete('/:id', async (req, res) => {
  try {
    const deleted = await Event.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ error: 'Event not found' });
    res.json({ message: 'Event deleted' });
  } catch (err) {
    console.error("🔥 Delete Event Error:", err.message);
    res.status(500).json({ error: err.message });
  }
});

// ✅ PUT: Update Event
router.put('/:id', upload.single('image'), async (req, res) => {
  try {
    const updatedFields = {
      title: req.body.title,
      organization: req.body.organization,
      location: req.body.location,
      date: req.body.date,
      time: req.body.time,
      spots: req.body.spots,
      description: req.body.description,
    };

    if (req.file) {
      updatedFields.image = `/uploads/events/${req.file.filename}`;
    }

    const updatedEvent = await Event.findByIdAndUpdate(req.params.id, updatedFields, {
      new: true,
    });

    if (!updatedEvent) return res.status(404).json({ error: 'Event not found' });

    res.json(updatedEvent);
  } catch (err) {
    console.error('❌ Event update error:', err.message);
    res.status(500).json({ error: 'Failed to update event' });
  }
});


module.exports = router;
