import 'package:dart_mappable/dart_mappable.dart';

part 'models.mapper.dart';

class DateTimeHook extends MappingHook {
  const DateTimeHook();

  @override
  Object? afterDecode(Object? value) {
    if (value is DateTime) {
      return value.copyWith(isUtc: true).toLocal();
    }
    return super.afterDecode(value);
  }

  @override
  Object? beforeEncode(Object? value) {
    if (value is DateTime) {
      return value. toUtc();
    }
    return super.beforeEncode(value);
  }
}

@MappableEnum()
enum TaskStatus {
  pending,
  completed,
}

@MappableClass(caseStyle: CaseStyle.snakeCase)
class TaskCreate with TaskCreateMappable {
  final String title;
  final String? description;
  @MappableField(hook: DateTimeHook())
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
  @MappableField(hook: DateTimeHook())
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
