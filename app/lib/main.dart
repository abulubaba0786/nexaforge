import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const TaskifyApp());
}

class TaskifyApp extends StatefulWidget {
  const TaskifyApp({super.key});

  @override
  State<TaskifyApp> createState() => _TaskifyAppState();
}

class _TaskifyAppState extends State<TaskifyApp> {
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
      title: 'Taskify Workspace',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF818CF8),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF1E293B),
          margin: EdgeInsets.zero,
        ),
      ),
      home: MainNavigationScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

// Model Classes
enum TaskPriority { low, medium, high }

class TaskItem {
  final String id;
  String title;
  String description;
  String category;
  DateTime dueDate;
  TaskPriority priority;
  bool isCompleted;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });
}

class ProjectItem {
  final String id;
  final String name;
  final String description;
  final double progress;
  final Color color;
  final int totalTasks;
  final int completedTasks;

  ProjectItem({
    required this.id,
    required this.name,
    required this.description,
    required this.progress,
    required this.color,
    required this.totalTasks,
    required this.completedTasks,
  });
}

// Main Navigation Widget
class MainNavigationScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const MainNavigationScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<TaskItem> _tasks = [
    TaskItem(
      id: '1',
      title: 'Design System Architecture',
      description: 'Create reusable UI tokens and component guidelines',
      category: 'Design',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: TaskPriority.high,
      isCompleted: false,
    ),
    TaskItem(
      id: '2',
      title: 'Implement CI/CD Build Pipeline',
      description: 'Ensure automated Android and iOS builds run cleanly',
      category: 'DevOps',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      priority: TaskPriority.high,
      isCompleted: true,
    ),
    TaskItem(
      id: '3',
      title: 'User Authentication Flow',
      description: 'Integrate OAuth2 authentication and refreshToken logic',
      category: 'Development',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      priority: TaskPriority.medium,
      isCompleted: false,
    ),
    TaskItem(
      id: '4',
      title: 'Database Migration Script',
      description: 'Prepare PostgreSQL migration schema for v2 release',
      category: 'Backend',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      priority: TaskPriority.low,
      isCompleted: false,
    ),
  ];

  final List<ProjectItem> _projects = [
    ProjectItem(
      id: 'p1',
      name: 'Mobile App Refactor',
      description: 'Migrating codebase to Material 3 & Clean Architecture',
      progress: 0.75,
      color: const Color(0xFF6366F1),
      totalTasks: 16,
      completedTasks: 12,
    ),
    ProjectItem(
      id: 'p2',
      name: 'E-Commerce Platform',
      description: 'Building modern shopping portal with payment gateway',
      progress: 0.40,
      color: const Color(0xFF10B981),
      totalTasks: 20,
      completedTasks: 8,
    ),
    ProjectItem(
      id: 'p3',
      name: 'Analytics Dashboard',
      description: 'Data visualizer dashboard for executive reporting',
      progress: 0.90,
      color: const Color(0xFFF59E0B),
      totalTasks: 10,
      completedTasks: 9,
    ),
  ];

  void _addTask(TaskItem newTask) {
    setState(() {
      _tasks.insert(0, newTask);
    });
  }

  void _toggleTaskStatus(String id) {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index].isCompleted = !_tasks[index].isCompleted;
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((task) => task.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardTab(
        tasks: _tasks,
        projects: _projects,
        onToggleTask: _toggleTaskStatus,
      ),
      TasksTab(
        tasks: _tasks,
        onToggleTask: _toggleTaskStatus,
        onDeleteTask: _deleteTask,
        onAddTask: _addTask,
      ),
      ProjectsTab(projects: _projects),
      AnalyticsTab(tasks: _tasks),
      SettingsTab(
        isDarkMode: widget.isDarkMode,
        onToggleTheme: widget.onToggleTheme,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Dashboard Tab
class DashboardTab extends StatelessWidget {
  final List<TaskItem> tasks;
  final List<ProjectItem> projects;
  final Function(String) onToggleTask;

  const DashboardTab({
    super.key,
    required this.tasks,
    required this.projects,
    required this.onToggleTask,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final pendingCount = tasks.length - completedCount;
    final completionRate = tasks.isEmpty ? 0.0 : (completedCount / tasks.length);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Alex Developer',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  'AD',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Overview Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Productivity',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(completionRate * 100).toInt()}% Tasks Done',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$pendingCount tasks remaining for this week',
                        style: const TextStyle(
                          color: Colors.white90,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 70,
                  height: 70,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: completionRate,
                        strokeWidth: 8,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                      ),
                      Center(
                        child: Text(
                          '${(completionRate * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Tasks',
                  value: '${tasks.length}',
                  icon: Icons.task_alt,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Completed',
                  value: '$completedCount',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Pending',
                  value: '$pendingCount',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Weekly Activity Chart Section
          Text(
            'Activity Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: SizedBox(
              height: 140,
              child: CustomPaint(
                painter: ActivityBarChartPainter(
                  barColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Container(),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Recent Tasks Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Tasks',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: math.min(3, tasks.length),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => onToggleTask(task.id),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(task.category),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.priority.name.toUpperCase(),
                      style: TextStyle(
                        color: _getPriorityColor(task.priority),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }
}

// Widget for Stat Card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Activity Bar Chart
class ActivityBarChartPainter extends CustomPainter {
  final Color barColor;
  final Color backgroundColor;

  ActivityBarChartPainter({
    required this.barColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double barWidth = size.width / 15;
    final List<double> values = [0.4, 0.7, 0.3, 0.9, 0.6, 0.8, 0.5];
    final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final Paint bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final Paint barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final double spacing = (size.width - (barWidth * values.length)) / (values.length + 1);

    for (int i = 0; i < values.length; i++) {
      final double x = spacing + i * (barWidth + spacing);
      final double maxBarHeight = size.height - 24;

      // Background Bar
      final RRect bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, barWidth, maxBarHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(bgRect, bgPaint);

      // Active Bar
      final double activeHeight = maxBarHeight * values[i];
      final RRect activeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, maxBarHeight - activeHeight, barWidth, activeHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(activeRect, barPaint);

      // Day Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: days[i],
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, size.height - 18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Tasks Tab
class TasksTab extends StatefulWidget {
  final List<TaskItem> tasks;
  final Function(String) onToggleTask;
  final Function(String) onDeleteTask;
  final Function(TaskItem) onAddTask;

  const TasksTab({
    super.key,
    required this.tasks,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onAddTask,
  });

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  List<TaskItem> get filteredTasks {
    return widget.tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.category.toLowerCase().contains(_searchQuery.toLowerCase());

      if (_selectedFilter == 'Pending') {
        return matchesSearch && !task.isCompleted;
      } else if (_selectedFilter == 'Completed') {
        return matchesSearch && task.isCompleted;
      }
      return matchesSearch;
    }).toList();
  }

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddTaskBottomSheet(onAddTask: widget.onAddTask),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskSheet,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasks',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filter Chips
            Row(
              children: ['All', 'Pending', 'Completed'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filter),
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Tasks List
            Expanded(
              child: filteredTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No tasks found',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Dismissible(
                          key: Key(task.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => widget.onDeleteTask(task.id),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: task.isCompleted,
                                    onChanged: (_) => widget.onToggleTask(task.id),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            decoration: task.isCompleted
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                          ),
                                        ),
                                        if (task.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            task.description,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Chip(
                                              padding: EdgeInsets.zero,
                                              label: Text(
                                                task.category,
                                                style: const TextStyle(fontSize: 11),
                                              ),
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.calendar_today,
                                              size: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add Task Bottom Sheet
class AddTaskBottomSheet extends StatefulWidget {
  final Function(TaskItem) onAddTask;

  const AddTaskBottomSheet({super.key, required this.onAddTask});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'Development';
  TaskPriority _priority = TaskPriority.medium;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  @override, visualDensity: VisualDensity.compact
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Task',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: ['Development', 'Design', 'Backend', 'DevOps', 'General']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Priority: '),
                  const SizedBox(width: 12),
                  SegmentedButton<TaskPriority>(
                    segments: const [
                      ButtonSegment(value: TaskPriority.low, label: Text('Low')),
                      ButtonSegment(value: TaskPriority.medium, label: Text('Med')),
                      ButtonSegment(value: TaskPriority.high, label: Text('High')),
                    ],
                    selected: {_priority},
                    onSelectionChanged: (Set<TaskPriority> selected) {
                      setState(() {
                        _priority = selected.first;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newTask = TaskItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _titleController.text,
                        description: _descController.text,
                        category: _category,
                        dueDate: _selectedDate,
                        priority: _priority,
                      );
                      widget.onAddTask(newTask);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Task'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Projects Tab
class ProjectsTab extends StatelessWidget {
  final List<ProjectItem> projects;

  const ProjectsTab({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Projects',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: project.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(project.progress * 100).toInt()}%',
                                style: TextStyle(
                                  color: project.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project.description,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: project.progress,
                          color: project.color,
                          backgroundColor: project.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${project.completedTasks}/${project.totalTasks} Tasks Done',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 14),
                          ],
                        ),
                      ],
                    ),
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

// Analytics Tab
class AnalyticsTab extends StatelessWidget {
  final List<TaskItem> tasks;

  const AnalyticsTab({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((t) => t.isCompleted).length;
    final pending = tasks.length - completed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),

          // Donut Chart Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Task Breakdown',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 160,
                  width: 160,
                  child: CustomPaint(
                    painter: DonutChartPainter(
                      completed: completed.toDouble(),
                      pending: pending.toDouble(),
                      completedColor: Theme.of(context).colorScheme.primary,
                      pendingColor: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(
                      color: Theme.of(context).colorScheme.primary,
                      label: 'Completed ($completed)',
                    ),
                    const SizedBox(width: 20),
                    _LegendItem(
                      color: Colors.amber,
                      label: 'Pending ($pending)',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Efficiency Metrics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.speed, color: Colors.indigo),
                    title: Text('Average Completion Time'),
                    trailing: Text('1.8 Days', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.star_outline, color: Colors.orange),
                    title: Text('Productivity Score'),
                    trailing: Text('92 / 100', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Donut Chart Painter
class DonutChartPainter extends CustomPainter {
  final double completed;
  final double pending;
  final Color completedColor;
  final Color pendingColor;

  DonutChartPainter({
    required this.completed,
    required this.pending,
    required this.completedColor,
    required this.pendingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double total = completed + pending;
    if (total == 0) return;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) / 2;
    final double strokeWidth = 24.0;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double completedAngle = (completed / total) * 2 * math.pi;
    final double pendingAngle = (pending / total) * 2 * math.pi;

    // Completed Arc
    paint.color = completedColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      completedAngle,
      false,
      paint,
    );

    // Pending Arc
    paint.color = pendingColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2 + completedAngle,
      pendingAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

// Settings Tab
class SettingsTab extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const SettingsTab({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle app color theme'),
                  secondary: const Icon(Icons.brightness_6),
                  value: isDarkMode,
                  onChanged: (_) => onToggleTheme(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  subtitle: const Text('Manage push alerts and reminders'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Privacy & Security'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App Version'),
              subtitle: const Text('v2.4.0 (Build 108)'),
            ),
          ),
        ],
      ),
    );
  }
}