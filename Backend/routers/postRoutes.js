const express = require('express');
const multer = require('multer');
const path = require('path');
const Post = require('../model/post'); // Updated schema with image, likes, replies

const router = express.Router();

// 🔧 Image Upload Setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // Make sure this folder exists
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage });

/* -------------------- 1️⃣ CREATE A POST -------------------- */
router.post('/', async (req, res) => {
  try {
    const { userId, username, content } = req.body;

    const post = new Post({
      userId,
      username,
      content,
      createdAt: new Date().toISOString(),
    });

    await post.save();
    res.status(201).json(post);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

/* -------------------- 1B️⃣ CREATE POST WITH IMAGE -------------------- */
router.post('/image', upload.single('image'), async (req, res) => {
  try {
    const { userId, username, content, timestamp } = req.body;

    const newPost = new Post({
      userId,
      username,
      content,
      image: req.file.filename,
      createdAt: timestamp || new Date().toISOString(),
    });

    await newPost.save();
    res.status(201).json(newPost);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Failed to create post with image' });
  }
});

/* -------------------- 2️⃣ GET ALL POSTS WITH FULL IMAGE URL -------------------- */
router.get('/', async (req, res) => {
  try {
    const posts = await Post.find().sort({ createdAt: -1 });

    const baseUrl = `${req.protocol}://${req.get('host')}`;

    const postsWithUrls = posts.map((post) => ({
      ...post.toObject(),
      image: post.image ? `${baseUrl}/uploads/${post.image}` : null,
    }));

    res.status(200).json(postsWithUrls);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* -------------------- 3️⃣ GET A SINGLE POST BY ID -------------------- */
router.get('/:id', async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    if (!post) return res.status(404).json({ error: 'Post not found' });

    const baseUrl = `${req.protocol}://${req.get('host')}`;
    const fullPost = {
      ...post.toObject(),
      image: post.image ? `${baseUrl}/uploads/${post.image}` : null,
    };

    res.status(200).json(fullPost);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* -------------------- 4️⃣ UPDATE A POST -------------------- */
router.put('/:id', async (req, res) => {
  try {
    const updatedData = {
      ...req.body,
      updatedAt: new Date().toISOString(),
    };

    const post = await Post.findByIdAndUpdate(req.params.id, updatedData, { new: true });
    if (!post) return res.status(404).json({ error: 'Post not found' });

    res.status(200).json(post);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* -------------------- 5️⃣ DELETE A POST -------------------- */
router.delete('/:id', async (req, res) => {
  try {
    const post = await Post.findByIdAndDelete(req.params.id);
    if (!post) return res.status(404).json({ error: 'Post not found' });

    res.status(200).json({ message: 'Post deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/* -------------------- 6️⃣ LIKE A POST -------------------- */
router.post('/:id/like', async (req, res) => {
  try {
    await Post.findByIdAndUpdate(req.params.id, { $inc: { likes: 1 } });
    res.sendStatus(200);
  } catch (err) {
    res.status(500).json({ message: 'Failed to like post' });
  }
});

/* -------------------- 7️⃣ REPLY TO A POST -------------------- */
router.post('/:id/reply', async (req, res) => {
  const { message, username } = req.body;

  try {
    const post = await Post.findById(req.params.id);
    if (!post) return res.status(404).json({ message: 'Post not found' });

    post.replies.push({ message, username });
    await post.save();

    res.status(200).json(post);
  } catch (err) {
    res.status(500).json({ message: 'Failed to reply to post' });
  }
});

module.exports = router;
