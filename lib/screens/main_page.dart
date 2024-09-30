import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miftek_assist/screens/auth_screen.dart';
import '../models/precudure.dart';
import '../models/topic.dart';
import '../widgets/procedure_card.dart';
import '../widgets/edit_procedure_dialog.dart';
import '../widgets/add_precedure_dialog.dart';
import '../widgets/procedure_search_delegate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Topic> _topics = [];
  List<Procedure> _procedures = [];
  bool _isAddingCategory = false;
  final TextEditingController _categoryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _highlightedProcedureId;
  final Map<String, String> _userNames = {};
  final FirestoreService _firestoreService = FirestoreService();

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
      _loggedInLastName = prefs.getString('lastName');
      _loggedInEmail = prefs.getString('email');
    });
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load data using FirestoreService
      List<Topic> loadedTopics = await _firestoreService.loadTopics();
      List<Procedure> loadedProcedures =
          await _firestoreService.loadProcedures();

      setState(() {
        _topics = loadedTopics;
        _procedures = loadedProcedures;
      });
      _updateTabController();

      // Load user names for the procedures
      _userNames.addAll(await _firestoreService.loadUserNames(_procedures));
    } catch (e) {
      print('Error loading data: $e');
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
    String? topicId = await _firestoreService.addNewTopic(title, userId);

    if (title == '') {
      return;
    }
    if (topicId != null) {
      setState(() {
        _topics.add(Topic(
          id: topicId,
          title: title,
          createdBy: userId,
        ));
      });
      _categoryController.clear();
      _isAddingCategory = false;
      _updateTabController();
    } else {
      print('Failed to add topic');
    }
  }

  Future<void> _addNewProcedure(
      String title, List<String> steps, Topic? topic, String userId) async {
    String? procedureId = await _firestoreService.addNewProcedure(
      title,
      steps,
      topic?.id,
      userId,
      topic == null,
    );

    if (procedureId != null) {
      setState(() {
        _procedures.add(Procedure(
          id: procedureId,
          title: title,
          steps: steps,
          topicId: topic?.id,
          createdBy: userId,
          isPersonal: topic == null,
        ));
      });
    } else {
      print('Failed to add procedure');
    }
  }

  void _editProcedure(String newTitle, List<String> newSteps, Procedure procedure) async {
    Procedure procedureToEdit = procedure;
    print('procedure to be edited: ${procedureToEdit.toString()}');
    await _firestoreService.editProcedure(
      procedureToEdit.id,
      newTitle,
      newSteps,
    );

    setState(() {
      procedureToEdit.title = newTitle;
      procedureToEdit.steps = newSteps;
    });
    print('procedure after edit: ${procedureToEdit.toString()}');
    _showSnackbar('Procedure updated successfully');
  }

  void _logout() async {
    // Log out from FirebaseAuth
    await FirebaseAuth.instance.signOut();

    // Clear SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Redirect to login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              AuthScreen()), // Assuming LoginScreen is defined somewhere in your code
    );
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
        title: Text(
          'MIFtek Assist',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple,
        bottom: _buildTabBar(),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.white,
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
          if (_loggedInFirstName != null && _loggedInLastName != null)
            Padding(
              padding: const EdgeInsets.only(
                  right: 16.0), // Padding added to the right
              child: PopupMenuButton<int>(
                icon: Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.purple.shade700, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        '${_loggedInFirstName!} ${_loggedInLastName!}',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    enabled: false, // Make the email option unselectable
                    child: ListTile(
                      leading: const Icon(Icons.email,
                          color: Color.fromARGB(255, 181, 181, 181)),
                      title: Text(_loggedInEmail ?? 'No Email',
                          style: const TextStyle(color: Colors.grey)),
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text('Log Out',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 2) {
                    _logout();
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      10), // Matches the button's borderRadius
                  side: BorderSide(color: Colors.purple.shade700, width: 1.0),
                ),
                color: Colors.purple
                    .shade900, // Optional: match the background color if desired
                elevation: 4, // Optional: add elevation for a more 3D look
              ),
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
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.purple
            : Colors.deepPurple,
        child: Icon(
          Icons.add,
          color: Colors.white
        ),
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
                  color: Colors.white,
                  onPressed: () => _scrollTabBar(-200),
                ),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    double newOffset =
                        _tabScrollController.offset - details.delta.dx;
                    newOffset = newOffset.clamp(
                        0, _tabScrollController.position.maxScrollExtent);
                    _tabScrollController.jumpTo(newOffset);
                  },
                  child: SingleChildScrollView(
                    controller: _tabScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      children: [
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabs: [
                            Tab(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple[800],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "My Procedures",
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                ),

                              ),
                            ),
                            ..._topics.map((topic) {
                              return GestureDetector(
                                onSecondaryTap: () {
                                  _showDeleteTopicDialog(topic);
                                },
                                child: Tab(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple[800],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      topic.title,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
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
                  color: Colors.white,
                  onPressed: () => _scrollTabBar(200),
                ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              if (!_isAddingCategory)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    color: Colors.white,
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
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'New Category',
          hintStyle: TextStyle(
            color: Colors.grey[200],
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.white,
            ),
            onPressed: () {
              _addNewTopic(_categoryController.text, _loggedInUserId);
            },
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }


  Widget _buildPersonalProceduresGrid(bool isDesktop) {
    final personalProcedures = _procedures
        .where((procedure) =>
            procedure.isPersonal && procedure.createdBy == _loggedInUserId)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: personalProcedures.isNotEmpty
          ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: personalProcedures.length,
              itemBuilder: (context, index) {
                return ProcedureCard(
                  procedure: personalProcedures[index],
                  isDesktop: isDesktop,
                  isPersonal: true,
                  onBookmark: () {},
                  onEdit: () {
                    _showEditProcedureDialog(
                      context,
                      personalProcedures[index],
                    );
                  },
                  onRemove: () {
                    _removeProcedure(personalProcedures[index]);
                  },
                  createdBy: _loggedInUserId,
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

  void _showDeleteTopicDialog(Topic topic) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Topic'),
          content: const Text(
            'Deleting this topic will delete all the procedures linked to it. Are you sure you want to proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isUserAdmin()) {
                  _deleteTopic(topic);
                } else {
                  _showSnackbar('Only administrators have this option.');
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }


  void _removeProcedure(Procedure procedure) async {
    await _firestoreService.removeProcedure(procedure);

    setState(() {
      _procedures.removeWhere((p) => p.id == procedure.id);
    });

    _showSnackbar('Procedure removed successfully');
  }

  Future<void> _deleteTopic(Topic topic) async {
    try {
      // Delete all procedures linked to this topic
      List<Procedure> proceduresToDelete =
          _procedures.where((p) => p.topicId == topic.id).toList();
      for (var procedure in proceduresToDelete) {
        await _firestoreService.removeProcedure(procedure);
      }

      // Delete the topic itself
      await _firestoreService.removeTopic(topic.id);

      // Update the local state
      setState(() {
        _procedures.removeWhere((p) => p.topicId == topic.id);
        _topics.removeWhere((t) => t.id == topic.id);
        _updateTabController();
      });

      _showSnackbar('Topic and linked procedures deleted successfully.');
    } catch (e) {
      print('Failed to delete topic: $e');
      _showSnackbar('Failed to delete topic: $e');
    }
  }


  void _showEditProcedureDialog(
      BuildContext context, Procedure procedure) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditProcedureDialog(
          procedure: procedure,
          onSave: (String newTitle, List<String> newSteps) {
            _editProcedure(newTitle, newSteps, procedure);
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
              _addNewProcedure(
                  newTitle, newSteps, selectedTopic, _loggedInUserId);
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
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[300]
            : Colors.black,
      ),
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
                final isHighlighted = procedure.id == _highlightedProcedureId;

                // Resolve the 'createdBy' field to display the user's full name
                String createdByName = _resolveUserName(procedure.createdBy);

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
                    onBookmark: () async {
                      try {
                        final newProcedure = await _firestoreService
                            .deepCopyProcedure(procedure, _loggedInUserId);
                        setState(() {
                          _procedures.add(newProcedure);
                        });
                        _showSnackbar('Procedure bookmarked successfully');
                      } catch (e) {
                        _showSnackbar('Failed to bookmark procedure: $e');
                      }
                    },
                    onEdit: () {
                      _showEditProcedureDialog(context, procedure);
                    },
                    onRemove: () {
                      _removeProcedure(procedure);
                    },
                    createdBy: createdByName,
                    isPersonal: procedure.isPersonal,
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

// Function to resolve user name based on user ID
  String _resolveUserName(String userId) {
    if (_userNames.containsKey(userId)) {
      return _userNames[userId]!;
    } else if (userId == _loggedInUserId) {
      // If it's the logged-in user, use the full name from SharedPreferences
      return '${_loggedInFirstName ?? ''} ${_loggedInLastName ?? ''}'.trim();
    } else {
      return 'Unknown';
    }
  }

}
