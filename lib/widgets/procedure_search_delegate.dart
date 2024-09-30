import 'package:flutter/material.dart';
import '../models/precudure.dart';
import '../models/topic.dart';
import '../screens/main_page.dart';

class ProcedureSearchDelegate extends SearchDelegate {
  final List<Procedure> procedures;
  final List<Topic> topics;
  final MainPageState mainPageState;

  ProcedureSearchDelegate({required this.procedures, required this.topics, required this.mainPageState});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context); // Refresh the suggestions when cleared
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
    final List<Procedure> filteredProcedures = _filterProcedures(query);

    return ListView.builder(
      itemCount: filteredProcedures.length,
      itemBuilder: (context, index) {
        final procedure = filteredProcedures[index];
        final topic = topics.firstWhere(
          (topic) => topic.id == procedure.topicId,
          orElse: () => Topic(id: 'Unknown', title: 'Unknown', createdBy: 'Unknown'),
        );

        return ListTile(
          title: Text(procedure.title),
          subtitle: Text(topic.title),
          onTap: () {
            // Close the search delegate to avoid duplicate screens
            close(context, null);
            mainPageState.highlightProcedure(procedure);
          },
        );
      },
    );
  }




  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Procedure> filteredProcedures = _filterProcedures(query);

    return ListView.builder(
      itemCount: filteredProcedures.length,
      itemBuilder: (context, index) {
        final procedure = filteredProcedures[index];
        final topic = topics.firstWhere(
          (topic) => topic.id == procedure.topicId,
          orElse: () => Topic(id: 'Unknown', title: 'Unknown', createdBy: 'Unknown'),
        );
        return ListTile(
          title: Text(procedure.title),
          subtitle: Text(topic.title),
          onTap: () {
            close(context, null);
            mainPageState.highlightProcedure(procedure);
          },
        );
      },
    );
  }


  List<Procedure> _filterProcedures(String query) {
    return procedures.where((procedure) {
      final topic = topics.firstWhere(
        (topic) => topic.id == procedure.topicId,
        orElse: () => Topic(id: 'Unknown', title: 'Unknown', createdBy: 'Unknown'),
      );
      return procedure.title.toLowerCase().contains(query.toLowerCase()) ||
          topic.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
