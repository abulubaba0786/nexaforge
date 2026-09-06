import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const NexaForgeOSApp());
}

/// Core OS Application Entry
class NexaForgeOSApp extends StatefulWidget {
  const NexaForgeOSApp({super.key});

  @override
  State<NexaForgeOSApp> createState() => _NexaForgeOSAppState();
}

class _NexaForgeOSAppState extends State<NexaForgeOSApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryCyan = Color(0xFF00E5FF);
    const darkBg = Color(0xFF0B0F19);
    const darkSurface = Color(0xFF151C2C);
    const darkBorder = Color(0xFF1F293D);

    return MaterialApp(
      title: 'NexaForge Base Core OS',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF00838F),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        cardTheme: CardTheme(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        colorScheme: const ColorScheme.dark(
          primary: primaryCyan,
          secondary: Color(0xFF8B5CF6),
          surface: darkSurface,
          background: darkBg,
          onSurface: Color(0xFFF3F4F6),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: darkBorder),
          ),
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: darkSurface,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: MainOSShell(onToggleTheme: _toggleTheme),
    );
  }
}

// ==========================================
// MODELS
// ==========================================

class ModuleModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String category;
  final String version;
  bool isInstalled;
  bool isEnabled;

  ModuleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.version,
    this.isInstalled = true,
    this.isEnabled = true,
  });
}

class ChatMessage {
  final String id;
  final String sender; // 'user', 'agent', 'system'
  final String text;
  final DateTime timestamp;
  final List<String>? actionSuggestions;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.actionSuggestions,
  });
}

// ==========================================
// MAIN OS SHELL
// ==========================================

class MainOSShell extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const MainOSShell({super.key, required this.onToggleTheme});

  @override
  State<MainOSShell> createState() => _MainOSShellState();
}

class _MainOSShellState extends State<MainOSShell> {
  int _currentNavIndex = 0;
  String _geminiApiKey = '';
  String _selectedAiModel = 'Gemini 1.5 Pro';
  bool _isAiOnline = true;

  // System State Data
  final List<ModuleModel> _modules = [
    ModuleModel(
      id: 'code_editor',
      name: 'Interactive Code Editor',
      description: 'Built-in IDE with syntax runner, live logs & line numbers.',
      icon: Icons.code_rounded,
      category: 'Developer',
      version: 'v2.4.0',
      isInstalled: true,
      isEnabled: true,
    ),
    ModuleModel(
      id: 'python_console',
      name: 'Python Runtime Console',
      description: 'Simulated micro-Python execution environment & REPL.',
      icon: Icons.terminal_rounded,
      category: 'Developer',
      version: 'v3.11.2',
      isInstalled: true,
      isEnabled: true,
    ),
    ModuleModel(
      id: 'file_manager',
      name: 'OS File Explorer',
      description: 'Manage core app assets, project files & local buffers.',
      icon: Icons.folder_copy_outlined,
      category: 'System',
      version: 'v1.0.8',
      isInstalled: true,
      isEnabled: false,
    ),
    ModuleModel(
      id: 'network_monitor',
      name: 'Network Diagnostics',
      description: 'Real-time bandwidth telemetry & API latency monitor.',
      icon: Icons.cell_tower_rounded,
      category: 'Telemetry',
      version: 'v1.2.0',
      isInstalled: false,
      isEnabled: false,
    ),
    ModuleModel(
      id: 'db_studio',
      name: 'SQLite Database Studio',
      description: 'Inspect local system tables and run query diagnostics.',
      icon: Icons.storage_rounded,
      category: 'Data',
      version: 'v0.9.5',
      isInstalled: true,
      isEnabled: true,
    ),
  ];

  late List<ChatMessage> _chatMessages;

  // Code Editor State
  String _selectedLanguage = 'Dart';
  final Map<String, TextEditingController> _codeControllers = {};
  String _consoleOutput = 'System initialized. Ready to execute scripts...\n';
  bool _isExecutingCode = false;

