import 'package:hive/hive.dart';
import 'package:to_do_app/models/todo.dart';
import 'package:to_do_app/repo/auth_repository.dart';
import 'package:to_do_app/repo/firestore_repository.dart';

class SyncService {
  final Box<ToDo> todoBox;
  final FirestoreRepository firestoreRepository;
  final AuthRepository authRepository;

  SyncService({
    required this.todoBox,
    required this.firestoreRepository,
    required this.authRepository,
  });

  Future<void> syncToFirestore() async {
    final user = authRepository.getCurrentUser();
    if (user != null) {
      final todos = todoBox.values.toList();

      for (var todo in todos) {
        await firestoreRepository.addToDo(todo, user.uid);  // Sync each ToDo to Firestore
      }
    }
  }
}
