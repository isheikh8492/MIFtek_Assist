class Procedure {
  static int _nextId = 0;
  int id;
  String title;
  List<String> steps;
  int? topicId; // Add the Topic reference

  Procedure({
    required this.title,
    required this.steps,
    this.topicId, // Require the topic when initializing
  }) : id = _nextId++;

  factory Procedure.fromJson(Map<String, dynamic> json) {
    return Procedure(
      title: json['title'],
      steps: List<String>.from(json['steps']),
      topicId: json['topicId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'steps': steps,
      'topicId': topicId,
    };
  }
}

