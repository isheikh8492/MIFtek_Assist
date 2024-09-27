import 'package:flutter/material.dart';
import '../models/precudure.dart';
import '../models/topic.dart';

class ProcedureSearchDelegate extends SearchDelegate {
  final List<Procedure> procedures;
  final List<Topic> topics;

  ProcedureSearchDelegate({required this.procedures, required this.topics});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Procedure> filteredProcedures = procedures.where((procedure) {
      final topic = topics.firstWhere(
        (topic) => topic.id == procedure.topicId,
        orElse: () => Topic(title: 'Unknown'),
      );
      return procedure.title.toLowerCase().contains(query.toLowerCase()) ||
          topic.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredProcedures.length,
      itemBuilder: (context, index) {
        final procedure = filteredProcedures[index];
        final topic = topics.firstWhere(
          (topic) => topic.id == procedure.topicId,
          orElse: () => Topic(title: 'Unknown'),
        );
        return ListTile(
          title: Text(procedure.title),
          subtitle: Text(topic.title),
          onTap: () {
            close(context, procedure);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Procedure> filteredProcedures = procedures.where((procedure) {
      final topic = topics.firstWhere(
        (topic) => topic.id == procedure.topicId,
        orElse: () => Topic(title: 'Unknown'),
      );
      return procedure.title.toLowerCase().contains(query.toLowerCase()) ||
          topic.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredProcedures.length,
      itemBuilder: (context, index) {
        final procedure = filteredProcedures[index];
        final topic = topics.firstWhere(
          (topic) => topic.id == procedure.topicId,
          orElse: () => Topic(title: 'Unknown'),
        );
        return ListTile(
          title: Text(procedure.title),
          subtitle: Text(topic.title),
          onTap: () {
            query = procedure.title;
            showResults(context);
          },
        );
      },
    );
  }
}
