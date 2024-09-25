import 'package:flutter/material.dart';

class ProcedureCard extends StatelessWidget {
  final String procedure;
  final bool isDesktop;
  final bool isPersonal;
  final VoidCallback onBookmark; // Add callback for bookmarking

  const ProcedureCard({
    super.key,
    required this.procedure,
    required this.isDesktop,
    this.isPersonal = false,
    required this.onBookmark, // Required callback for bookmarking
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
              onPressed: onBookmark, // Call the callback on bookmark
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
