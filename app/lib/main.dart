import 'package:flutter/material.dart';

void main() {
  runApp(const TaskPulseApp());
}

class TaskPulseApp extends StatefulWidget {
  const TaskPulseApp({super.key});

  @override
  State<TaskPulseApp> createState() => _TaskPulseAppState();
}

class _TaskPulseAppState extends State<TaskPulseApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskPulse Dashboard',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: const CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardTheme: const CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: DashboardScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark ||
            (_themeMode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark),
      ),
    );
  }
}

class TaskItem {
  final String id;
  String title;
  String category;
  DateTime dueDate;
  bool isCompleted;
  Priority priority;

  TaskItem({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = Priority.medium,
  });
}

enum Priority { low, medium, high }

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const DashboardScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = 'All';

  final List<TaskItem> _tasks = [
    TaskItem(
      id: '1',
      title: 'Design Mobile App Wireframes',
      category: 'Design',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: Priority.high,
    ),
    TaskItem(
      id: '2',
      title: 'Fix CI/CD Pipeline Build Error',
      category: 'DevOps',
      dueDate: DateTime.now(),
      isCompleted: true,
      priority: Priority.high,
    ),
    TaskItem(
      id: '3',
      title: 'Review Pull Requests',
      category: 'Development',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      priority: Priority.medium,
    ),
    TaskItem(
      id: '4',
      title: 'Client Sprint Planning Meeting',
      category: 'Management',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      priority: Priority.low,
    ),
    TaskItem(
      id: '5',
      title: 'Update API Documentation',
      category: 'Development',
      dueDate: DateTime.now().add(const Duration(days: 4)),
      priority: Priority.medium,
    ),
  ];

  void _addNewTask(String title, String category, Priority priority) {
    setState(() {
      _tasks.add(
        TaskItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          category: category,
          dueDate: DateTime.now().add(const Duration(days: 1)),
          priority: priority,
        ),
      );
    });
  }

  void _toggleTaskStatus(String id) {
    setState(() {
      final task = _tasks.firstWhere((element) => element.id == id);
      task.isCompleted = !task.isCompleted;
    });
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((element) => element.id == id);
    });
  }

  List<TaskItem> get _filteredTasks {
    if (_selectedCategory == 'All') return _tasks;
    return _tasks.where((t) => t.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.bolt_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'TaskPulse',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              child: Icon(
                Icons.person_rounded,
                size: 22,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(context, isDark),
          _buildProjectsTab(context),
          _buildAnalyticsTab(context),
          _buildProfileTab(context),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddTaskDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Task'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_rounded),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, bool isDark) {
    final completedCount = _tasks.where((t) => t.isCompleted).length;
    final totalCount = _tasks.length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF4F46E5), const Color(0xFF7C3AED)]
                    : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Welcome back, Developer! 👋',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        // Using explicit opacity safely
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Sprint 24',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Your daily target is almost complete.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Overview Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Tasks',
                  value: '$totalCount',
                  icon: Icons.assignment_outlined,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Completed',
                  value: '$completedCount',
                  icon: Icons.check_circle_outline_rounded,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Pending',
                  value: '${totalCount - completedCount}',
                  icon: Icons.pending_actions_rounded,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Task Category Filter Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: _selectedCategory,
                underline: const SizedBox(),
                borderRadius: BorderRadius.circular(12),
                items: ['All', 'Design', 'DevOps', 'Development', 'Management']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Task List
          _filteredTasks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.task_alt_rounded,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No tasks in this category!',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = _filteredTasks[index];
                    return _buildTaskCard(task);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskItem task) {
    final theme = Theme.of(context);

    Color priorityColor;
    switch (task.priority) {
      case Priority.high:
        priorityColor = Colors.red;
        break;
      case Priority.medium:
        priorityColor = Colors.amber;
        break;
      case Priority.low:
        priorityColor = Colors.green;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile,
      // Wrap tile manually to handle tap & dismissible properly
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _toggleTaskStatus(task.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                shape: const CircleBorder(),
                onChanged: (_) => _toggleTaskStatus(task.id),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? theme.colorScheme.onSurface.withOpacity(0.4)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            task.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.priority.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: theme.colorScheme.error.withOpacity(0.7),
                onPressed: () => _deleteTask(task.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsTab(BuildContext context) {
    final projects = [
      {
        'title': 'Mobile App Redesign',
        'progress': 0.75,
        'tasks': '12/16 Completed',
        'color': Colors.indigo
      },
      {
        'title': 'Cloud Infrastructure Migration',
        'progress': 0.40,
        'tasks': '4/10 Completed',
        'color': Colors.teal
      },
      {
        'title': 'E-Commerce Storefront',
        'progress': 0.90,
        'tasks': '18/20 Completed',
        'color': Colors.deepOrange
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final p = projects[index];
        final color = p['color'] as Color;
        final progress = p['progress'] as double;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.more_horiz_rounded,
                        color: Theme.of(context).hintColor),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  p['tasks'] as String,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 6,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Performance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAlignment.end,
                  children: [
                    _buildBar(context, 'Mon', 0.4),
                    _buildBar(context, 'Tue', 0.8),
                    _buildBar(context, 'Wed', 0.65),
                    _buildBar(context, 'Thu', 0.9),
                    _buildBar(context, 'Fri', 0.5),
                    _buildBar(context, 'Sat', 0.2),
                    _buildBar(context, 'Sun', 0.3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, String day, double heightFactor) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FractionallySizedBox(
          heightFactor: heightFactor,
          child: Container(
            width: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 48,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            child: Icon(
              Icons.person_rounded,
              size: 56,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Alex Developer',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'alex.dev@example.com',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none_rounded),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: const Text('Security'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    String selectedCategory = 'Development';
    Priority selectedPriority = Priority.medium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create New Task',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Design', 'DevOps', 'Development', 'Management']
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedCategory = val;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<Priority>(
                        value: selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                        ),
                        items: Priority.values
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.name.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedPriority = val;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isNotEmpty) {
                        _addNewTask(
                          titleController.text.trim(),
                          selectedCategory,
                          selectedPriority,
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Add Task'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}