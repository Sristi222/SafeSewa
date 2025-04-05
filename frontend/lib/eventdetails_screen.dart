import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './model/event_model.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final dynamic userId;

  const EventDetailsScreen({
    Key? key,
    required this.eventId,
    required this.userId,
  }) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Event? event;
  bool isEnrolled = false;
  bool isLoading = false;
  bool isPageLoading = true;

  // Define our blue color scheme (matching the HomeFeedScreen)
  final Color primaryBlue = const Color(0xFF2196F3);
  final Color lightBlue = const Color(0xFFBBDEFB);
  final Color darkBlue = const Color(0xFF1565C0);
  final Color accentBlue = const Color(0xFF03A9F4);

  final String baseUrl = 'http://192.168.1.8:3000';

  @override
  void initState() {
    super.initState();
    fetchEvent();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> fetchEvent() async {
    setState(() => isPageLoading = true);
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/events/${widget.eventId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final loadedEvent = Event.fromJson(data);

        final enrolledList = data['enrolled'] ?? [];
        final alreadyEnrolled = enrolledList.contains(widget.userId);

        setState(() {
          event = loadedEvent;
          isEnrolled = alreadyEnrolled;
          isPageLoading = false;
        });
      } else {
        setState(() => isPageLoading = false);
        _showErrorSnackBar('Error fetching event: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isPageLoading = false);
      _showErrorSnackBar('Exception in fetchEvent: $e');
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> enrollInEvent() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/events/${widget.eventId}/enroll'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'volunteerId': widget.userId}),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        await fetchEvent();
        _showSuccessSnackBar("You are now enrolled in this event!");
      } else {
        _showErrorSnackBar("Error: ${response.body}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar("Exception: $e");
    }
  }

  Future<void> cancelEnrollment() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/events/${widget.eventId}/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'volunteerId': widget.userId}),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        await fetchEvent();
        _showSuccessSnackBar("Enrollment cancelled");
      } else {
        _showErrorSnackBar("Error: ${response.body}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isPageLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Event Details"),
          backgroundColor: primaryBlue,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading event details...',
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (event == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Event Details"),
          backgroundColor: primaryBlue,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: primaryBlue),
              const SizedBox(height: 16),
              Text(
                'Event not found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: fetchEvent,
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

    final String imageUrl = event!.image.isNotEmpty
        ? '$baseUrl${event!.image}'
        : 'https://via.placeholder.com/300x200.png?text=No+Image';

    final bool isFull = event!.spots <= 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          event!.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality would go here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'event-${widget.eventId}',
              child: Container(
                height: 250,
                width: double.infinity,
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: lightBlue.withOpacity(0.3),
                          alignment: Alignment.center,
                          child: Icon(Icons.image, size: 80, color: primaryBlue.withOpacity(0.7)),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: [0.6, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event!.organization,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.white.withOpacity(0.9), size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event!.location,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
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
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: darkBlue.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "${event!.spots} spot${event!.spots != 1 ? 's' : ''} left",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.calendar_today,
                          title: "Date",
                          value: _formatDate(event!.date),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.access_time,
                          title: "Time",
                          value: event!.time,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "About This Event",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event!.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (isEnrolled)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryBlue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: primaryBlue, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "You're enrolled!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: darkBlue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "You've secured your spot for this event.",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading || (isFull && !isEnrolled)
                          ? null
                          : () {
                              if (isEnrolled) {
                                cancelEnrollment();
                              } else {
                                enrollInEvent();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEnrolled ? Colors.red : primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isEnrolled
                                      ? Icons.cancel
                                      : (isFull ? Icons.error_outline : Icons.check_circle),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isEnrolled
                                      ? "Cancel Enrollment"
                                      : (isFull ? "No Spots Available" : "Enroll Now"),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}