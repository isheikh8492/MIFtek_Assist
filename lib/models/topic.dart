class Topic {
  String id; // Use String for ID, since Firestore document IDs are strings
  String title;
  String createdBy;

  Topic({
    required this.id,
    required this.title,
    required this.createdBy,
  });

  // Factory constructor for JSON deserialization
  factory Topic.fromJson(Map<String, dynamic> json, String id) {
    return Topic(
      id: id, // Use the Firestore document ID as the topic ID
      title: json['title'],
      createdBy: json['createdBy'],
    );
  }

  // Convert a Topic object to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'createdBy': createdBy,
    };
  }
}
