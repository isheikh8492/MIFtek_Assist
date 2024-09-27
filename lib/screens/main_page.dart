import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/precudure.dart';
import '../models/topic.dart';
import '../widgets/procedure_card.dart';
import '../widgets/edit_procedure_dialog.dart';
import '../widgets/add_precedure_dialog.dart';

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
      // Correcting how topics are deserialized
      _topics = (jsonData['topics'] as List)
          .map((topicJson) => Topic.fromJson(topicJson))
          .toList();

      // Correcting how procedures are deserialized
      _procedures = (jsonData['procedures'] as List)
          .map((procedureJson) => Procedure.fromJson(procedureJson))
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
        bottom: _buildTabBar(),
        actions: [_buildSearchButton()],
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
          children: [
            _buildPersonalProceduresGrid(isDesktop),
            ..._topics.map((topic) {
              return _buildProceduresGrid(isDesktop, topic);
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new procedure action
          _showAddProcedureDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return PreferredSize(
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
              _buildNewCategoryInput()
            else
              _buildAddCategoryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewCategoryInput() {
    return Container(
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
    );
  }

  Widget _buildAddCategoryButton() {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        setState(() {
          _isAddingCategory = true; // Start adding category
        });
      },
    );
  }

  Widget _buildSearchButton() {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {
        // Search logic
      },
    );
  }

  Widget _buildProceduresGrid(bool isDesktop, Topic topic) {
    final proceduresForTopic = _procedures.where((procedure) => procedure.topicId == topic.id)
    .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: proceduresForTopic.isNotEmpty
          ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: proceduresForTopic.length,
              itemBuilder: (context, index) {
                return ProcedureCard(
                  procedure: proceduresForTopic[index],
                  isDesktop: isDesktop,
                  onBookmark: () {
                    setState(() {
                      if (!_bookmarkedProcedures.any((proc) =>
                          proc.title == proceduresForTopic[index].title)) {
                        _bookmarkedProcedures.add(proceduresForTopic[index]);
                      }
                    });
                  },
                  onEdit: () {
                    _showEditProcedureDialog(
                        context, proceduresForTopic[index], index);
                  },
                );
              },
            )
          : Center(
              child: Text(
                "No procedures available for this topic.",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditProcedureDialog(
          procedure: procedure,
          onSave: (String newTitle, List<String> newSteps) {
            _editProcedure(newTitle, newSteps, index);
          },
        );
      },
    );
  }

  void _showAddProcedureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddProcedureDialog(
          availableTopics: _topics, // Pass the list of available topics
          onSave:
              (String newTitle, List<String> newSteps, Topic selectedTopic) {
            // Add the new procedure to the selected topic
            setState(() {
              _procedures.add(Procedure(
                title: newTitle,
                steps: newSteps,
                topicId: selectedTopic.id,
              ));
            });
          },
        );
      },
    );
  }
}
