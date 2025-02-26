import 'dart:convert';
import 'package:http/http.dart' as http;

class PostService {
  static const String apiUrl = 'http://192.168.1.7:3000/posts'; // Replace with your backend URL

  // Fetch Posts
  static Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      
      if (jsonData is List) {
        return jsonData;
      } else if (jsonData is Map && jsonData.containsKey('posts')) {
        return jsonData['posts'];
      } else {
        throw FormatException("Unexpected JSON format: $jsonData");
      }
    } else {
      throw Exception("Failed to load posts");
    }
  }

  // Create a Post
  static Future<void> createPost(String userId, String username, String content, String timestamp) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'username': username,
        'content': content,
        'timestamp': timestamp,
        'likes': 0, // Default likes count
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create post');
    }
  }

  // Update a Post
  static Future<void> updatePost(String postId, String updatedContent) async {
    await http.put(
      Uri.parse('$apiUrl/$postId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': updatedContent}),
    );
  }

  // Delete a Post
  static Future<void> deletePost(String postId) async {
    await http.delete(Uri.parse('$apiUrl/$postId'));
  }
}
