const express = require("express");
const router = express.Router();
const { User } = require("../model/user.model");
const UserController = require("../controller/user.controller"); // Ensure this path is correct


// ✅ User Authentication Routes
router.post("/registration", UserController.register);
router.post("/login", UserController.login);

// ✅ Volunteer Management Routes
router.get("/volunteers", UserController.getVolunteers);
router.get("/volunteers/pending", UserController.getPendingVolunteers);
router.put("/volunteers/approve/:id", UserController.approveVolunteer);
router.put("/admin/approve/:id", UserController.approveVolunteer);

// Admin: Get all users
router.get("/users", UserController.getAllUsers);

// Node.js (Express)
router.get('/users/:id', async (req, res) => {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  });

// routes/auth.js
router.post('/reset-password-direct', async (req, res) => {
  const { email, phone, newPassword } = req.body;

  if (!email || !phone || !newPassword) {
    return res.status(400).json({ status: 'fail', message: 'All fields are required' });
  }

  try {
    const user = await User.findOne({ email, phone });

    if (!user) {
      return res.status(404).json({ status: 'fail', message: 'User not found with matching email and phone' });
    }

    user.password = newPassword; // 🔐 hash this in production!
    await user.save();

    return res.json({ status: 'success', message: 'Password successfully updated' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ status: 'fail', message: 'Server error' });
  }
});

  

module.exports = router;
