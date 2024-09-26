import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../widgets/procedure_card.dart';
import './procedure_search_delegate.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ["Maintenance", "Safety", "Calibration"];
  final List<String> _procedures = [
    "Procedure 1",
    "Procedure 2",
    "Procedure 3"
  ];
  final List<String> _bookmarkedProcedures = [];
  bool _isAddingCategory = false; // Flag to toggle category input field
  final TextEditingController _categoryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeTabController();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isAddingCategory) {
        setState(() {
          _isAddingCategory = false; // Abort adding when focus is lost
        });
      }
    });
  }

  void _initializeTabController() {
    _tabController = TabController(
      length: _categories.length + 1, // +1 for My Procedures
      vsync: this,
    );
  }

  void _updateTabController() {
    setState(() {
      _tabController.dispose();
      _tabController = TabController(
        length: _categories.length + 1,
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
        _categories.add(newCategory);
        _isAddingCategory = false;
        _categoryController.clear();
        _updateTabController();
      });
    }
  }

  void _editProcedure(String newProcedure, int index) {
    setState(() {
      _bookmarkedProcedures[index] = newProcedure;
    });
  }

  void _showEditProcedureDialog(
      BuildContext context, String procedure, int index) {
    TextEditingController _editController =
        TextEditingController(text: procedure);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Procedure'),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(
              labelText: 'Procedure Name',
            ),
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
                _editProcedure(_editController.text, index);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MIFtek Assist'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
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
                      ..._categories.map((category) => Tab(text: category)),
                    ],
                  ),
                ),
                if (_isAddingCategory) // Show the input field when adding a category
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
                else // Show the plus icon when not adding a category
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
              showSearch(
                context: context,
                delegate:
                    ProcedureSearchDelegate(_procedures, _bookmarkedProcedures),
              );
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
            ..._categories.map((category) {
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
                // Add the procedure to bookmarked list if not already added
                if (!_bookmarkedProcedures.contains(_procedures[index])) {
                  _bookmarkedProcedures.add(_procedures[index]);
                }
              });
            },
            onEdit: () {},
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

}