  @override
  void initState() {
    super.initState() {
      _chatMessages = [
        ChatMessage(
          id: '1',
          sender: 'agent',
          text:
              'Welcome to **NexaForge Core OS** v4.2. I am your resident AI Kernel Assistant. How can I help configure your modules or run scripts today?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          actionSuggestions: [
            'System Diagnostics',
            'Run Code Sample',
            'Install Modules'
          ],
        ),
      ];

      _codeControllers['Dart'] = TextEditingController(
        text: '''void main() {
  print("Initializing NexaForge Core Pipeline...");
  int coreThreads = 8;
  for (int i = 1; i <= 3; i++) {
    print("Executing core thread step \$i/\$coreThreads");
  }
  print("Operation completed with 0 errors.");
}''',
      );

      _codeControllers['Python'] = TextEditingController(
        text: '''import time

def run_telemetry():
    print("Fetching system diagnostics...")
    metrics = {"cpu_load": "18%", "ram_used": "4.2GB"}
    for key, val in metrics.items():
        print(f"-> {key}: {val}")
    print("Telemetry process finish.")

run_telemetry()''',
      );

      _codeControllers['JavaScript'] = TextEditingController(
        text: '''const systemStatus = {
  kernel: "NexaForge OS",
  uptime: "99.98%",
  status: "OPTIMAL"
};

console.log("Kernel Status Check:");
console.log(JSON.stringify(systemStatus, null, 2));''',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _codeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addChatMessage(
      String sender, String text, List<String>? suggestions) {
    setState(() {
      _chatMessages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: sender,
          text: text,
          timestamp: DateTime.now(),
          actionSuggestions: suggestions,
        ),
      );
    });
  }

  void _processAiCommand(String input) {
    if (input.trim().isEmpty) return;

    _addChatMessage('user', input, null);

    // AI Response Simulation Logic
    Timer(const Duration(milliseconds: 600), () {
      final lower = input.toLowerCase();
      if (lower.contains('diagnostics') || lower.contains('status')) {
        final activeCount = _modules.where((m) => m.isEnabled).length;
        _addChatMessage(
          'agent',
          '⚡ **System Health Status**: Optimal\n• Active Modules: $activeCount/${_modules.length}\n• Gemini API Key: ${_geminiApiKey.isEmpty ? "Not Set (Offline Mode)" : "Active"}\n• Core Memory Usage: 34%',
          ['Open Code Editor', 'Settings'],
        );
      } else if (lower.contains('install') || lower.contains('module')) {
        _addChatMessage(
          'agent',
          'Navigating to **Module Manager**. You can toggle core system features or install updates directly.',
          ['Open Module Manager'],
        );
      } else if (lower.contains('code') || lower.contains('run')) {
        _addChatMessage(
          'agent',
          'Opening the **Interactive Code Editor**. You can test Dart, Python, or JS execution pipelines.',
          ['Execute Current Code'],
        );
      } else {
        _addChatMessage(
          'agent',
          'Received command: "$input". Processing request via $_selectedAiModel kernel pipeline... Action simulated successfully.',
          ['Check System Status', 'Show Code Editor'],
        );
      }
    });
  }

  void _executeCode() async {
    setState(() {
      _isExecutingCode = true;
      _consoleOutput += '\n[${DateTime.now().toIso8601String().substring(11, 19)}] Compiling & Running $_selectedLanguage script...\n';
    });

    await Future.delayed(const Duration(milliseconds: 900));

    final code = _codeControllers[_selectedLanguage]?.text ?? '';
    String simulatedResult = '';

    if (_selectedLanguage == 'Dart') {
      simulatedResult = 'Initializing NexaForge Core Pipeline...\n'
          'Executing core thread step 1/8\n'
          'Executing core thread step 2/8\n'
          'Executing core thread step 3/8\n'
          'Operation completed with 0 errors.\nProcess finished with exit code 0.';
    } else if (_selectedLanguage == 'Python') {
      simulatedResult = 'Fetching system diagnostics...\n'
          '-> cpu_load: 18%\n'
          '-> ram_used: 4.2GB\n'
          'Telemetry process finish.\nProcess finished with exit code 0.';
    } else {
      simulatedResult = 'Kernel Status Check:\n'
          '{\n  "kernel": "NexaForge OS",\n  "uptime": "99.98%",\n  "status": "OPTIMAL"\n}\nProcess finished with exit code 0.';
    }

    if (mounted) {
      setState(() {
        _isExecutingCode = false;
        _consoleOutput += simulatedResult + '\n';
      });
    }
  }

  void _toggleModule(String id) {
    setState(() {
      final index = _modules.indexWhere((m) => m.id == id);
      if (index != -1) {
        _modules[index].isEnabled = !_modules[index].isEnabled;
      }
    });
  }

