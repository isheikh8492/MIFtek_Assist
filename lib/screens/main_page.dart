import 'package:flutter/material.dart';
import '../widgets/procedure_card.dart';
import './procedure_search_delegate.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ["Maintenance", "Safety", "Calibration"];
  final List<String> _procedures = [
    "Procedure 1",
    "Procedure 2",
    "Procedure 3"
  ];
  final List<String> _bookmarkedProcedures =
      []; // User’s personal list of bookmarked procedures

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: _categories.length + 1,
        vsync: this); // +1 for My Procedures tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MIFtek Assist'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors
                      .deepPurple[400], // Distinct color for "My Procedures"
                  borderRadius: BorderRadius.circular(
                      20), // Rounded corners for visual distinction
                ),
                child: const Text(
                  "My Procedures",
                  style:
                      TextStyle(color: Colors.white), // White text to stand out
                ),
              ),
            ),
            ..._categories.map((category) => Tab(text: category)),
            const Tab(
              child: Text('+', style: TextStyle(fontSize: 18)),
            ),
          ],
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalProceduresGrid(
              isDesktop), // "My Procedures" tab content
          ..._categories.map((category) {
            return _buildProceduresGrid(isDesktop);
          }),
        ],
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
              procedure: _procedures[index], isDesktop: isDesktop);
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
                    isPersonal: true);
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
