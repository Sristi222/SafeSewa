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

module.exports = router;
