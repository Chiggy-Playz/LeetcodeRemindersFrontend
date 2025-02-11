import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/client.dart';
import 'package:frontend/extensions.dart';
import 'package:frontend/models.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<List<Task>>(
        future: taskClient.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final now = DateTime.now()
              .copyWith(hour: 23, minute: 59, second: 59, microsecond: 0);

          final allTasks = snapshot.data!;

          final tasksDue = <Task>[];
          final futureTasks = <Task>[];
          final completedTasks = <Task>[];

          for (var task in allTasks) {
            if (task.status == TaskStatus.completed) {
              completedTasks.add(task);
            } else if (task.dueDate.isBefore(now)) {
              tasksDue.add(task);
            } else {
              futureTasks.add(task);
            }
          }

          return ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      "Solved any leetcode problem today?",
                      style: context.textTheme.titleLarge,
                    ),
                  ),
                  ListTile(
                    title: Form(
                      key: key,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Problem ID',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.send,
                              color: context.colorScheme.primary,
                            ),
                            onPressed: () async {
                              key.currentState!.save();
                            },
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a problem ID';
                          }
                          final parsed = int.tryParse(value);
                          if (parsed == null || parsed <= 0) {
                            return 'Invalid problem ID';
                          }
                          return null;
                        },
                        onSaved: (value) async {
                          if (!key.currentState!.validate()) return;
                          final parsed = int.parse(value!);
                          final task = TaskCreate(
                            title: "Problem $parsed",
                            description: null,
                            dueDate: DateTime.now()
                                .add(
                                  const Duration(days: 1),
                                )
                                .toUtc(),
                          );
                          await taskClient.createTask(task);
                          key.currentState!.reset();
                          // Refetch tasks after creating a new one.
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
              tasksDue.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: Text('No tasks due today =D')),
                    )
                  : Column(
                      children: <Widget>[const Divider()] +
                          tasksDue.map((task) {
                            return Card(
                              child: ListTile(
                                title: Text(task.title),
                                subtitle: task.description != null &&
                                        task.description!.isNotEmpty
                                    ? Text(task.description!)
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check),
                                      onPressed: () async {
                                        await taskClient.completeTask(task.id);
                                        setState(() {});
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        await taskClient.deleteTask(task.id);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
              Theme(
                data: context.theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text('Pending Tasks'),
                  children: futureTasks.map(
                    (futureTask) {
                      return Card(
                        child: ListTile(
                          title: Text(futureTask.title),
                          subtitle: Text(
                              "${futureTask.description ?? ''}\n${futureTask.dueDate.toLocal().toFormattedString(DateTimeFormat.dateTime)}"
                                  .trim()),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              Theme(
                data: context.theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text('Completed Tasks'),
                  children: completedTasks.map(
                    (completedTask) {
                      return Card(
                        child: ListTile(
                          title: Text(completedTask.title),
                          subtitle: Text(
                              "${completedTask.description ?? ''}\n${completedTask.dueDate.toLocal().toFormattedString(DateTimeFormat.dateTime)}"
                                  .trim()),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          );
        },
      ),
    ));
  }
}
