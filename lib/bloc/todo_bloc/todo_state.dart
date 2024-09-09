import 'package:equatable/equatable.dart';
import 'package:to_do_app/models/todo.dart';

abstract class ToDoState extends Equatable {
  const ToDoState();

  @override
  List<Object?> get props => [];
}

class ToDoLoading extends ToDoState {}

class ToDoLoaded extends ToDoState {
  final List<ToDo> todos;

  const ToDoLoaded([this.todos = const []]);

  @override
  List<Object?> get props => [todos];
}

class Navigate extends ToDoState {}
