class Procedure {
  static int _nextId = 0;
  final int id;
  String title;
  String? topic;
  List<String>? steps = [];

  Procedure({
    required this.title,
    this.topic,
    required this.steps
  }) : id = _nextId++;
}