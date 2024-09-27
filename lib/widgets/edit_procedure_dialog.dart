import 'package:flutter/material.dart';
import '../models/precudure.dart';

class EditProcedureDialog extends StatefulWidget {
  final Procedure procedure;
  final Function(String, List<String>) onSave;

  const EditProcedureDialog({
    required this.procedure,
    required this.onSave,
    super.key,
  });

  @override
  _EditProcedureDialogState createState() => _EditProcedureDialogState();
}

class _EditProcedureDialogState extends State<EditProcedureDialog> {
  late TextEditingController _editTitleController;
  late List<TextEditingController> _editStepControllers;

  @override
  void initState() {
    super.initState();
    _editTitleController = TextEditingController(text: widget.procedure.title);
    _editStepControllers = widget.procedure.steps
        .map((step) => TextEditingController(text: step))
        .toList();
  }

  @override
  void dispose() {
    _editTitleController.dispose();
    for (var controller in _editStepControllers) {
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
        width: 400, // Fixed width
        height: 500, // Fixed height
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Procedure Title
              TextField(
                controller: _editTitleController,
                decoration: const InputDecoration(
                  labelText: 'Procedure Name',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Scrollable Steps Section
              Expanded(
                child: _editStepControllers.isEmpty
                    ? const Center(
                        child: Text(
                          'No steps available. Add a new step.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: List.generate(_editStepControllers.length,
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
                                        controller:
                                            _editStepControllers[stepIndex],
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
                                          _editStepControllers
                                              .removeAt(stepIndex);
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
                    _editStepControllers.add(TextEditingController());
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
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave(
                        _editTitleController.text,
                        _editStepControllers
                            .map((controller) => controller.text)
                            .toList(),
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
