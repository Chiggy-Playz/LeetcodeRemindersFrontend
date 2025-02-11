import 'package:dio/dio.dart';
import 'package:frontend/models.dart';
import 'package:retrofit/retrofit.dart';

part 'client.g.dart';

@RestApi(baseUrl: '/api')
abstract class TaskClient {
  factory TaskClient(Dio dio, {String? baseUrl}) = _TaskClient;

  @GET('/tasks')
  Future<List<Task>> getTasks();

  @GET('/tasks/{id}')
  Future<Task> getTaskById(@Path() int id);

  @GET('/tasks/today')
  Future<List<Task>> getTodayTasks();

  @POST('/tasks')
  Future<void> createTask(@Body() TaskCreate task);

  @PUT('/tasks/{id}/complete')
  Future<void> completeTask(@Path() int id);

  @DELETE('/tasks/{id}')
  Future<void> deleteTask(@Path() int id);
}

final taskClient = TaskClient(Dio());
