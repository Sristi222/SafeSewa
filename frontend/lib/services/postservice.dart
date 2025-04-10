
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PostService {
  static const String apiUrl = 'http://192.168.1.10:3000/posts'; // Replace with your backend URL

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
        throw FormatException("Unexpected JSON format: \$jsonData");
      }
    } else {
      throw Exception("Failed to load posts");
    }
  }

  // Create a Post (text only)
  static Future<void> createPost(String userId, String username, String content, String timestamp) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'username': username,
        'content': content,
        'timestamp': timestamp,
        'likes': 0,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create post');
    }
  }

  // Create a Post with Image
  static Future<void> createPostWithImage(String userId, String username, String content, String timestamp, File imageFile) async {
    var uri = Uri.parse('$apiUrl/image');
    var request = http.MultipartRequest('POST', uri)
      ..fields['userId'] = userId
      ..fields['username'] = username
      ..fields['content'] = content
      ..fields['timestamp'] = timestamp
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();

    if (response.statusCode != 201) {
      throw Exception('Failed to create post with image');
    }
  }

  // Like a Post
  static Future<void> likePost(String postId) async {
    final response = await http.post(
      Uri.parse('$apiUrl/$postId/like'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to like post');
    }
  }

  // Reply to a Post
  static Future<void> replyToPost(String postId, String message) async {
    final response = await http.post(
      Uri.parse('$apiUrl/$postId/reply'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reply to post');
    }
  }

  // Update a Post
  static Future<void> updatePost(String postId, String updatedContent) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$postId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': updatedContent}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update post');
    }
  }

  // Delete a Post
  static Future<void> deletePost(String postId) async {
    final response = await http.delete(Uri.parse('$apiUrl/$postId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post');
    }
  }
}
