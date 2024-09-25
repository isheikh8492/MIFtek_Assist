class Topic {
  static int _nextId = 0;
  int id;
  String title;

  Topic({
    required this.title,
  }) : id = _nextId++;
}

