const express = require('express');
const router = express.Router();
const Post = require('../model/post');

// **1️⃣ CREATE A POST (Now includes timestamp)**
router.post('/', async (req, res) => {
    try {
        const { username, content } = req.body;
        
        const post = new Post({
            username,
            content,
            createdAt: new Date().toISOString(), // Store timestamp in ISO format
        });

        await post.save();
        res.status(201).json(post);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// **2️⃣ GET ALL POSTS (Ensure timestamps are returned properly)**
router.get('/', async (req, res) => {
    try {
        const posts = await Post.find().sort({ createdAt: -1 }); // Sort by latest
        res.status(200).json(posts);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// **3️⃣ GET A SINGLE POST BY ID**
router.get('/:id', async (req, res) => {
    try {
        const post = await Post.findById(req.params.id);
        if (!post) return res.status(404).json({ error: 'Post not found' });

        res.status(200).json(post);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// **4️⃣ UPDATE A POST**
router.put('/:id', async (req, res) => {
    try {
        const updatedData = {
            ...req.body,
            updatedAt: new Date().toISOString(), // Store update timestamp
        };

        const post = await Post.findByIdAndUpdate(req.params.id, updatedData, { new: true });
        if (!post) return res.status(404).json({ error: 'Post not found' });

        res.status(200).json(post);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// **5️⃣ DELETE A POST**
router.delete('/:id', async (req, res) => {
    try {
        const post = await Post.findByIdAndDelete(req.params.id);
        if (!post) return res.status(404).json({ error: 'Post not found' });

        res.status(200).json({ message: 'Post deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
