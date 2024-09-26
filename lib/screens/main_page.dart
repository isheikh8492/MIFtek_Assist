import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/precudure.dart';
import '../widgets/procedure_card.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Topic> _topics = [];
  List<Procedure> _procedures = [];
  final List<Procedure> _bookmarkedProcedures = [];
  bool _isAddingCategory = false;
  final TextEditingController _categoryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeTabController();
    _loadSampleData(); // Load sample data
  }

  Future<void> _loadSampleData() async {
    String data = await rootBundle.loadString('assets/sample_data.json');
    final jsonData = json.decode(data);

    setState(() {
      _topics = List<String>.from(jsonData['categories'])
          .map((category) => Topic.fromJson(category))
          .toList();
      _procedures = List<Map<String, dynamic>>.from(jsonData['procedures'])
          .map((procedure) => Procedure.fromJson(procedure))
          .toList();
      _updateTabController();
    });
  }

  void _initializeTabController() {
    _tabController = TabController(
      length: _topics.length + 1, // +1 for My Procedures
      vsync: this,
    );
  }

  void _updateTabController() {
    setState(() {
      _tabController.dispose();
      _tabController = TabController(
        length: _topics.length + 1,
        vsync: this,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addNewCategory(String newCategory) {
    if (newCategory.isNotEmpty) {
      setState(() {
        _topics.add(Topic(title: newCategory));
        _isAddingCategory = false;
        _categoryController.clear();
        _updateTabController();
      });
    }
  }

  void _editProcedure(String newTitle, List<String> newSteps, int index) {
    setState(() {
      _bookmarkedProcedures[index].title = newTitle;
      _bookmarkedProcedures[index].steps = newSteps;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MIFtek Assist'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: SizedBox(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: [
                      Tab(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple[400],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "My Procedures",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      ..._topics.map((topic) => Tab(text: topic.title)),
                    ],
                  ),
                ),
                if (_isAddingCategory)
                  Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 10),
                    child: TextField(
                      controller: _categoryController,
                      focusNode: _focusNode,
                      autofocus: true,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'New Category',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            _addNewCategory(_categoryController.text);
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        _addNewCategory(value);
                      },
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _isAddingCategory = true; // Start adding category
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search logic
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (_isAddingCategory) {
            setState(() {
              _isAddingCategory = false; // Close input when tapping outside
            });
          }
        },
        child: TabBarView(
          controller: _tabController,
          dragStartBehavior: DragStartBehavior.start,
          children: [
            _buildPersonalProceduresGrid(isDesktop),
            ..._topics.map((topic) {
              return _buildProceduresGrid(isDesktop);
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new procedure action
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProceduresGrid(bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _procedures.length,
        itemBuilder: (context, index) {
          return ProcedureCard(
            procedure: _procedures[index],
            isDesktop: isDesktop,
            onBookmark: () {
              setState(() {
                if (!_bookmarkedProcedures.contains(_procedures[index])) {
                  _bookmarkedProcedures.add(_procedures[index]);
                }
              });
            },
            onEdit: () {
              _showEditProcedureDialog(context, _procedures[index], index);
            },
          );
        },
      ),
    );
  }

  Widget _buildPersonalProceduresGrid(bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _bookmarkedProcedures.isNotEmpty
          ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _bookmarkedProcedures.length,
              itemBuilder: (context, index) {
                return ProcedureCard(
                  procedure: _bookmarkedProcedures[index],
                  isDesktop: isDesktop,
                  isPersonal: true,
                  onBookmark: () {},
                  onEdit: () {
                    _showEditProcedureDialog(
                      context,
                      _bookmarkedProcedures[index],
                      index,
                    );
                  },
                );
              },
            )
          : Center(
              child: Text(
                "No bookmarked procedures yet.",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
    );
  }

  void _showEditProcedureDialog(
      BuildContext context, Procedure procedure, int index) {
    TextEditingController _editTitleController =
        TextEditingController(text: procedure.title);

    List<TextEditingController> _editStepControllers = procedure.steps
        .map((step) => TextEditingController(text: step))
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Procedure'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editTitleController,
                decoration: const InputDecoration(
                  labelText: 'Procedure Name',
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: List.generate(_editStepControllers.length, (index) {
                  return TextField(
                    controller: _editStepControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Step ${index + 1}',
                    ),
                  );
                }),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _editStepControllers.add(TextEditingController());
                  setState(() {});
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Step'),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _editProcedure(
                  _editTitleController.text,
                  _editStepControllers
                      .map((controller) => controller.text)
                      .toList(),
                  index,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

