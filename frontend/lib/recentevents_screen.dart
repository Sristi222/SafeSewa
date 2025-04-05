import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './model/event_model.dart';
import 'package:intl/intl.dart';
import 'eventdetails_screen.dart';

class RecentEventsScreen extends StatefulWidget {
  final String userId;
  const RecentEventsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _RecentEventsScreenState createState() => _RecentEventsScreenState();
}

class _RecentEventsScreenState extends State<RecentEventsScreen> {
  List<Event> recentEvents = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  
  // Define our blue color scheme (matching the other screens)
  final Color primaryBlue = const Color(0xFF2196F3);
  final Color lightBlue = const Color(0xFFBBDEFB);
  final Color darkBlue = const Color(0xFF1565C0);
  final Color accentBlue = const Color(0xFF03A9F4);
  
  final String baseUrl = 'http://192.168.1.8:3000';

  @override
  void initState() {
    super.initState();
    fetchRecentEvents();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> fetchRecentEvents() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/events/volunteer/${widget.userId}'),
      );
      
      if (res.statusCode == 200) {
        final List decoded = json.decode(res.body);
        setState(() {
          recentEvents = decoded.map((e) => Event.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = "Error fetching events: ${res.statusCode}";
        });
        _showErrorSnackBar("Error fetching events: ${res.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = "Error: $e";
      });
      _showErrorSnackBar("Error: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "My Enrolled Events",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchRecentEvents,
            tooltip: 'Refresh',
          )
        ],
      ),
      body: isLoading
          ? _buildLoadingState()
          : hasError
              ? _buildErrorState()
              : RefreshIndicator(
                  color: primaryBlue,
                  onRefresh: fetchRecentEvents,
                  child: recentEvents.isEmpty
                      ? _buildEmptyState()
                      : _buildEventsList(),
                ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your events...',
            style: TextStyle(
              color: darkBlue,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 70, color: lightBlue),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: fetchRecentEvents,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.event_busy,
          size: 100,
          color: lightBlue,
        ),
        const SizedBox(height: 24),
        Text(
          "No Events Yet",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          "You haven't enrolled in any events yet. Browse available events and join one!",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context); // Navigate back to the events list
          },
          icon: const Icon(Icons.search),
          label: const Text('Find Events'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: recentEvents.length,
      itemBuilder: (context, index) {
        final event = recentEvents[index];
        final imageUrl = event.image.isNotEmpty
            ? '$baseUrl${event.image}'
            : 'https://via.placeholder.com/100x100.png?text=No+Image';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailsScreen(
                    eventId: event.id,
                    userId: widget.userId,
                  ),
                ),
              ).then((_) => fetchRecentEvents()); // Refresh after returning
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'event-${event.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: lightBlue.withOpacity(0.3),
                          child: Icon(Icons.image, color: primaryBlue.withOpacity(0.7)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: primaryBlue),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(event.date),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: primaryBlue),
                            const SizedBox(width: 4),
                            Text(
                              event.time,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: primaryBlue),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: lightBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}