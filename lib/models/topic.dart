class Topic {
  static int _nextId = 0;
  int id;
  String title;

  Topic({
    required this.title,
  }) : id = _nextId++;

  // Factory constructor to handle JSON deserialization
  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}
