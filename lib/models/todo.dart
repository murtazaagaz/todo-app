import 'package:hive/hive.dart';

part 'todo.g.dart';  // Needed for code generation

@HiveType(typeId: 0)
class ToDo {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
   bool completed;

  ToDo({
    required this.id,
    required this.title,
    this.completed = false,
  });
}