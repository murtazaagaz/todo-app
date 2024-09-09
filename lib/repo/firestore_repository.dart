import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_app/models/todo.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore;

  FirestoreRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Add ToDo to Firestore
  Future<void> addToDo(ToDo todo, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('todos').doc(todo.id).set({
        'title': todo.title,
        'completed': todo.completed,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
    }
  }

  // Update ToDo in Firestore
  Future<void> updateToDo(ToDo todo, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('todos').doc(todo.id).update({
        'completed': todo.completed,
      });
    } catch (e) {
      print(e);
    }
  }

  // Delete ToDo from Firestore
  Future<void> deleteToDo(String todoId, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('todos').doc(todoId).delete();
    } catch (e) {
      print(e);
    }
  }

  // Fetch ToDos from Firestore
  Stream<List<ToDo>> fetchToDos(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return ToDo(
                id: doc.id,
                title: data['title'] as String,
                completed: data['completed'] as bool,
              );
            }).toList());
  }
}
