import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Kişisel Asistan',
          theme:
              themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: const MainPage(),
        );
      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menü',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Notlar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Görevler'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TasksScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Hatırlatıcılar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RemindersScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const WeatherScreen(),
          Expanded(
            child: Column(
              children: const [
                Expanded(child: NotesList()),
                Divider(),
                Expanded(child: TasksList()),
                Divider(),
                Expanded(child: RemindersList()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: ListTile(
          title: Text('Bugün: 25°C, Hava: Açık'),
          subtitle: Text('İstanbul'),
        ),
      ),
    );
  }
}

class NotesList extends StatelessWidget {
  const NotesList({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotesProvider>().notes;

    if (notes.isEmpty) {
      return const Center(
        child: Text(
          'Hiç not bulunamadı.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(note.title),
        );
      },
    );
  }
}

class TasksList extends StatelessWidget {
  const TasksList({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;

    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'Hiç görev bulunamadı.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        );
      },
    );
  }
}

class RemindersList extends StatelessWidget {
  const RemindersList({super.key});

  @override
  Widget build(BuildContext context) {
    final reminders = context.watch<ReminderProvider>().reminders;

    if (reminders.isEmpty) {
      return const Center(
        child: Text(
          'Hiç hatırlatıcı bulunamadı.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return ListTile(
          title: Text(reminder.title),
          subtitle: Text(reminder.dateTime.toString()),
        );
      },
    );
  }
}

// (Kalan sınıflar değişmeden eklendi.)

class Notes {
  final String title;
  bool isCompleted;

  Notes({required this.title, this.isCompleted = false});
}

class NotesProvider extends ChangeNotifier {
  final List<Notes> _notes = [];

  List<Notes> get notes => _notes;

  void addNote(String title) {
    _notes.add(Notes(title: title));
    notifyListeners();
  }

  void deleteNote(int index) {
    if (index >= 0 && index < _notes.length) {
      _notes.removeAt(index);
      notifyListeners();
    }
  }
}

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notlar'),
      ),
      body: notesProvider.notes.isEmpty
          ? Center(
              child: Text(
                'Hiç not bulunamadı.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: notesProvider.notes.length,
              itemBuilder: (context, index) {
                final note = notesProvider.notes[index];
                return ListTile(
                  title: Text(note.title),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      notesProvider.deleteNote(index);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
        onPressed: () {
          _showAddNoteDialog(context, notesProvider);
        },
      ),
    );
  }
}

void _showAddNoteDialog(BuildContext context, NotesProvider notesProvider) {
  final TextEditingController noteController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Yeni Not'),
        content: TextField(
          controller: noteController,
          decoration: InputDecoration(hintText: 'Not girin'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                notesProvider.addNote(noteController.text);
                Navigator.of(context).pop();
              }
            },
            child: Text('Ekle'),
          ),
        ],
      );
    },
  );
}

class Task {
  final String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false});
}

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(String title) {
    _tasks.add(Task(title: title));
    notifyListeners();
  }

  void toggleTask(int index) {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    notifyListeners();
  }

  void removeTask(int index) {
    _tasks.removeAt(index);
    notifyListeners();
  }
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görevler'),
      ),
      body: ListView.builder(
        itemCount: taskProvider.tasks.length,
        itemBuilder: (context, index) {
          final task = taskProvider.tasks[index];
          return ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    taskProvider.toggleTask(index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    taskProvider.removeTask(index);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
        onPressed: () {
          _showAddTaskDialog(context, taskProvider);
        },
      ),
    );
  }
}

void _showAddTaskDialog(BuildContext context, TaskProvider taskProvider) {
  final TextEditingController taskController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Yeni Görev'),
        content: TextField(
          controller: taskController,
          decoration: InputDecoration(hintText: 'Görev adı girin'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (taskController.text.isNotEmpty) {
                taskProvider
                    .addTask(taskController.text); // İçerik ekleyebilirsiniz
                Navigator.of(context).pop();
              }
            },
            child: Text('Ekle'),
          ),
        ],
      );
    },
  );
}

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reminderProvider = context.watch<ReminderProvider>();
    TextEditingController titleController = TextEditingController();
    DateTime selectedDateTime = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hatırlatıcılar'),
      ),
      body: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Hatırlatıcı Başlığı'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!context.mounted) return;
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: selectedDateTime,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (selectedDate != null) {
                if (!context.mounted) return;
                final selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                );

                if (selectedTime != null) {
                  selectedDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  reminderProvider.addReminder(
                    titleController.text,
                    selectedDateTime,
                  );
                }
              }
            },
            child: const Text('Hatırlatıcı Ekle'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reminderProvider.reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminderProvider.reminders[index];
                return ListTile(
                  title: Text(reminder.title),
                  subtitle: Text(reminder.dateTime.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      reminderProvider.deleteReminder(index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Karanlık Mod'),
            value: context.watch<ThemeProvider>().isDarkMode,
            onChanged: (value) {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class Reminder {
  final String title;
  final DateTime dateTime;

  Reminder({required this.title, required this.dateTime});
}

class ReminderProvider extends ChangeNotifier {
  final List<Reminder> _reminders = [];

  List<Reminder> get reminders => _reminders;

  void addReminder(String title, DateTime dateTime) {
    _reminders.add(Reminder(title: title, dateTime: dateTime));
    notifyListeners();
  }

  void deleteReminder(int index) {
    _reminders.removeAt(index);
    notifyListeners();
  }
}
