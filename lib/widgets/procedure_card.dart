import 'package:flutter/material.dart';
import '../models/precudure.dart';

class ProcedureCard extends StatelessWidget {
  final Procedure procedure;
  final bool isDesktop;
  final bool isPersonal;
  final VoidCallback onBookmark;
  final VoidCallback onEdit;
  final VoidCallback onRemove; // New: Callback for remove action
  final String createdBy;

  const ProcedureCard({
    super.key,
    required this.procedure,
    required this.isDesktop,
    this.isPersonal = false,
    required this.onBookmark,
    required this.onEdit,
    required this.onRemove, // New: Initialize in constructor
    required this.createdBy,
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
            // Title and Edit/Bookmark/Remove Icons
            Row(
              children: [
                Expanded(
                  child: Text(
                    procedure.title,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Remove Icon
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                  ),
                  onPressed: onRemove, // Callback for removing procedure
                ),
                // Bookmark or Edit Icon
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
            // Steps with Proper Alignment
            Expanded(
              child: ListView.builder(
                physics:
                    const NeverScrollableScrollPhysics(), // To avoid scrolling within the card
                shrinkWrap: true, // To make it take the minimum space required
                itemCount: procedure.steps.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Number Column with Fixed Width for Alignment
                        SizedBox(
                          width: 20, // Fixed width to align numbers
                          child: Text(
                            '${i + 1}.',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                                fontSize: isDesktop ? 15 : 12),
                            textAlign:
                                TextAlign.right, // Align numbers to the right
                          ),
                        ),
                        const SizedBox(
                            width: 8), // Spacing between number and text
                        // Step Text Expanded to Fill Space
                        Expanded(
                          child: Text(
                            procedure.steps[i],
                            style: TextStyle(
                              fontSize: isDesktop ? 15 : 12,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Created by tag - Always at the bottom of the card
            if (!isPersonal)
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Created by: $createdBy',
                    style: TextStyle(
                      fontSize: isDesktop ? 12 : 10,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
