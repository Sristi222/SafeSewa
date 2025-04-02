class DisasterPrecaution {
  final String id;
  final String title;
  final String description;

  DisasterPrecaution({
    required this.id,
    required this.title,
    required this.description,
  });

  factory DisasterPrecaution.fromJson(Map<String, dynamic> json) {
    return DisasterPrecaution(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
    );
  }
}
