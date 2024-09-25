import 'package:flutter/material.dart';

class ProcedureSearchDelegate extends SearchDelegate<String> {
  final List<String> procedures;
  final List<String> personalProcedures;
  ProcedureSearchDelegate(this.procedures, this.personalProcedures);

  @override
  List<Widget> buildActions(BuildContext context) {
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
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = [
      ...procedures.where(
          (procedure) => procedure.toLowerCase().contains(query.toLowerCase())),
      ...personalProcedures.where(
          (procedure) => procedure.toLowerCase().contains(query.toLowerCase())),
    ];
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index]),
          onTap: () {
            // Show selected procedure
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = [
      ...procedures.where(
          (procedure) => procedure.toLowerCase().contains(query.toLowerCase())),
      ...personalProcedures.where(
          (procedure) => procedure.toLowerCase().contains(query.toLowerCase())),
    ];
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
          },
        );
      },
    );
  }
}
