import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/precudure.dart';
import '../models/topic.dart';
import '../widgets/procedure_card.dart';
import '../widgets/edit_procedure_dialog.dart';
import '../widgets/add_precedure_dialog.dart';
import '../widgets/procedure_search_delegate.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _highlightedProcedureId;

  String _loggedInUserId = '';
  String? _loggedInFirstName;
  String? _loggedInLastName;
  String? _loggedInEmail;

  late ScrollController _tabScrollController;

  bool _showScrollButtons = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _initializeTabController();
    _tabScrollController = ScrollController()
      ..addListener(() {
        _checkIfScrollable();
      });
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _loggedInUserId = prefs.getString('userId')!;
      _loggedInFirstName = prefs.getString('firstName');
      _loggedInFirstName = prefs.getString('lastName');
      _loggedInEmail = prefs.getString('email');
    });
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Reference to Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Load topics from Firestore
      QuerySnapshot topicSnapshot = await firestore.collection('topics').get();
      List<Topic> loadedTopics = topicSnapshot.docs.map((doc) {
        return Topic.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Load procedures from Firestore
      QuerySnapshot procedureSnapshot =
          await firestore.collection('procedures').get();
      List<Procedure> loadedProcedures = procedureSnapshot.docs.map((doc) {
        return Procedure.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Update the state with the fetched data
      setState(() {
        _topics = loadedTopics;
        _procedures = loadedProcedures;
      });
      _updateTabController();
    } catch (e) {
      print('Error loading data: $e');
      // Optionally show an error message or handle the error accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  bool isUserAdmin() {
    return (_loggedInEmail == "admin@miftek.com" && _loggedInFirstName == "Miftek" && _loggedInLastName == "Admin");
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

  Future<void> _addNewTopic(String title, String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Add topic to Firestore with an auto-generated ID
      DocumentReference docRef = await firestore.collection('topics').add({
        'title': title,
        'createdBy': userId,
      });

      // Retrieve the auto-generated ID
      String topicId = docRef.id;

      // Optionally, update the state to keep track of topics locally
      setState(() {
        _topics.add(Topic(
          id: topicId, // Use the generated ID
          title: title,
          createdBy: userId,
        ));
      });
      _categoryController.clear();
      _isAddingCategory = false;
      _updateTabController();
    } catch (e) {
      print('Failed to add topic: $e');
    }
  }

  Future<void> _addNewProcedure(
      String title, List<String> steps, String topicId, String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Add the new procedure to Firestore and link to the topic
      DocumentReference docRef = await firestore.collection('procedures').add({
        'title': title,
        'steps': steps,
        'topicId': topicId, // Link this procedure to the topic using its ID
        'createdBy': userId,
        'isPersonal': false
      });

      // Use Firestore's auto-generated ID for the Procedure model
      String procedureId = docRef.id;

      setState(() {
        _procedures.add(Procedure(
          id: procedureId,
          title: title,
          steps: steps,
          topicId: topicId,
          createdBy: userId,
          isPersonal: false
        ));
      });
    } catch (e) {
      print('Failed to add procedure: $e');
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
              _addNewTopic(_categoryController.text, _loggedInUserId);
            },
          ),
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          _addNewTopic(value, _loggedInUserId!);
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
                _addNewProcedure(newTitle, newSteps, selectedTopic.id, _loggedInUserId);
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
