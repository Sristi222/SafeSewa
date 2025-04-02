const express = require("express");
const router = express.Router();
const Helpline = require("../model/Helpline");

// Get all
router.get("/", async (req, res) => {
  const data = await Helpline.find().sort({ createdAt: -1 });
  res.json(data);
});

// Add
router.post("/", async (req, res) => {
  try {
    const { title, number } = req.body;
    const newEntry = new Helpline({ title, number });
    await newEntry.save();
    res.status(201).json(newEntry);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Edit
router.put("/:id", async (req, res) => {
  try {
    const updated = await Helpline.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete
router.delete("/:id", async (req, res) => {
  await Helpline.findByIdAndDelete(req.params.id);
  res.json({ message: "Deleted" });
});

module.exports = router;
