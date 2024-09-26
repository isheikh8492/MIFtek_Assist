import 'package:flutter/material.dart';

import '../models/precudure.dart';

class ProcedureCard extends StatelessWidget {
  final Procedure procedure;
  final bool isDesktop;
  final bool isPersonal;
  final VoidCallback onBookmark;
  final VoidCallback onEdit;

  const ProcedureCard({
    super.key,
    required this.procedure,
    required this.isDesktop,
    this.isPersonal = false,
    required this.onBookmark,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    procedure.title,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isPersonal ? Icons.edit : Icons.bookmark_add,
                    color: isPersonal ? Colors.orange : Colors.blue,
                  ),
                  onPressed: isPersonal ? onEdit : onBookmark,
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < procedure.steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${i + 1}. ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        procedure.steps[i],
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
