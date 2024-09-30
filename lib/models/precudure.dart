class Procedure {
  String? id; // Use String for ID, since Firestore document IDs are strings
  String title;
  List<String> steps;
  String? topicId; // Reference to the related Topic, now a String
  String createdBy;
  bool isPersonal;

  Procedure({
    this.id,
    required this.title,
    required this.steps,
    this.topicId,
    required this.createdBy,
    required this.isPersonal,
  });

  // Factory constructor for JSON deserialization
  factory Procedure.fromJson(Map<String, dynamic> json, String id) {
    return Procedure(
      id: id, // Use the Firestore document ID as the procedure ID
      title: json['title'],
      steps: List<String>.from(json['steps']),
      topicId: json['topicId'],
      createdBy: json['createdBy'],
      isPersonal: json['isPersonal'],
    );
  }

  // Convert a Procedure object to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'steps': steps,
      'topicId': topicId,
      'createdBy': createdBy,
      'isPersonal': isPersonal,
    };
  }

  Procedure deepCopy(String currentUserId) {
    return Procedure(
      title: title,
      steps: List<String>.from(steps), // Create a new list for steps
      topicId: null,
      createdBy: currentUserId,
      isPersonal: true
    );
  }

  @override
  String toString() {
    return 'Procedure{id: $id, title: $title, steps: $steps, topicId: $topicId, createdBy: $createdBy, isPersonal: $isPersonal}';
  }
}