  void _installModule(String id) {
    setState(() {
      final index = _modules.indexWhere((m) => m.id == id);
      if (index != -1) {
        _modules[index].isInstalled = true;
        _modules[index].isEnabled = true;
      }
    });
  }

  void _showSettingsModal() {
    final apiKeyController = TextEditingController(text: _geminiApiKey);
    bool obscureKey = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.tune_rounded, color: Color(0xFF00E5FF)),
                SizedBox(width: 10),
                Text('Kernel Settings'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gemini API Key',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: apiKeyController,
                    obscureText: obscureKey,
                    decoration: InputDecoration(
                      hintText: 'Enter AI Key (e.g. AIzaSy...)',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(obscureKey
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () {
                          setDialogState(() {
                            obscureKey = !obscureKey;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AI Model Selector',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedAiModel,
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ['Gemini 1.5 Pro', 'Gemini Flash 1.5', 'Nexa-Local-7B']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          _selectedAiModel = val;
                        });
                        setState(() {
                          _selectedAiModel = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('AI Agent Live Status'),
                    subtitle: Text(_isAiOnline ? 'Online / Responsive' : 'Offline'),
                    value: _isAiOnline,
                    onChanged: (val) {
                      setDialogState(() {
                        _isAiOnline = val;
                      });
                      setState(() {
                        _isAiOnline = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _geminiApiKey = apiKeyController.text.trim();
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings saved successfully!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                child: const Text('Save Changes',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final pages = [
      DashboardView(
        modules: _modules,
        apiKeySet: _geminiApiKey.isNotEmpty,
        aiModel: _selectedAiModel,
        onNavigate: (index) => setState(() => _currentNavIndex = index),
        onOpenSettings: _showSettingsModal,
      ),
      AiConsoleView(
        messages: _chatMessages,
        onSendMessage: _processAiCommand,
        onActionTriggered: (action) {
          if (action.contains('Code')) {
            setState(() => _currentNavIndex = 2);
          } else if (action.contains('Module')) {
            setState(() => _currentNavIndex = 3);
          } else if (action.contains('Settings')) {
            _showSettingsModal();
          } else if (action.contains('Execute')) {
            setState(() => _currentNavIndex = 2);
            _executeCode();
          } else {
            _processAiCommand(action);
          }
        },
      ),
      CodeEditorView(
        selectedLanguage: _selectedLanguage,
        controllers: _codeControllers,
        consoleOutput: _consoleOutput,
        isExecuting: _isExecutingCode,
        onLanguageChanged: (lang) => setState(() => _selectedLanguage = lang),
        onRunCode: _executeCode,
        onClearConsole: () {
          setState(() {
            _consoleOutput = 'Console cleared.\n';
          });
        },
      ),
      ModuleManagerView(
        modules: _modules,
        onToggleModule: _toggleModule,
        onInstallModule: _installModule,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: isDesktop ? 24 : 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withOpacity(0.4),
                ),
              ),
              child: const Icon(Icons.memory_rounded,
                  color: Color(0xFF00E5FF), size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NexaForge OS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Core Kernel v4.2 • ${_isAiOnline ? "AI Active" : "AI Paused"}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_geminiApiKey.isEmpty
                ? Icons.key_off_outlined
                : Icons.vpn_key_rounded),
            color: _geminiApiKey.isEmpty ? Colors.amber : const Color(0xFF10B981),
            tooltip: 'Gemini Key Status',
            onPressed: _showSettingsModal,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showSettingsModal,
            tooltip: 'System Settings',
          ),
          IconButton(
            icon: const Icon(Icons.contrast_rounded),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop) ...[
            NavigationRail(
              selectedIndex: _currentNavIndex,
              onDestinationSelected: (index) {
                setState(() => _currentNavIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF151C2C),
                  child: Icon(Icons.developer_board, size: 20, color: Color(0xFF00E5FF)),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.smart_toy_outlined),
                  selectedIcon: Icon(Icons.smart_toy_rounded),
                  label: Text('AI Console'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.code_rounded),
                  selectedIcon: Icon(Icons.code_rounded),
                  label: Text('Code Editor'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.extension_outlined),
                  selectedIcon: Icon(Icons.extension_rounded),
                  label: Text('Modules'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
          ],
          Expanded(child: pages[_currentNavIndex]),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? NavigationBar(
              selectedIndex: _currentNavIndex,
              onDestinationSelected: (index) {
                setState(() => _currentNavIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'OS Core',
                ),
                NavigationDestination(
                  icon: Icon(Icons.smart_toy_outlined),
                  selectedIcon: Icon(Icons.smart_toy_rounded),
                  label: 'AI Console',
                ),
                NavigationDestination(
                  icon: Icon(Icons.code_rounded),
                  selectedIcon: Icon(Icons.code_rounded),
                  label: 'Editor',
                ),
                NavigationDestination(
                  icon: Icon(Icons.extension_outlined),
                  selectedIcon: Icon(Icons.extension_rounded),
                  label: 'Modules',
                ),
              ],
            )
          : null,
    );
  }
}

// ==========================================
// VIEW 1: DASHBOARD
// ==========================================

class DashboardView extends StatelessWidget {
  final List<ModuleModel> modules;
  final bool apiKeySet;
  final String aiModel;
  final Function(int) onNavigate;
  final VoidCallback onOpenSettings;

  const DashboardView({
    super.key,
    required this.modules,
    required this.apiKeySet,
    required this.aiModel,
    required this.onNavigate,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final activeModules = modules.where((m) => m.isEnabled).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF8B5CF6)],
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
                        'NexaForge OS Dashboard',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.extrabold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'AI Model Engine: $aiModel • Key Status: ${apiKeySet ? "CONFIGURED" : "MISSING"}',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.key, size: 18),
                  label: Text(apiKeySet ? 'Key Active' : 'Set Gemini Key'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Core System Telemetry Widgets
          const Text(
            'System Telemetry',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 700 ? 3 : 1;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: const [
                  MetricTile(
                    title: 'CPU Core Allocation',
                    value: '18.4 %',
                    subtext: '8 Cores / Threads Online',
                    icon: Icons.developer_board,
                    accentColor: Color(0xFF00E5FF),
                  ),
                  MetricTile(
                    title: 'Memory Usage',
                    value: '4.2 GB / 16 GB',
                    subtext: 'Buffer pool optimal',
                    icon: Icons.memory,
                    accentColor: Color(0xFF8B5CF6),
                  ),
                  MetricTile(
                    title: 'Kernel Latency',
                    value: '14 ms',
                    subtext: 'Direct local IPC link',
                    icon: Icons.speed,
                    accentColor: Color(0xFF10B981),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // Active Tools & Direct Shortcuts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active System Tools',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => onNavigate(3),
                child: const Text('Manage All Modules'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeModules.length,
            itemBuilder: (context, index) {
              final mod = activeModules[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    child: Icon(mod.icon,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(
                    mod.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(mod.description),
                  trailing: ElevatedButton(
                    onPressed: () {
                      if (mod.id == 'code_editor') {
                        onNavigate(2);
                      } else {
                        onNavigate(1);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Launch'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final IconData icon;
  final Color accentColor;

  const MetricTile({
    super.key,
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtext,
                    style: TextStyle(
                        fontSize: 11, color: accentColor.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// VIEW 2: AI AGENT CONSOLE
// ==========================================

class AiConsoleView extends StatefulWidget {
  final List<ChatMessage> messages;
  final Function(String) onSendMessage;
  final Function(String) onActionTriggered;

  const AiConsoleView({
    super.key,
    required this.messages,
    required this.onSendMessage,
    required this.onActionTriggered,
  });

  @override
  State<AiConsoleView> createState() => _AiConsoleViewState();
}

class _AiConsoleViewState extends State<AiConsoleView> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _inputController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Console Header Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Nexa-AI Core Console • Live Prompt Session',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Spacer(),
                const Icon(Icons.terminal, size: 18, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                final msg = widget.messages[index];
                final isUser = msg.sender == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF00E5FF).withOpacity(0.18)
                          : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUser
                            ? const Color(0xFF00E5FF).withOpacity(0.4)
                            : Theme.of(context).dividerColor.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUser ? Icons.person : Icons.smart_toy_rounded,
                              size: 14,
                              color: isUser
                                  ? const Color(0xFF00E5FF)
                                  : const Color(0xFF8B5CF6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isUser ? 'USER COMMAND' : 'NEXA KERNEL AI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isUser
                                    ? const Color(0xFF00E5FF)
                                    : const Color(0xFF8B5CF6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          msg.text,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                        if (msg.actionSuggestions != null &&
                            msg.actionSuggestions!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: msg.actionSuggestions!.map((action) {
                              return ActionChip(
                                label: Text(action,
                                    style: const TextStyle(fontSize: 11)),
                                backgroundColor: const Color(0xFF8B5CF6)
                                    .withOpacity(0.15),
                                side: BorderSide(
                                    color: const Color(0xFF8B5CF6)
                                        .withOpacity(0.4)),
                                onPressed: () =>
                                    widget.onActionTriggered(action),
                              );
                            }).toList(),
                          )
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Input Section
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    hintText: 'Type dynamic instructions (e.g., "Run diagnostics")...',
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                onPressed: _handleSend,
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                child: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// VIEW 3: INTERACTIVE CODE EDITOR
// ==========================================

class CodeEditorView extends StatelessWidget {
  final String selectedLanguage;
  final Map<String, TextEditingController> controllers;
  final String consoleOutput;
  final bool isExecuting;
  final Function(String) onLanguageChanged;
  final VoidCallback onRunCode;
  final VoidCallback onClearConsole;

  const CodeEditorView({
    super.key,
    required this.selectedLanguage,
    required this.controllers,
    required this.consoleOutput,
    required this.isExecuting,
    required this.onLanguageChanged,
    required this.onRunCode,
    required this.onClearConsole,
  });

  @override
  Widget build(BuildContext context) {
    final activeController = controllers[selectedLanguage];
    final linesCount = (activeController?.text.split('\n').length ?? 1);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Editor Top Control Bar
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.code, color: Color(0xFF00E5FF)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: selectedLanguage,
                    underline: const SizedBox(),
                    items: ['Dart', 'Python', 'JavaScript']
                        .map((lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(
                                lang,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) onLanguageChanged(val);
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.cleaning_services_outlined),
                    tooltip: 'Clear Console',
                    onPressed: onClearConsole,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isExecuting ? null : onRunCode,
                    icon: isExecuting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.play_arrow_rounded, size: 20),
                    label: Text(isExecuting ? 'Running...' : 'Run Simulation'),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Main Interactive Code Area
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF070A12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Line Numbers Column
                  Container(
                    width: 44,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFF1F293D)),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: linesCount,
                      itemBuilder: (context, idx) {
                        return Text(
                          '${idx + 1}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),

                  // Code Text Input Area
                  Expanded(
                    child: TextField(
                      controller: activeController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13.5,
                        color: Color(0xFF00E5FF),
                        height: 1.4,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Console / Stdout Drawer Screen
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0F19),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1F293D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.terminal_rounded,
                          size: 16, color: Color(0xFF10B981)),
                      SizedBox(width: 6),
                      Text(
                        'Execution Console Output',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF1F293D), height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        consoleOutput,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
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

// ==========================================
// VIEW 4: DYNAMIC MODULE MANAGER
// ==========================================

class ModuleManagerView extends StatefulWidget {
  final List<ModuleModel> modules;
  final Function(String) onToggleModule;
  final Function(String) onInstallModule;

  const ModuleManagerView({
    super.key,
    required this.modules,
    required this.onToggleModule,
    required this.onInstallModule,
  });

  @override
  State<ModuleManagerView> createState() => _ModuleManagerViewState();
}

class _ModuleManagerViewState extends State<ModuleManagerView> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredModules = widget.modules.where((mod) {
      final matchesSearch =
          mod.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              mod.description.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_selectedCategory == 'All') return matchesSearch;
      return matchesSearch && mod.category == _selectedCategory;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Search Controls
          TextField(
            decoration: InputDecoration(
              hintText: 'Search core modules...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Developer', 'System', 'Telemetry', 'Data']
                  .map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Modules Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    MediaQuery.of(context).size.width > 700 ? 2 : 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
              ),
              itemCount: filteredModules.length,
              itemBuilder: (context, index) {
                final mod = filteredModules[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.15),
                              child: Icon(mod.icon,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mod.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '${mod.category} • ${mod.version}',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            if (mod.isInstalled)
                              Switch(
                                value: mod.isEnabled,
                                onChanged: (_) =>
                                    widget.onToggleModule(mod.id),
                              )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          mod.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Spacer(),
                        if (!mod.isInstalled)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF),
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () =>
                                  widget.onInstallModule(mod.id),
                              icon: const Icon(Icons.download_rounded, size: 18),
                              label: const Text('Install Module'),
                            ),
                          )
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