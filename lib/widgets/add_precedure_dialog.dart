import 'package:flutter/material.dart';
import '../models/topic.dart';

class AddProcedureDialog extends StatefulWidget {
  final Function(String, List<String>, Topic?) onSave;
  final List<Topic> availableTopics;
  final Topic? selectedTopic; // New: current tab's selected topic

  const AddProcedureDialog({
    required this.onSave,
    required this.availableTopics,
    this.selectedTopic, // New: pass the topic if a specific topic tab is open
    super.key,
  });

  @override
  _AddProcedureDialogState createState() => _AddProcedureDialogState();
}

class _AddProcedureDialogState extends State<AddProcedureDialog> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _stepControllers = [];
  Topic? _selectedTopic;

  @override
  void initState() {
    super.initState();
    // If the dialog was opened from a specific topic tab, use that topic
    _selectedTopic = widget.selectedTopic;
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: 400,
        height: 550,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Procedure Title Input
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Procedure Name',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Topic Dropdown with Info Icon
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Topic>(
                      decoration: const InputDecoration(
                        labelText: 'Select Topic',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                      ),
                      value: _selectedTopic,
                      onChanged: (widget.selectedTopic !=
                              null) // Disable if topic was passed
                          ? null
                          : (Topic? newValue) {
                              setState(() {
                                _selectedTopic = newValue;
                              });
                            },
                      items: [
                        DropdownMenuItem<Topic>(
                          value: null, // Null indicates no topic selected
                          child: const Text('No Topic Selected'),
                        ),
                        ...widget.availableTopics.map((Topic topic) {
                          return DropdownMenuItem<Topic>(
                            value: topic,
                            child: Text(topic.title),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    tooltip:
                        'Selecting a topic will add the procedure to both "My Procedures" and the selected topic.\n'
                        'If no topic is selected, the procedure will only appear in "My Procedures".',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Topic Selection Info'),
                            content: const Text(
                              'Selecting a topic will add the procedure to both "My Procedures" and the selected topic.\n'
                              'If no topic is selected, the procedure will only appear in "My Procedures".',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Scrollable Steps Section
              Expanded(
                child: _stepControllers.isEmpty
                    ? const Center(
                        child: Text(
                          'No steps added yet. Add a new step.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: List.generate(_stepControllers.length,
                              (stepIndex) {
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _stepControllers[stepIndex],
                                        decoration: InputDecoration(
                                          labelText: 'Step ${stepIndex + 1}',
                                          border: InputBorder.none,
                                        ),
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _stepControllers.removeAt(stepIndex);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
              ),
              const SizedBox(height: 10),

              // Add Step Button
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _stepControllers.add(TextEditingController());
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Step'),
              ),

              const SizedBox(height: 20),

              // Save and Cancel Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave(
                        _titleController.text,
                        _stepControllers
                            .map((controller) => controller.text)
                            .toList(),
                        _selectedTopic, // Pass the selected topic, which can be null
                      );
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

