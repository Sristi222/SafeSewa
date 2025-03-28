class Event {
  // These are the fields your Event will have
  final String id;
  final String title;
  final String organization;
  final String image;
  final String location;
  final String date;
  final String time;
  final int spots;
  final String description;

  // Constructor: creates an Event from given values
  Event({
    required this.id,
    required this.title,
    required this.organization,
    required this.image,
    required this.location,
    required this.date,
    required this.time,
    required this.spots,
    required this.description,
  });

  // Factory method to create an Event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],  // this is how MongoDB sends IDs
      title: json['title'],
      organization: json['organization'],
      image: json['image'],
      location: json['location'],
      date: json['date'],
      time: json['time'],
      spots: json['spots'],
      description: json['description'],
    );
  }
}
