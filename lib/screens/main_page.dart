import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/precudure.dart';
import '../models/topic.dart';
import '../widgets/procedure_card.dart';
import '../widgets/edit_procedure_dialog.dart';
import '../widgets/add_precedure_dialog.dart';
import '../widgets/procedure_search_delegate.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Topic> _topics = [];
  List<Procedure> _procedures = [];
  final List<Procedure> _bookmarkedProcedures = [];
  bool _isAddingCategory = false;
  final TextEditingController _categoryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int? _highlightedProcedureId;

  late ScrollController _tabScrollController;

  bool _showScrollButtons = false;
  
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeTabController();
    _loadSampleData(); // Load sample data
    _tabScrollController = ScrollController()
      ..addListener(() {
        _checkIfScrollable();
      });
  }

  void _checkIfScrollable() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tabScrollController.hasClients &&
          _tabScrollController.position.maxScrollExtent > 0) {
        if (!_showScrollButtons) {
          setState(() {
            _showScrollButtons = true;
          });
        }
      } else if (_showScrollButtons) {
        setState(() {
          _showScrollButtons = false;
        });
      }
    });
  }

  Future<void> _loadSampleData() async {
    try {
      String data = await rootBundle.loadString('assets/sample_data.json');
      final jsonData = json.decode(data);

      setState(() {
        _topics = (jsonData['topics'] as List)
            .map((topicJson) => Topic.fromJson(topicJson))
            .toList();

        _procedures = (jsonData['procedures'] as List)
            .map((procedureJson) => Procedure.fromJson(procedureJson))
            .toList();

        _updateTabController();
      });
    } catch (e) {
      // Handle or show error message
      print('Error loading data: $e');
    }
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
    _checkIfScrollable();
  }


  @override
  void dispose() {
    _tabController.dispose();
    _categoryController.dispose();
    _focusNode.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  void _scrollTabBar(double offset) {
    double newOffset = _tabScrollController.offset + offset;

    // Prevent over-scrolling to the left
    if (newOffset < 0) {
      newOffset = 0;
    }

    // Prevent over-scrolling to the right
    if (newOffset > _tabScrollController.position.maxScrollExtent) {
      newOffset = _tabScrollController.position.maxScrollExtent;
    }

    _tabScrollController.animateTo(
      newOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
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

  void highlightProcedure(Procedure procedure) {
    // Find the index of the corresponding topic tab
    int topicIndex =
        _topics.indexWhere((topic) => topic.id == procedure.topicId);

    if (topicIndex != -1) {
      // Navigate to the topic tab (+1 because "My Procedures" is the first tab)
      _tabController.animateTo(topicIndex + 1);
    } else {
      // If it's a bookmarked procedure, navigate to "My Procedures"
      _tabController.animateTo(0);
    }

    // Delay to ensure the tab navigation is complete before highlighting
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        // Set the highlighted procedure ID to indicate which procedure to blink
        _highlightedProcedureId = procedure.id;
      });

      // Remove highlight after a short period to create a blink effect
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _highlightedProcedureId = null;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MIFtek Assist'),
        bottom: _buildTabBar(),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProcedureSearchDelegate(
                  mainPageState: this,
                  procedures: _procedures,
                  topics: _topics,
                ),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (_isAddingCategory) {
            setState(() {
              _isAddingCategory = false;
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
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_isAddingCategory) {
              setState(() {
                _isAddingCategory = false;
              });
            }
          },
          child: Row(
            children: [
              if (_showScrollButtons)
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () =>
                      _scrollTabBar(-200), // Scroll left by 200 pixels
                ),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    // Calculate the new scroll offset
                    double newOffset = _tabScrollController.offset - details.delta.dx;

                    // Prevent over-scrolling to the left
                    if (newOffset < 0) {
                      newOffset = 0;
                    }
                
                    // Prevent over-scrolling to the right
                    if (newOffset > _tabScrollController.position.maxScrollExtent) {
                      newOffset = _tabScrollController.position.maxScrollExtent;
                    }
                
                    _tabScrollController.jumpTo(newOffset);
  },
  child: SingleChildScrollView(
    controller: _tabScrollController,
    scrollDirection: Axis.horizontal,
    physics: const ClampingScrollPhysics(), // Disable visual scrollbar
    child: Row(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      ],
    ),
  ),
),
              ),
              if (_showScrollButtons)
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () =>
                      _scrollTabBar(200), // Scroll right by 200 pixels
                ),
              // Separator between the tab bar and the add button
              Container(
                width: 1, // Width of the separator
                height: 30, // Height of the separator
                color: Colors.white, // Color of the separator
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              if (!_isAddingCategory) // Hide "+" button when adding a new category
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _isAddingCategory = true;
                      });
                    },
                  ),
                ),
              if (_isAddingCategory) _buildNewCategoryInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewCategoryInput() {
    return Container(
      width: 200, // Give a fixed width here to avoid unbounded issues
      margin: const EdgeInsets.only(left: 10, right: 10),
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
                  onRemove: () {
                    _removeBookmarkedProcedure(index);
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

  void _removeBookmarkedProcedure(int index) {
    setState(() {
      _bookmarkedProcedures.removeAt(index);
    });
    _showSnackbar('Procedure removed from My Procedures');
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
    Topic? currentTabTopic = (_tabController.index > 0)
        ? _topics[_tabController.index -
            1] // Because "My Procedures" is the first tab (index 0)
        : null; // Null if "My Procedures" tab is selected

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddProcedureDialog(
          availableTopics: _topics,
          onSave:
              (String newTitle, List<String> newSteps, Topic? selectedTopic) {
            setState(() {
              if (selectedTopic != null) {
                _procedures.add(Procedure(
                  title: newTitle,
                  steps: newSteps,
                  topicId: selectedTopic.id,
                ));
              }
            });
            _showSnackbar('Procedure added successfully');
          },
          selectedTopic: currentTabTopic, // Pass the current tab's topic
        );
      },
    );
  }


  List<Procedure> _getFilteredProcedures(Topic topic) {
    // If no search query, return all procedures for the topic
    return _procedures
        .where((procedure) => procedure.topicId == topic.id)
        .toList();
  }



  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildProceduresGrid(bool isDesktop, Topic topic) {
    final proceduresForTopic = _getFilteredProcedures(topic);

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
                final procedure = proceduresForTopic[index];

                // Check if this procedure is the one being highlighted
                final isHighlighted = procedure.id == _highlightedProcedureId;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? Colors.yellow.withOpacity(0.3) // Highlight color
                        : Colors.transparent, // Normal state
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ProcedureCard(
                    procedure: procedure,
                    isDesktop: isDesktop,
                    onBookmark: () {
                      setState(() {
                        if (!_bookmarkedProcedures
                            .any((proc) => proc.title == procedure.title)) {
                          _bookmarkedProcedures.add(procedure.deepCopy());
                        }
                      });
                    },
                    onEdit: () {
                      _showEditProcedureDialog(context, procedure, index);
                    },
                    onRemove: () {
                      _removeProcedureFromTopic(topic, procedure);
                    },
                  ),
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




  void _removeProcedureFromTopic(Topic topic, Procedure procedure) {
    setState(() {
      _procedures
          .removeWhere((p) => p.id == procedure.id && p.topicId == topic.id);
    });
    _showSnackbar('Procedure removed from ${topic.title}');
  }

}
