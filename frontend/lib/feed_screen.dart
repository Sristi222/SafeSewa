import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/postservice.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<dynamic>> posts;
  String profileName = "John Doe";
  final TextEditingController _tweetController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadProfileName();
    posts = PostService.fetchPosts();
  }

  Future<void> _loadProfileName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profileName = prefs.getString('profile_name') ?? "John Doe";
    });
  }

  Future<void> refreshPosts() async {
    List<dynamic> updatedPosts = await PostService.fetchPosts();
    setState(() {
      posts = Future.value(updatedPosts);
    });
  }

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

  void _addNewPost() {
    TextEditingController contentController = TextEditingController();
    _selectedImage = null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Create Post'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: contentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedImage != null)
                    Image.file(File(_selectedImage!.path), height: 100),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await _picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setModalState(() => _selectedImage = picked);
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("Add Image"),
                  ),
                ],
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
                      if (_selectedImage != null) {
                        await PostService.createPostWithImage(
                          '123', profileName, contentController.text, timestamp, File(_selectedImage!.path),
                        );
                      } else {
                        await PostService.createPost(
                          '123', profileName, contentController.text, timestamp,
                        );
                      }
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
      },
    );
  }

  void _editPost(String postId, String oldContent) {
    TextEditingController editController = TextEditingController(text: oldContent);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
  }

  void _deletePost(String postId) async {
    await PostService.deletePost(postId);
    refreshPosts();
  }

  void _likePost(String postId) async {
    await PostService.likePost(postId);
    refreshPosts();
  }

  void _replyToPost(String postId) {
    TextEditingController replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reply"),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(hintText: "Write your reply..."),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (replyController.text.isNotEmpty) {
                await PostService.replyToPost(postId, replyController.text);
                Navigator.pop(context);
                refreshPosts();
              }
            },
            child: const Text("Reply"),
          ),
        ],
      ),
    );
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
                              child: Text(post['username'][0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post['username'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text("Posted on: ${formatTimestamp(post['createdAt'])}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                              itemBuilder: (context) {
                                List<PopupMenuEntry<String>> items = [
                                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                ];
                                if (post['username'] == profileName) {
                                  items.add(const PopupMenuItem(value: 'delete', child: Text('Delete')));
                                }
                                return items;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(post['content'], maxLines: 5, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15)),

                        if (post['image'] != null && post['image'].toString().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              post['image'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text("Failed to load image");
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.favorite_border, color: Colors.red),
                                  onPressed: () => _likePost(post['_id']),
                                ),
                                Text("${post['likes'] ?? 0}"),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => _replyToPost(post['_id']),
                              child: const Row(
                                children: [
                                  Icon(Icons.comment, color: Colors.blueAccent),
                                  SizedBox(width: 5),
                                  Text("Reply"),
                                ],
                              ),
                            ),
                          ],
                        ),

                        if (post['replies'] != null && post['replies'] is List && post['replies'].isNotEmpty) ...[
                          const Divider(height: 20),
                          const Text("Replies:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          ...post['replies'].map<Widget>((reply) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.reply, size: 18, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(color: Colors.black87),
                                        children: [
                                          TextSpan(
                                            text: "${reply['username'] ?? 'Anonymous'}: ",
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: reply['message'] ?? '',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
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
