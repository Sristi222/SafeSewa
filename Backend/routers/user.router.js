const express = require("express");
const router = express.Router();
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
  

module.exports = router;
