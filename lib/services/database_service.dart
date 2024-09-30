import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miftek_assist/models/precudure.dart';
import '../models/topic.dart';


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch a specific user by ID
  Future<String> fetchUserNameById(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        var user = doc.data() as Map<String, dynamic>;
        String firstName = user['firstName'] ?? 'Unknown';
        String lastName = user['lastName'] ?? '';
        return '$firstName $lastName';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print('Failed to fetch user: $e');
      return 'Unknown';
    }
  }

  Future<Map<String, String>> loadUserNames(List<Procedure> procedures) async {
    final Map<String, String> userNames = {};

    for (var procedure in procedures) {
      if (!userNames.containsKey(procedure.createdBy)) {
        try {
          DocumentSnapshot doc = await _firestore
              .collection('users')
              .doc(procedure.createdBy)
              .get();
          if (doc.exists) {
            var user = doc.data() as Map<String, dynamic>;
            String firstName = user['firstName'] ?? 'Unknown';
            String lastName = user['lastName'] ?? '';
            userNames[procedure.createdBy] = '$firstName $lastName';
          } else {
            userNames[procedure.createdBy] = 'Unknown';
          }
        } catch (e) {
          print('Error fetching user name for ID ${procedure.createdBy}: $e');
          userNames[procedure.createdBy] = 'Unknown';
        }
      }
    }

    return userNames;
  }

  // Load all topics from Firestore
  Future<List<Topic>> loadTopics() async {
    try {
      QuerySnapshot topicSnapshot = await _firestore.collection('topics').get();
      return topicSnapshot.docs.map((doc) {
        return Topic.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error loading topics: $e');
      return [];
    }
  }

  // Load all procedures from Firestore
  Future<List<Procedure>> loadProcedures() async {
    try {
      QuerySnapshot procedureSnapshot =
          await _firestore.collection('procedures').get();
      return procedureSnapshot.docs.map((doc) {
        return Procedure.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error loading procedures: $e');
      return [];
    }
  }

  // Load all bookmarked procedures for a specific user
  Future<List<Procedure>> loadBookmarkedProcedures(String userId) async {
    try {
      QuerySnapshot bookmarkedProceduresSnapshot = await _firestore
          .collection('procedures')
          .where('createdBy', isEqualTo: userId)
          .where('isPersonal', isEqualTo: true)
          .get();
      return bookmarkedProceduresSnapshot.docs.map((doc) {
        return Procedure.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error loading bookmarked procedures: $e');
      return [];
    }
  }

  // Add a new topic
  Future<String?> addNewTopic(String title, String userId) async {
    try {
      DocumentReference docRef = await _firestore.collection('topics').add({
        'title': title,
        'createdBy': userId,
      });
      return docRef.id;
    } catch (e) {
      print('Failed to add topic: $e');
      return null;
    }
  }

  // Add a new procedure
  Future<String?> addNewProcedure(String title, List<String> steps,
      String? topicId, String userId, bool isPersonal) async {
    try {
      Map<String, dynamic> procedureData = {
        'title': title,
        'steps': steps,
        'createdBy': userId,
        'isPersonal': isPersonal,
      };
      if (topicId != null) {
        procedureData['topicId'] = topicId;
      }

      DocumentReference docRef =
          await _firestore.collection('procedures').add(procedureData);
      return docRef.id;
    } catch (e) {
      print('Failed to add procedure: $e');
      return null;
    }
  }

  // Edit a procedure
  Future<void> editProcedure(
      String? procedureId, String newTitle, List<String> newSteps) async {
    try {
      await _firestore.collection('procedures').doc(procedureId).update({
        'title': newTitle,
        'steps': newSteps,
      });
    } catch (e) {
      print('Failed to edit procedure: $e');
    }
  }

  // Remove a procedure
  Future<void> removeProcedure(Procedure procedure) async {
    try {
      await _firestore.collection('procedures').doc(procedure.id).delete();
    } catch (e) {
      print('Failed to remove procedure: $e');
    }
  }

  Future<void> removeTopic(String topicId) async {
    try {
      await _firestore.collection('topics').doc(topicId).delete();
    } catch (e) {
      throw Exception('Failed to delete topic: $e');
    }
  }

  Future<Procedure> deepCopyProcedure(
      Procedure procedure, String currentUserId) async {
    // Create a new Procedure instance for deep copying without an ID
    final newProcedure = Procedure(
      title: procedure.title,
      steps: List<String>.from(procedure.steps),
      topicId: null, // No specific topic for personal bookmarks
      createdBy: currentUserId,
      isPersonal: true,
    );

    // Save the new procedure to Firestore and let Firebase generate the ID
    DocumentReference docRef =
        await _firestore.collection('procedures').add(newProcedure.toJson());

    // Assign the generated Firestore ID to the new procedure
    newProcedure.id = docRef.id;

    return newProcedure;
  }
}
