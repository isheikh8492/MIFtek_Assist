import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIFtek Assist',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Placeholder data for the procedure list
  final List<String> _procedures = [
    "Procedure 1",
    "Procedure 2",
    "Procedure 3"
  ];

  // Method to add a new procedure
  void _addProcedure() {
    setState(() {
      _procedures.add('New Procedure');
    });
  }

  // Method to remove a procedure
  void _removeProcedure(int index) {
    setState(() {
      _procedures.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'MIFtek Assist',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.left,
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title and FAB in the same row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Procedures',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w700, // Bigger font weight for title
                  ),
                ),
                FloatingActionButton(
                  onPressed: _addProcedure,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  tooltip: 'Add Procedure',
                  foregroundColor: Colors.white,
                  hoverColor: Colors.blue[600],
                  child: const Icon(Icons.add, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // List of Procedures
            Expanded(
              child: ListView.builder(
                itemCount: _procedures.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        _procedures[index],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye,
                                color: Colors.blue),
                            onPressed: () {
                              // View procedure details (to be implemented)
                            },
                            tooltip: 'View Details',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeProcedure(index),
                            tooltip: 'Delete Procedure',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
