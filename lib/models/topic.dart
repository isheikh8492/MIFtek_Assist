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
