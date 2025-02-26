import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/postservice.dart';
import 'package:intl/intl.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<dynamic>> posts;
  String profileName = "John Doe"; // Default Profile Name
  final TextEditingController _tweetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileName();
    posts = PostService.fetchPosts(); // Fetch Posts
  }

  // Load Profile Name from SharedPreferences
  Future<void> _loadProfileName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profileName = prefs.getString('profile_name') ?? "John Doe";
    });
  }

  // Refresh Posts
  Future<void> refreshPosts() async {
    List<dynamic> updatedPosts = await PostService.fetchPosts();
    setState(() {
      posts = Future.value(updatedPosts);
    });
  }

  // Format timestamp for better readability
  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null || timestamp.toString().isEmpty) return "No Date";

    try {
      DateTime dateTime;
      
      if (timestamp is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return "Invalid Date";
      }

      return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }

  // Add a New Post with Timestamp
  void _addNewPost() {
    TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Create Post'),
          content: TextField(
            controller: contentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "What's on your mind?",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  String timestamp = DateTime.now().toIso8601String();

                  await PostService.createPost(
                    '123', // Replace with actual user ID
                    profileName,
                    contentController.text,
                    timestamp,
                  );

                  Navigator.pop(context);
                  refreshPosts();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text('Post', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Edit a Post
  void _editPost(String postId, String oldContent) {
    TextEditingController editController = TextEditingController(text: oldContent);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Edit Post'),
          content: TextField(
            controller: editController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Edit your post",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (editController.text.isNotEmpty) {
                  await PostService.updatePost(postId, editController.text);
                  Navigator.pop(context);
                  refreshPosts();
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Delete a Post
  void _deletePost(String postId) async {
    await PostService.deletePost(postId);
    refreshPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Feed"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts available.'));
          }

          final posts = snapshot.data!;
          return RefreshIndicator(
            onRefresh: refreshPosts,
            child: ListView.builder(
              itemCount: posts.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final post = posts[index];

                if (post is! Map || !post.containsKey('username') || !post.containsKey('content')) {
                  return const SizedBox();
                }

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                post['username'][0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['username'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Posted on: ${formatTimestamp(post['createdAt'])}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editPost(post['_id'], post['content']);
                                } else if (value == 'delete') {
                                  _deletePost(post['_id']);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          post['content'],
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.favorite_border, color: Colors.red),
                                const SizedBox(width: 5),
                                Text("${post['likes'] ?? 0}"),
                              ],
                            ),
                            const Row(
                              children: [
                                Icon(Icons.comment, color: Colors.blueAccent),
                                SizedBox(width: 5),
                                Text("Reply"),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPost,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
