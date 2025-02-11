import 'package:dart_mappable/dart_mappable.dart';

part 'models.mapper.dart';

@MappableEnum()
enum TaskStatus {
  pending,
  completed,
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class TaskCreate with TaskCreateMappable {
  final String title;
  final String? description;
  final DateTime dueDate;

  const TaskCreate(
      {required this.title, required this.description, required this.dueDate});

  static const fromJson = TaskCreateMapper.fromJson;
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class Task with TaskMappable {
  final int id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskStatus status;
  final int repeatInterval;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.repeatInterval,
  });

  static const fromJson = TaskMapper.fromJson;
}
