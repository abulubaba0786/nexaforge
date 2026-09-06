import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const NexaForgeApp());
}

class NexaForgeApp extends StatelessWidget {
  const NexaForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexaForge Core OS',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0E14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF7C4DFF),
          surface: Color(0xFF161B22),
          background: Color(0xFF0B0E14),
          onPrimary: Colors.black,
          onSurface: Color(0xFFE6EDF3),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF161B22),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF30363D), width: 1),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF30363D),
          thickness: 1,
        ),
      ),
      home: const OSMainScreen(),
    );
  }
}

// Data Models
class ModuleItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String category;
  bool isInstalled;
  bool isEnabled;

  ModuleItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.isInstalled = true,
    this.isEnabled = true,
  });
}

class ChatMessage {
  final String id;
  final String sender;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? activeTool;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.activeTool,
  });
}

class OSMainScreen extends StatefulWidget {
  const OSMainScreen({super.key});

  @override
  State<OSMainScreen> createState() => _OSMainScreenState();
}

class _OSMainScreenState extends State<OSMainScreen> {
  int _selectedBottomNav = 0;
  String _geminiApiKey = "";
  double _cpuUsage = 24.5;
  double _ramUsage = 4.2; // GB
  Timer? _metricsTimer;

  // Code Editor State
  final TextEditingController _codeController = TextEditingController(
    text: '''// NexaForge Core OS Routine\nvoid main() {\n  print("Initializing NexaForge Kernel...");\n  int activeNodes = 8;\n  double totalMemory = 16.0;\n  \n  for (int i = 1; i <= activeNodes; i++) {\n    print("Subsystem \$i status: ONLINE");\n  }\n  \n  print("Core OS Ready. System operational.");\n}''',
  );
  final TextEditingController _editorConsoleController = TextEditingController(
    text: "Console output ready. Press 'Run' to execute code stream.",
  );
  bool _isExecutingCode = false;

