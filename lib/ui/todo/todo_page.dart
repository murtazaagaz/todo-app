import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:to_do_app/bloc/todo_bloc/todo_bloc.dart';
import 'package:to_do_app/bloc/todo_bloc/todo_event.dart';
import 'package:to_do_app/bloc/todo_bloc/todo_state.dart';
import 'package:to_do_app/generated/l10n.dart';
import 'package:to_do_app/models/todo.dart';
import 'package:to_do_app/repo/auth_repository.dart';
import 'package:to_do_app/repo/firestore_repository.dart';
import 'package:to_do_app/ui/auth/auth_screen.dart';
import 'package:to_do_app/ui/todo/add_todo.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Hive.openBox<ToDo>('todoBox'), // Open Hive box for local storage
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final Box<ToDo> todoBox = Hive.box<ToDo>('todoBox');

          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider(create: (context) => AuthRepository()),
              RepositoryProvider(create: (context) => FirestoreRepository()),
            ],
            child: BlocProvider(
              create: (context) => ToDoBloc(
                todoBox: todoBox,
                firestoreRepository:
                    RepositoryProvider.of<FirestoreRepository>(context),
                authRepository: RepositoryProvider.of<AuthRepository>(context),
              )..add(LoadToDos()), // Trigger loading of ToDos
              child:
                  const ToDoScreen(), // The screen that displays the ToDo items
            ),
          );
        } else {
          return const CircularProgressIndicator(); // Loading indicator while Hive box is being opened
        }
      },
    );
  }
}

class ToDoScreen extends StatelessWidget {
  const ToDoScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).todoApp),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
                onTap: () async {
                  await RepositoryProvider.of<AuthRepository>(context)
                      .signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()));
                },
                child: const Icon(Icons.logout)),
          )
        ],
      ),
      body: BlocBuilder<ToDoBloc, ToDoState>(
        builder: (context, state) {
          if (state is Navigate) {
            return const AddToDoScreen();
          }
          if (state is ToDoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ToDoLoaded) {
            final todos = state.todos;

            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo.title),
                  trailing: Checkbox(
                    value: todo.completed,
                    onChanged: (value) {
                      context.read<ToDoBloc>().add(ToggleToDo(todo.id));
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Failed to load ToDos'));
          }
        },
      ),
      floatingActionButton: BlocBuilder<ToDoBloc, ToDoState>(
        builder: (context, state) {
          if (state is! Navigate) {
            return FloatingActionButton(
              onPressed: () async {
                // Add new ToDo logic
                context.read<ToDoBloc>().add(const NavigateToAddTodo());
              },
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
