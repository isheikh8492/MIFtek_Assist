import 'package:flutter/material.dart';

class ProcedureCard extends StatelessWidget {
  final String procedure;
  final bool isDesktop;
  final bool isPersonal;
  final VoidCallback onBookmark;
  final VoidCallback onEdit; // Add callback for editing

  const ProcedureCard({
    super.key,
    required this.procedure,
    required this.isDesktop,
    this.isPersonal = false,
    required this.onBookmark,
    required this.onEdit, // Required callback for editing
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(procedure),
            trailing: IconButton(
              icon: Icon(isPersonal ? Icons.edit : Icons.bookmark_add,
                  color: Colors.blue),
              onPressed: isPersonal ? onEdit : onBookmark, // Edit or bookmark
            ),
            onTap: () {
              // Expand procedure details or open detailed view
            },
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Step 1: Get floor soap'),
                Text('Step 2: Pour soap into bucket'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
