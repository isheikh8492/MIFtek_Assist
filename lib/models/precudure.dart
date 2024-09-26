class Procedure {
  String title;
  List<String> steps;

  Procedure({
    required this.title,
    required this.steps,
  });

  factory Procedure.fromJson(Map<String, dynamic> json) {
    return Procedure(
      title: json['title'],
      steps: List<String>.from(json['steps']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'steps': steps,
    };
  }
}

class Topic {
  static int _nextId = 0;
  int id;
  String title;

  Topic({
    required this.title,
  }) : id = _nextId++;

  factory Topic.fromJson(String jsonTitle) {
    return Topic(title: jsonTitle);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}
