const express = require("express");
const multer = require("multer");
const router = express.Router();
const DisasterPrecaution = require("../model/disasterprecaution"); // ✅ Adjust path as needed

// Setup multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename: (req, file, cb) =>
    cb(null, Date.now() + "-" + file.originalname),
});
const upload = multer({ storage });

/**
 * ✅ GET all precautions
 */
router.get("/", async (req, res) => {
  try {
    const all = await DisasterPrecaution.find().sort({ createdAt: -1 });
    res.json(all);
  } catch (err) {
    res.status(500).json({ error: "Server error", details: err.message });
  }
});

/**
 * ✅ POST precaution with image upload
 */
router.post("/", upload.single("image"), async (req, res) => {
  try {
    const { title, precaution, response } = req.body;
    const image = req.file ? req.file.filename : "default.png";

    const newPrecaution = new DisasterPrecaution({
      title,
      precaution,
      response,
      image,
    });

    await newPrecaution.save();
    res.status(201).json({ message: "Precaution added", data: newPrecaution });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * ✅ PUT update precaution (without reuploading image)
 */
// UPDATE with image support
router.put("/:id", upload.single("image"), async (req, res) => {
  try {
    const { title, precaution, response } = req.body;
    const updatedData = {
      title,
      precaution,
      response,
    };

    if (req.file) {
      updatedData.image = req.file.filename;
    }

    const updated = await DisasterPrecaution.findByIdAndUpdate(
      req.params.id,
      updatedData,
      { new: true }
    );

    res.json({ message: "Updated", data: updated });
  } catch (err) {
    res.status(500).json({ error: "Update failed", details: err.message });
  }
});


/**
 * ✅ DELETE precaution
 */
router.delete("/:id", async (req, res) => {
  try {
    await DisasterPrecaution.findByIdAndDelete(req.params.id);
    res.json({ message: "Deleted" });
  } catch (err) {
    res.status(500).json({ error: "Delete failed", details: err.message });
  }
});

module.exports = router;