  // Chat State
  final TextEditingController _chatInputController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final List<ChatMessage> _chatMessages = [
    ChatMessage(
      id: '1',
      sender: 'Nexa AI Core',
      text: 'Greetings Commander. NexaForge OS Base Core is initialized and running smoothly. How can I assist you with system tools or workflows today?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  // Dynamic Modules Data
  late List<ModuleItem> _modules;

  @override
  void initState() {
    super.initState();
    _modules = [
      ModuleItem(
        id: 'editor',
        name: 'Code Editor',
        description: 'Interactive IDE with runtime simulation & console log',
        icon: Icons.code_rounded,
        category: 'Development',
        isInstalled: true,
        isEnabled: true,
      ),
      ModuleItem(
        id: 'python',
        name: 'Python Console',
        description: 'Embedded PyScript interpreter core for data processing',
        icon: Icons.terminal_rounded,
        category: 'Development',
        isInstalled: true,
        isEnabled: true,
      ),
      ModuleItem(
        id: 'file_mgr',
        name: 'File Manager',
        description: 'Virtual secure sandboxed filesystem explorer',
        icon: Icons.folder_special_rounded,
        category: 'System',
        isInstalled: true,
        isEnabled: true,
      ),
      ModuleItem(
        id: 'sys_mon',
        name: 'System Monitor',
        description: 'Real-time telemetry for CPU, Memory, and Network threads',
        icon: Icons.speed_rounded,
        category: 'Diagnostics',
        isInstalled: true,
        isEnabled: false,
      ),
      ModuleItem(
        id: 'db_viewer',
        name: 'Database Inspector',
        description: 'SQL/NoSQL query workbench for local secure storage',
        icon: Icons.storage_rounded,
        category: 'Data',
        isInstalled: false,
        isEnabled: false,
      ),
    ];

    // Live Metrics Simulation
    _metricsTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _cpuUsage = 15.0 + Random().nextDouble() * 25.0;
          _ramUsage = 3.8 + Random().nextDouble() * 1.2;
        });
      }
    });
  }

  @override
  void dispose() {
    _metricsTimer?.cancel();
    _codeController.dispose();
    _editorConsoleController.dispose();
    _chatInputController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _openSettingsModal() {
    final keyController = TextEditingController(text: _geminiApiKey);
    bool obscureKey = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.settings_suggest_rounded, color: Color(0xFF00E5FF)),
                          SizedBox(width: 8),
                          Text(
                            'Core OS Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Gemini API Configuration',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00E5FF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Provide your Google Gemini API Key to enable advanced neural capabilities across agent tools.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: keyController,
                    obscureText: obscureKey,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'AIzaSy...',
                      filled: true,
                      fillColor: const Color(0xFF0B0E14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF30363D)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF00E5FF)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureKey ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setModalState(() {
                            obscureKey = !obscureKey;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF30363D)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            keyController.clear();
                          },
                          child: const Text('Clear Key', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            setState(() {
                              _geminiApiKey = keyController.text.trim();
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF161B22),
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Color(0xFF00E5FF)),
                                    const SizedBox(width: 10),
                                    Text(
                                      _geminiApiKey.isNotEmpty
                                          ? 'Gemini API Key updated successfully'
                                          : 'API Key cleared',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleSendMessage() {
    final text = _chatInputController.text.trim();
    if (text.isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'User',
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _chatMessages.add(userMsg);
      _chatInputController.clear();
    });

    _scrollToBottom();

    // Simulated AI response with intelligence triggers
    Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      String responseText = "I have processed your instruction: '$text'. ";
      String? toolTag;

      if (text.toLowerCase().contains('run') || text.toLowerCase().contains('code')) {
        responseText += "Navigating runtime parameters. You can switch to the Code Editor tab to test and execute your script.";
        toolTag = "Code Runtime Tool";
      } else if (text.toLowerCase().contains('install') || text.toLowerCase().contains('module')) {
        responseText += "I have highlighted active system modules. You can manage them in the Dynamic Module Manager.";
        toolTag = "Module Management Subsystem";
      } else if (text.toLowerCase().contains('status') || text.toLowerCase().contains('cpu')) {
        responseText += "Current CPU Load: ${_cpuUsage.toStringAsFixed(1)}% | Allocated Memory: ${_ramUsage.toStringAsFixed(2)} GB.";
        toolTag = "System Diagnostics Tool";
      } else {
        responseText += _geminiApiKey.isNotEmpty
            ? "Gemini API Engine connected. Custom core pipeline processed your command."
            : "Operating in Standalone Core mode. Set Gemini API Key in Settings for deep neural synthesis.";
      }

      setState(() {
        _chatMessages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sender: 'Nexa AI Core',
            text: responseText,
            isUser: false,
            timestamp: DateTime.now(),
            activeTool: toolTag,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _runCodeSimulation() {
    setState(() {
      _isExecutingCode = true;
      _editorConsoleController.text = "[BUILD] Compiling Dart source core...\n";
    });

    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final lines = _codeController.text.split('\n');
      StringBuffer output = StringBuffer();
      output.writeln("[SYSTEM] Execution started at ${DateTime.now().toIso8601String()}");
      output.writeln("--------------------------------------------------");

      // Simple runtime parser simulation
      for (var line in lines) {
        if (line.contains('print(')) {
          final match = RegExp(r'print\((.*?)\);').firstMatch(line);
          if (match != null) {
            String extracted = match.group(1) ?? "";
            extracted = extracted.replaceAll('"', '').replaceAll("'", '');
            if (extracted.contains(r'$i')) {
              for (int i = 1; i <= 8; i++) {
                output.writeln(extracted.replaceAll(r'$i', '$i'));
              }
            } else {
              output.writeln(extracted);
            }
          }
        }
      }

      output.writeln("--------------------------------------------------");
      output.writeln("[SUCCESS] Process exited with code 0");

      setState(() {
        _isExecutingCode = false;
        _editorConsoleController.text = output.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final codeEditorEnabled = _modules.firstWhere((m) => m.id == 'editor').isEnabled;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.hub_rounded, color: Color(0xFF00E5FF), size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'NexaForge OS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.5),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green, width: 0.5),
              ),
              child: const Text('CORE v2.5', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'System Settings',
            icon: Stack(
              children: [
                const Icon(Icons.settings, color: Colors.white70),
                if (_geminiApiKey.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E5FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _openSettingsModal,
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF161B22),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              backgroundColor: const Color(0xFF0B0E14),
              accountName: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(
                _geminiApiKey.isNotEmpty ? 'Gemini 1.5 Pro Connected' : 'Standalone Kernel Mode',
                style: TextStyle(color: _geminiApiKey.isNotEmpty ? const Color(0xFF00E5FF) : Colors.grey, fontSize: 12),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: const Color(0xFF7C4DFF).withOpacity(0.3),
                child: const Icon(Icons.terminal, color: Color(0xFF00E5FF), size: 30),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF00E5FF)),
              title: const Text('Dashboard & Modules'),
              selected: _selectedBottomNav == 0,
              onTap: () {
                setState(() => _selectedBottomNav = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy_rounded, color: Color(0xFF7C4DFF)),
              title: const Text('AI Agent Console'),
              selected: _selectedBottomNav == 1,
              onTap: () {
                setState(() => _selectedBottomNav = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.code_rounded, color: codeEditorEnabled ? const Color(0xFF00E5FF) : Colors.grey),
              title: Text('Code Editor IDE', style: TextStyle(color: codeEditorEnabled ? Colors.white : Colors.grey)),
              enabled: codeEditorEnabled,
              selected: _selectedBottomNav == 2,
              onTap: () {
                setState(() => _selectedBottomNav = 2);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.tune_rounded, color: Colors.white70),
              title: const Text('OS Settings'),
              onTap: () {
                Navigator.pop(context);
                _openSettingsModal();
              },
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF0B0E14),
              child: Row(
                children: [
                  const Icon(Icons.memory, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'CPU: ${_cpuUsage.toStringAsFixed(1)}% | RAM: ${_ramUsage.toStringAsFixed(1)}GB',
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedBottomNav,
        children: [
          _buildDashboardTab(),
          _buildAiConsoleTab(),
          _buildCodeEditorTab(codeEditorEnabled),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomNav,
        onTap: (index) {
          if (index == 2 && !codeEditorEnabled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Code Editor module is currently disabled in Module Manager.')),
            );
            return;
          }
          setState(() {
            _selectedBottomNav = index;
          });
        },
        backgroundColor: const Color(0xFF161B22),
        selectedItemColor: const Color(0xFF00E5FF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarViewItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Modules',
          ),
          const BottomNavigationBarViewItem(
            icon: Icon(Icons.psychology_rounded),
            label: 'AI Agent',
          ),
          BottomNavigationBarViewItem(
            icon: Icon(
              Icons.code_rounded,
              color: codeEditorEnabled ? null : Colors.grey.withOpacity(0.4),
            ),
            label: 'Editor',
          ),
        ],
      ),
    );
  }

  // TAB 1: Dashboard & Dynamic Module Manager
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          // Telemetry Cards
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.memory, color: Color(0xFF00E5FF), size: 18),
                            SizedBox(width: 6),
                            Text('CPU Load', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_cpuUsage.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: _cpuUsage / 100,
                          backgroundColor: Colors.black25,
                          color: const Color(0xFF00E5FF),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.storage_rounded, color: Color(0xFF7C4DFF), size: 18),
                            SizedBox(width: 6),
                            Text('RAM Usage', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_ramUsage.toStringAsFixed(2)} GB',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: _ramUsage / 16.0,
                          backgroundColor: Colors.black25,
                          color: const Color(0xFF7C4DFF),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAlignment: CrossAlignment.start,
                children: [
                  Text('Dynamic Module Manager', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Install, uninstall or toggle runtime core applications', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Chip(
                backgroundColor: const Color(0xFF161B22),
                label: Text(
                  '${_modules.where((m) => m.isEnabled).length}/${_modules.length} Active',
                  style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12),
                ),
                side: const BorderSide(color: Color(0xFF30363D)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Module Cards Grid
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _modules.length,
            itemBuilder: (context, index) {
              final module = _modules[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: module.isEnabled
                              ? const Color(0xFF00E5FF).withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          module.icon,
                          color: module.isEnabled ? const Color(0xFF00E5FF) : Colors.grey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  module.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: module.isEnabled ? Colors.white : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF30363D),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    module.category,
                                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              module.description,
                              style: TextStyle(fontSize: 12, color: module.isEnabled ? Colors.grey : Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          if (!module.isInstalled)
                            TextButton.icon(
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text('Install'),
                              style: TextButton.styleFrom(foregroundColor: const Color(0xFF00E5FF)),
                              onPressed: () {
                                setState(() {
                                  module.isInstalled = true;
                                  module.isEnabled = true;
                                });
                              },
                            )
                          else
                            Switch(
                              value: module.isEnabled,
                              activeColor: const Color(0xFF00E5FF),
                              onChanged: (val) {
                                setState(() {
                                  module.isEnabled = val;
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // TAB 2: AI Agent Console
  Widget _buildAiConsoleTab() {
    return Column(
      children: [
        // AI Banner Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFF161B22),
          child: Row(
            children: [
              const Icon(Icons.psychology, color: Color(0xFF7C4DFF), size: 20),
              const SizedBox(width: 8),
              Text(
                _geminiApiKey.isNotEmpty ? 'AI Core: Gemini 1.5 Active' : 'AI Core: Local Autonomous Mode',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _geminiApiKey.isNotEmpty ? const Color(0xFF00E5FF) : Colors.amber,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _openSettingsModal,
                child: Text(
                  _geminiApiKey.isNotEmpty ? 'Change Key' : 'Add Gemini Key',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF00E5FF), textBaseline: TextBaseline.alphabetic),
                ),
              ),
            ],
          ),
        ),

        // Message List
        Expanded(
          child: ListView.builder(
            controller: _chatScrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final msg = _chatMessages[index];
              return Align(
                alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                  decoration: BoxDecoration(
                    color: msg.isUser ? const Color(0xFF7C4DFF).withOpacity(0.2) : const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: msg.isUser ? const Color(0xFF7C4DFF).withOpacity(0.5) : const Color(0xFF30363D),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            msg.isUser ? Icons.person : Icons.smart_toy,
                            size: 14,
                            color: msg.isUser ? const Color(0xFF7C4DFF) : const Color(0xFF00E5FF),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            msg.sender,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: msg.isUser ? const Color(0xFF7C4DFF) : const Color(0xFF00E5FF),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        msg.text,
                        style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.3),
                      ),
                      if (msg.activeTool != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.build_circle_outlined, size: 12, color: Color(0xFF00E5FF)),
                              const SizedBox(width: 4),
                              Text(
                                'Tool Executed: ${msg.activeTool}',
                                style: const TextStyle(fontSize: 10, color: Color(0xFF00E5FF)),
                              ),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Prompts suggestion row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              _buildPromptChip('/status Check System Health'),
              _buildPromptChip('/run Run Code Routine'),
              _buildPromptChip('/modules List Installed Tools'),
            ],
          ),
        ),

        // Input Field Bar
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF161B22),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatInputController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Type instructions or command...',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF0B0E14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFF30363D)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFF00E5FF)),
                    ),
                  ),
                  onSubmitted: (_) => _handleSendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFF00E5FF),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.black, size: 18),
                  onPressed: _handleSendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromptChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        backgroundColor: const Color(0xFF161B22),
        side: const BorderSide(color: Color(0xFF30363D)),
        onPressed: () {
          _chatInputController.text = label.split(' ')[0];
          _handleSendMessage();
        },
      ),
    );
  }

  // TAB 3: Code Editor IDE
  Widget _buildCodeEditorTab(bool isEnabled) {
    if (!isEnabled) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.code_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Code Editor Module Disabled', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => setState(() => _selectedBottomNav = 0),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black),
              child: const Text('Enable in Dynamic Modules'),
            ),
          ],
        ),
      );
    }

    final lineCount = _codeController.text.split('\n').length;

    return Column(
      children: [
        // Action Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFF161B22),
          child: Row(
            children: [
              const Icon(Icons.code, color: Color(0xFF00E5FF), size: 18),
              const SizedBox(width: 8),
              const Text('main.dart', style: TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                icon: _isExecutingCode
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(_isExecutingCode ? 'Running...' : 'Run Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: _isExecutingCode ? null : _runCodeSimulation,
              ),
            ],
          ),
        ),

        // Code Area
        Expanded(
          flex: 3,
          child: Row(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              // Line Numbers Column
              Container(
                width: 40,
                color: const Color(0xFF0B0E14),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: List.generate(
                    lineCount,
                    (index) => Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.grey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              const VerticalDivider(width: 1, color: Color(0xFF30363D)),
              // Interactive Editor Field
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _codeController,
                    maxLines: null,
                    expands: true,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Color(0xFFE6EDF3),
                      height: 1.4,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Console Output Drawer / Drawer Area
        Expanded(
          flex: 2,
          child: Container(
            color: const Color(0xFF0B0E14),
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: const Color(0xFF161B22),
                  child: const Row(
                    children: [
                      Icon(Icons.terminal_rounded, size: 14, color: Colors.grey),
                      SizedBox(width: 6),
                      Text('SYSTEM OUTPUT / CONSOLE LOG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _editorConsoleController,
                      readOnly: true,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFF00E5FF),
                      ),
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BottomNavigationBarViewItem {
  final Widget icon;
  final String label;

  const BottomNavigationBarViewItem({required this.icon, required this.label});

  operator [](int index) {}
}