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
  String _searchQuery = '';
  int? _highlightedProcedureId;


  @override
  void initState() {
    super.initState();
    _initializeTabController();
    _loadSampleData(); // Load sample data
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
        bottom: _buildTabBar(), // Always show the TabBar, even during search
        actions: [
          Row(
            children: [
              _buildSearchField(), // Search field with a fixed width
            ],
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
        child: _searchQuery.isNotEmpty
            ? _buildSearchResults() // Show search results
            : TabBarView(
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
      width: 200, // Give a fixed width here to avoid unbounded issues
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

  Widget _buildSearchField() {
    return Container(
      width: 250, // Set a fixed width for the search field
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Procedures...',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = ''; // Clear search query
                    });
                  },
                )
              : null,
        ),
        style: const TextStyle(color: Colors.black), // Set text color to black
        onChanged: (query) {
          setState(() {
            _searchQuery = query.toLowerCase(); // Update query dynamically
          });
        },
        controller:
            TextEditingController(text: _searchQuery), // Keep the text updated
      ),
    );
  }



  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return Text(text); // No highlight needed
    }

    final List<TextSpan> spans = [];
    int start = 0;
    int index = text.toLowerCase().indexOf(query.toLowerCase());

    while (index != -1) {
      spans.add(TextSpan(text: text.substring(start, index)));
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      start = index + query.length;
      index = text.toLowerCase().indexOf(query.toLowerCase(), start);
    }
    spans.add(TextSpan(text: text.substring(start)));

    return RichText(
        text: TextSpan(
            children: spans, style: const TextStyle(color: Colors.white)));
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
              // _bookmarkedProcedures.add(Procedure(
              //   title: newTitle,
              //   steps: newSteps,
              //   topicId: selectedTopic?.id,
              // ));

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
    if (_searchQuery.isEmpty) {
      return _procedures
          .where((procedure) => procedure.topicId == topic.id)
          .toList();
    }

    // Only match procedures where the title contains the search query
    return _procedures
        .where((procedure) =>
            procedure.topicId == topic.id &&
            procedure.title
                .toLowerCase()
                .contains(_searchQuery)) // Only match by title
        .toList();
  }



  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) return Container();

    // List of procedures to show
    List<Procedure> matchedProcedures = [];

    // First, find topics where the topic title matches the search query
    List<Topic> matchingTopics = _topics.where((topic) {
      return topic.title.toLowerCase().contains(_searchQuery);
    }).toList();

    // Add all procedures under those matching topics
    for (var topic in matchingTopics) {
      matchedProcedures.addAll(
        _procedures
            .where((procedure) => procedure.topicId == topic.id)
            .toList(),
      );
    }

    // Now, find procedures where the title matches the search query, regardless of topic
    List<Procedure> matchingProcedures = _procedures.where((procedure) {
      return procedure.title.toLowerCase().contains(_searchQuery);
    }).toList();

    // Merge both results, ensuring no duplicates (use a Set to handle uniqueness)
    Set<Procedure> finalResults = {...matchedProcedures, ...matchingProcedures};

    if (finalResults.isEmpty) {
      return Center(
        child: Text("No results found for '$_searchQuery'"),
      );
    }

    // Group results by topic for better display
    Map<Topic, List<Procedure>> groupedResults = {};

    for (var procedure in finalResults) {
      Topic topic =
          _topics.firstWhere((topic) => topic.id == procedure.topicId);
      if (!groupedResults.containsKey(topic)) {
        groupedResults[topic] = [];
      }
      groupedResults[topic]!.add(procedure);
    }

    // Render results grouped by topic in a lightweight, clean design
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListView.builder(
        itemCount: groupedResults.length,
        itemBuilder: (context, index) {
          Topic topic = groupedResults.keys.elementAt(index);
          List<Procedure> procedures = groupedResults[topic]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topic Title with minimal styling
                Text(
                  topic.title,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            Colors.blueAccent, // Subtle color for topic header
                      ),
                ),
                const SizedBox(
                    height: 8.0), // Space between title and procedures

                // Procedures for the topic
                ...procedures.map((procedure) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0), // Space between procedures
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                      ),
                      child: ListTile(
                        title: _buildHighlightedText(
                            procedure.title, _searchQuery),
                        subtitle: Text(
                          topic
                              .title, // Show topic title as a subtitle to reinforce grouping
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        onTap: () {
                          // You can add navigation or other actions here
                          _highlightProcedure(procedure);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _highlightProcedure(Procedure procedure) {
    // Find the index of the corresponding topic tab
    int topicIndex =
        _topics.indexWhere((topic) => topic.id == procedure.topicId);

    // If the topic is found, switch to that tab
    if (topicIndex != -1) {
      setState(() {
        _tabController.animateTo(
            topicIndex + 1); // +1 because My Procedures is the first tab
        _highlightedProcedureId = procedure.id; // Highlight this procedure
        _searchQuery = ''; // Reset the search query
      });

      // Remove the highlight after 1 second
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _highlightedProcedureId = null; // Reset highlight
        });
      });
    }
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
                    titleWidget:
                        _buildHighlightedText(procedure.title, _searchQuery),
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
