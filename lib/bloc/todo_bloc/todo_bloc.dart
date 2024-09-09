import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/models/todo.dart';
import 'package:to_do_app/repo/auth_repository.dart';
import 'package:to_do_app/repo/firestore_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';
import 'package:hive/hive.dart';

class ToDoBloc extends Bloc<ToDoEvent, ToDoState> {
  final Box<ToDo> todoBox;
  final FirestoreRepository firestoreRepository;
  final AuthRepository authRepository;

  ToDoBloc({
    required this.todoBox,
    required this.firestoreRepository,
    required this.authRepository,
  }) : super(ToDoLoading()) {
    on<LoadToDos>(loadTodo);

    on<AddToDo>(addTodo);

    on<ToggleToDo>(toggleTodo);
    
    on<NavigateToAddTodo>(
      (event, emit) => emit(Navigate()),
    );
  }

  loadTodo(event, emit) async {
    final todos = todoBox.values.toList();
    emit(ToDoLoaded(todos));

    final user = authRepository.getCurrentUser();
    if (user != null) {
      firestoreRepository.fetchToDos(user.uid).listen((cloudToDos) {
        for (var todo in cloudToDos) {
          todoBox.put(
              todo.id, todo); // Update local database with Firebase data
        }
        emit(ToDoLoaded(todoBox.values.toList()));
      });
    }
  }

  addTodo(event, emit) async {
    emit(ToDoLoading());

    try {
      final newToDo = ToDo(
        id: DateTime.now().toString(),
        title: event.title,
      );
      await todoBox.put(newToDo.id, newToDo);
      final user = authRepository.getCurrentUser();
      if (user != null) {
        await firestoreRepository.addToDo(
            newToDo, user.uid); // Sync with Firestore
      }
      final todos = todoBox.values.toList();

      emit(ToDoLoaded(todos));
    } catch (_) {}
  }

  toggleTodo(event, emit) async {
    final todo = todoBox.get(event.id);
    if (todo != null) {
      final updatedToDo = ToDo(
        id: todo.id,
        title: todo.title,
        completed: !todo.completed,
      );
      await todoBox.put(event.id, updatedToDo);
      final user = authRepository.getCurrentUser();
      if (user != null) {
        await firestoreRepository.updateToDo(
            updatedToDo, user.uid); // Sync with Firestore
      }
      final todos = todoBox.values.toList();
      emit(ToDoLoaded(todos));
    }
  }
}
