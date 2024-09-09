import 'package:equatable/equatable.dart';

abstract class ToDoEvent extends Equatable {
  const ToDoEvent();

  @override
  List<Object?> get props => [];
}

class LoadToDos extends ToDoEvent {}

class AddToDo extends ToDoEvent {
  final String title;

  const AddToDo(this.title);

  @override
  List<Object?> get props => [title];
}


class ToggleToDo extends ToDoEvent {
  final String id;

  const ToggleToDo(this.id);

  @override
  List<Object?> get props => [id];
}
class NavigateToAddTodo extends ToDoEvent {

  const NavigateToAddTodo();

  @override
  List<Object?> get props => [];
}
