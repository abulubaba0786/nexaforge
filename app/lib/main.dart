// NexaForge Autonomous Agent Active
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B0F19),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const NexaForgeApp());
}

class NexaForgeApp extends StatefulWidget {
  const NexaForgeApp({super.key});

  @override
  State<NexaForgeApp> createState() => _NexaForgeAppState();
}

class _NexaForgeAppState extends State<NexaForgeApp> {
  Color _accentColor = const Color(0xFF06B6D4); // Neon Cyan default
  bool _isHighPerformance = true;

  void _updateAccent(Color color) {
    setState(() {
      _accentColor = color;
    });
  }

  void _togglePerformanceMode() {
    setState(() {
      _isHighPerformance = !_isHighPerformance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexaForge Core OS',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        colorScheme: ColorScheme.dark(
          primary: _accentColor,
          secondary: const Color(0xFF8B5CF6),
          surface: const Color(0xFF111827),
          surfaceContainerHighest: const Color(0xFF1F2937),
          onSurface: const Color(0xFFF3F4F6),
          error: const Color(0xFFEF4444),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF111827),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF1F2937), width: 1),
          ),
        ),
        fontFamily: 'monospace',
      ),
      home: CoreOSDashboardScreen(
        accentColor: _accentColor,
        isHighPerformance: _isHighPerformance,
        onAccentChange: _updateAccent,
        onTogglePerformance: _togglePerformanceMode,
      ),
    );
  }
}

// ==========================================
// DATA MODELS
// ==========================================

enum ProcessStatus { running, highLoad, idle, suspended }

class OSProcess {
  final String id;
  final String name;
  final int pid;
  double cpuUsage;
  double memoryMb;
  ProcessStatus status;
  final String category;

  OSProcess({
    required this.id,
    required this.name,
    required this.pid,
    required this.cpuUsage,
    required this.memoryMb,
    required this.status,
    required this.category,
  });
}

class SecurityThreat {
  final String id;
  final String title;
  final String sourceIp;
  final String severity; // LOW, MEDIUM, CRITICAL
  final DateTime timestamp;
  bool resolved;

  SecurityThreat({
    required this.id,
    required this.title,
    required this.sourceIp,
    required this.severity,
    required this.timestamp,
    this.resolved = false,
  });
}

class ForgeModule {
  final String id;
  final String name;
  final String version;
  double health;
  int latencyMs;
  bool isOnline;

  ForgeModule({
    required this.id,
    required this.name,
    required this.version,
    required this.health,
    required this.latencyMs,
    this.isOnline = true,
  });
}

class TerminalLog {
  final DateTime time;
  final String message;
  final String level; // INFO, WARN, EXEC, SUCCESS, ERROR

  TerminalLog(this.message, {this.level = 'INFO'}) : time = DateTime.now();
}

// ==========================================
// MAIN DASHBOARD SCREEN
// ==========================================

class CoreOSDashboardScreen extends StatefulWidget {
  final Color accentColor;
  final bool isHighPerformance;
  final ValueChanged<Color> onAccentChange;
  final VoidCallback onTogglePerformance;

  const CoreOSDashboardScreen({
    super.key,
    required this.accentColor,
    required this.isHighPerformance,
    required this.onAccentChange,
    required this.onTogglePerformance,
  });

  @override
  State<CoreOSDashboardScreen> createState() => _CoreOSDashboardScreenState();
}

class _CoreOSDashboardScreenState extends State<CoreOSDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedNavIndex = 0;
  late Timer _telemetryTimer;

  // Real-time telemetry simulated values
  double _cpuLoad = 42.5;
  double _ramUsage = 64.8;
  double _gpuLoad = 28.1;
  double _tempC = 54.0;
  double _networkMbps = 842.1;
  int _powerWatts = 185;

  final List<double> _networkHistory = List.generate(20, (i) => 30.0 + (i * 3) % 50);

  // Lists
  late List<OSProcess> _processes;
  late List<SecurityThreat> _threats;
  late List<ForgeModule> _modules;
  final List<TerminalLog> _terminalLogs = [];

  final TextEditingController _terminalController = TextEditingController();
  final ScrollController _terminalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initSampleData();
    _startTelemetryLoop();
  }

  void _initSampleData() {
    _processes = [
      OSProcess(
          id: '1',
          name: 'nexa_kernel.sys',
          pid: 104,
          cpuUsage: 12.4,
          memoryMb: 1024,
          status: ProcessStatus.running,
          category: 'Kernel'),
      OSProcess(
          id: '2',
          name: 'neural_render_v4',
          pid: 482,
          cpuUsage: 45.2,
          memoryMb: 3420,
          status: ProcessStatus.highLoad,
          category: 'Graphics'),
      OSProcess(
          id: '3',
          name: 'quantum_sec_daemon',
          pid: 890,
          cpuUsage: 4.1,
          memoryMb: 512,
          status: ProcessStatus.running,
          category: 'Security'),
      OSProcess(
          id: '4',
          name: 'telemetry_stream',
          pid: 1120,
          cpuUsage: 8.8,
          memoryMb: 256,
          status: ProcessStatus.running,
          category: 'IO'),
      OSProcess(
          id: '5',
          name: 'hyper_db_cluster',
          pid: 1540,
          cpuUsage: 22.0,
          memoryMb: 4096,
          status: ProcessStatus.running,
          category: 'Database'),
      OSProcess(
          id: '6',
          name: 'legacy_bridge_v1',
          pid: 2201,
          cpuUsage: 0.0,
          memoryMb: 128,
          status: ProcessStatus.suspended,
          category: 'System'),
    ];

    _threats = [
      SecurityThreat(
        id: 'SEC-901',
        title: 'Buffer Overflow Attempt Blocked',
        sourceIp: '192.168.1.104',
        severity: 'HIGH',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      SecurityThreat(
        id: 'SEC-882',
        title: 'Unauthorized Port Probe (Port 8443)',
        sourceIp: '10.0.4.92',
        severity: 'MEDIUM',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SecurityThreat(
        id: 'SEC-703',
        title: 'Malformed Packet Flood Suppressed',
        sourceIp: '172.16.0.44',
        severity: 'LOW',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];

    _modules = [
      ForgeModule(
          id: 'M-1', name: 'Neural Synthesizer', version: 'v2.4.0', health: 99.2, latencyMs: 12),
      ForgeModule(
          id: 'M-2', name: 'Quantum Core Gateway', version: 'v4.1.8', health: 98.0, latencyMs: 8),
      ForgeModule(
          id: 'M-3', name: 'Vector DB Vault', version: 'v1.9.3', health: 100.0, latencyMs: 15),
      ForgeModule(
          id: 'M-4', name: 'Mesh Event Bus', version: 'v3.0.1', health: 94.5, latencyMs: 24),
    ];

    _addLog('NexaForge Core OS initialization complete.', level: 'SUCCESS');
    _addLog('Kernel loaded. System status: OPTIMAL.', level: 'INFO');
  }

  void _startTelemetryLoop() {
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (!mounted) return;
      final rand = math.Random();
      setState(() {
        _cpuLoad = (_cpuLoad + (rand.nextDouble() * 10 - 5)).clamp(15.0, 98.0);
        _ramUsage = (_ramUsage + (rand.nextDouble() * 2 - 1)).clamp(40.0, 92.0);
        _gpuLoad = (_gpuLoad + (rand.nextDouble() * 8 - 4)).clamp(10.0, 99.0);
        _tempC = (_tempC + (rand.nextDouble() * 0.8 - 0.4)).clamp(42.0, 82.0);
        _networkMbps = (_networkMbps + (rand.nextDouble() * 60 - 30)).clamp(200.0, 1200.0);
        _powerWatts = (150 + (_cpuLoad * 0.9)).toInt();

        _networkHistory.removeAt(0);
        _networkHistory.add(_networkMbps / 12);

        // Fluctuate CPU per process slightly
        for (var p in _processes) {
          if (p.status != ProcessStatus.suspended) {
            p.cpuUsage = (p.cpuUsage + (rand.nextDouble() * 4 - 2)).clamp(0.5, 95.0);
          }
        }
      });
    });
  }

  void _addLog(String msg, {String level = 'INFO'}) {
    setState(() {
      _terminalLogs.add(TerminalLog(msg, level: level));
    });
    _scrollToBottomTerminal();
  }

  void _scrollToBottomTerminal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_terminalScrollController.hasClients) {
        _terminalScrollController.animateTo(
          _terminalScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleTerminalSubmit(String input) {
    if (input.trim().isEmpty) return;
    final cmd = input.trim().toLowerCase();
    _terminalController.clear();
    _addLog('> $input', level: 'EXEC');

    if (cmd == 'help') {
      _addLog('Available Commands:', level: 'INFO');
      _addLog('  status     - Display full system diagnostics', level: 'INFO');
      _addLog('  clear      - Clear terminal console', level: 'INFO');
      _addLog('  boost      - Flush cache & balance core clocks', level: 'INFO');
      _addLog('  scan       - Run security threat matrix audit', level: 'INFO');
      _addLog('  nodes      - List system modules status', level: 'INFO');
      _addLog('  version    - Output kernel version info', level: 'INFO');
    } else if (cmd == 'clear') {
      setState(() {
        _terminalLogs.clear();
      });
    } else if (cmd == 'status') {
      _addLog('--- SYSTEM DIAGNOSTIC REPORT ---', level: 'INFO');
      _addLog('CPU: ${_cpuLoad.toStringAsFixed(1)}% | RAM: ${_ramUsage.toStringAsFixed(1)}%',
          level: 'INFO');
      _addLog('Temp: ${_tempC.toStringAsFixed(1)}°C | Power: ${_powerWatts}W', level: 'INFO');
      _addLog('Threats Active: ${_threats.where((t) => !t.resolved).length}', level: 'INFO');
    } else if (cmd == 'boost') {
      _addLog('Flushing memory caches...', level: 'INFO');
      _addLog('Optimizing thread pool affinity...', level: 'INFO');
      setState(() {
        _cpuLoad = math.max(18.0, _cpuLoad - 15);
        _ramUsage = math.max(35.0, _ramUsage - 12);
      });
      _addLog('System Boosted! Memory freed.', level: 'SUCCESS');
    } else if (cmd == 'scan') {
      _addLog('Initiating Deep Kernel Threat Audit...', level: 'WARN');
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        _addLog('Audit Complete: 0 Critical Vulnerabilities found.', level: 'SUCCESS');
      });
    } else if (cmd == 'nodes') {
      for (var m in _modules) {
        _addLog('[${m.id}] ${m.name} (${m.version}) - Health: ${m.health}% - ${m.latencyMs}ms',
            level: 'INFO');
      }
    } else if (cmd == 'version') {
      _addLog('NexaForge Core OS v4.8.2-quantum (Build 9042)', level: 'SUCCESS');
    } else {
      _addLog('Command not recognized: "$cmd". Type "help" for actions.', level: 'ERROR');
    }
  }

  void _runDiagnosticModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _DiagnosticDialog(
        accentColor: widget.accentColor,
        cpuLoad: _cpuLoad,
        ramUsage: _ramUsage,
        tempC: _tempC,
      ),
    );
  }

  @override
  void dispose() {
    _telemetryTimer.cancel();
    _terminalController.dispose();
    _terminalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // OS Top Header Bar
            _buildOSHeader(theme),

            // Body Area (NavigationRail for desktop or Page Stack)
            Expanded(
              child: Row(
                children: [
                  if (isDesktop) _buildNavRail(theme),
                  Expanded(
                    child: Container(
                      color: const Color(0xFF0B0F19),
                      child: IndexedStack(
                        index: _selectedNavIndex,
                        children: [
                          _buildDashboardTab(theme),
                          _buildProcessTab(theme),
                          _buildSecurityTab(theme),
                          _buildModulesTab(theme),
                          _buildTerminalTab(theme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isDesktop ? null : _buildBottomNavBar(theme),
    );
  }

  // ==========================================
  // TOP HEADER BAR
  // ==========================================

  Widget _buildOSHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1F2937), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo & OS Name
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: widget.accentColor.withOpacity(0.4)),
            ),
            child: Icon(Icons.memory_rounded, color: widget.accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'NEXA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: widget.accentColor,
                    ),
                  ),
                  const Text(
                    'FORGE CORE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'v4.8.2 // ONLINE',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // System Status Badges
          if (MediaQuery.of(context).size.width > 600) ...[
            _buildQuickHeaderChip(
              icon: Icons.thermostat_rounded,
              label: '${_tempC.toStringAsFixed(1)}°C',
              color: _tempC > 75 ? Colors.red : const Color(0xFF10B981),
            ),
            const SizedBox(width: 10),
            _buildQuickHeaderChip(
              icon: Icons.bolt_rounded,
              label: '${_powerWatts}W',
              color: Colors.amber,
            ),
            const SizedBox(width: 10),
          ],

          // Theme Accent Switcher Button
          PopupMenuButton<Color>(
            tooltip: 'Accent Color',
            icon: Icon(Icons.palette_outlined, color: widget.accentColor),
            color: const Color(0xFF1F2937),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: widget.onAccentChange,
            itemBuilder: (context) => [
              _buildColorMenuItem(const Color(0xFF06B6D4), 'Cyan Neon'),
              _buildColorMenuItem(const Color(0xFF8B5CF6), 'Electric Violet'),
              _buildColorMenuItem(const Color(0xFF10B981), 'Emerald Matrix'),
              _buildColorMenuItem(const Color(0xFFF59E0B), 'Amber Flame'),
            ],
          ),

          const SizedBox(width: 4),

          // Diagnostic Tool Action Button
          IconButton(
            tooltip: 'System Audit',
            icon: const Icon(Icons.minor_crash_outlined, color: Colors.white70),
            onPressed: _runDiagnosticModal,
          ),
        ],
      ),
    );
  }

  PopupMenuItem<Color> _buildColorMenuItem(Color color, String name) {
    return PopupMenuItem<Color>(
      value: color,
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildQuickHeaderChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // NAVIGATION WIDGETS
  // ==========================================

  Widget _buildNavRail(ThemeData theme) {
    return NavigationRail(
      selectedIndex: _selectedNavIndex,
      backgroundColor: const Color(0xFF111827),
      indicatorColor: widget.accentColor.withOpacity(0.2),
      unselectedIconTheme: const IconThemeData(color: Colors.white38),
      selectedIconTheme: IconThemeData(color: widget.accentColor),
      labelType: NavigationRailLabelType.all,
      unselectedLabelTextStyle: const TextStyle(color: Colors.white38, fontSize: 11),
      selectedLabelTextStyle: TextStyle(
        color: widget.accentColor,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
      onDestinationSelected: (idx) {
        setState(() {
          _selectedNavIndex = idx;
        });
      },
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: Text('Overview'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.memory_outlined),
          selectedIcon: Icon(Icons.memory_rounded),
          label: Text('Processes'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.shield_outlined),
          selectedIcon: Icon(Icons.shield_rounded),
          label: Text('Security'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.developer_board_outlined),
          selectedIcon: Icon(Icons.developer_board_rounded),
          label: Text('Modules'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.terminal_outlined),
          selectedIcon: Icon(Icons.terminal_rounded),
          label: Text('Console'),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(ThemeData theme) {
    return NavigationBar(
      selectedIndex: _selectedNavIndex,
      backgroundColor: const Color(0xFF111827),
      indicatorColor: widget.accentColor.withOpacity(0.25),
      elevation: 8,
      onDestinationSelected: (idx) {
        setState(() {
          _selectedNavIndex = idx;
        });
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.dashboard_outlined, color: Colors.white54),
          selectedIcon: Icon(Icons.dashboard_rounded, color: widget.accentColor),
          label: 'Overview',
        ),
        NavigationDestination(
          icon: const Icon(Icons.memory_outlined, color: Colors.white54),
          selectedIcon: Icon(Icons.memory_rounded, color: widget.accentColor),
          label: 'Nodes',
        ),
        NavigationDestination(
          icon: const Icon(Icons.shield_outlined, color: Colors.white54),
          selectedIcon: Icon(Icons.shield_rounded, color: widget.accentColor),
          label: 'Security',
        ),
        NavigationDestination(
          icon: const Icon(Icons.terminal_outlined, color: Colors.white54),
          selectedIcon: Icon(Icons.terminal_rounded, color: widget.accentColor),
          label: 'CLI',
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: OVERVIEW DASHBOARD
  // ==========================================

  Widget _buildDashboardTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Banner Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.accentColor.withOpacity(0.2),
                  const Color(0xFF1F2937),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.accentColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.accentColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'CORE STATUS',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'K-CLUSTER OPERATIONAL',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Quantum Compute & Telemetry Hub',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'All neural nodes synchronized. Bandwidth throughput is operating at optimal load.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _handleTerminalSubmit('boost');
                  },
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: const Text('PURGE CACHE',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Core System Metrics Gauge Grid
          const Text(
            'REAL-TIME GAUGES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(builder: (context, constraints) {
            final double cardWidth =
                constraints.maxWidth > 700 ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildGaugeCard(
                  title: 'CPU CORE LOAD',
                  value: _cpuLoad,
                  unit: '%',
                  color: widget.accentColor,
                  icon: Icons.memory_rounded,
                  width: cardWidth,
                ),
                _buildGaugeCard(
                  title: 'RAM ALLOCATION',
                  value: _ramUsage,
                  unit: '%',
                  color: const Color(0xFF8B5CF6),
                  icon: Icons.pie_chart_outline_rounded,
                  width: cardWidth,
                ),
                _buildGaugeCard(
                  title: 'NEURAL GPU ENGINE',
                  value: _gpuLoad,
                  unit: '%',
                  color: const Color(0xFF10B981),
                  icon: Icons.developer_board_rounded,
                  width: cardWidth,
                ),
                _buildGaugeCard(
                  title: 'CORE TEMP',
                  value: _tempC,
                  unit: '°C',
                  maxVal: 100,
                  color: _tempC > 75 ? Colors.redAccent : const Color(0xFFF59E0B),
                  icon: Icons.thermostat_rounded,
                  width: cardWidth,
                ),
              ],
            );
          }),

          const SizedBox(height: 24),

          // Network Telemetry Chart + Quick Quick Actions Split Row
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildNetworkGraphCard()),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildQuickControlCard()),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildNetworkGraphCard(),
                  const SizedBox(height: 16),
                  _buildQuickControlCard(),
                ],
              );
            }
          }),

          const SizedBox(height: 24),

          // Live System Console Feed Preview
          _buildConsolePreviewCard(),
        ],
      ),
    );
  }

  Widget _buildGaugeCard({
    required String title,
    required double value,
    required String unit,
    double maxVal = 100.0,
    required Color color,
    required IconData icon,
    required double width,
  }) {
    final double pct = (value / maxVal).clamp(0.0, 1.0);

    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 18, color: color),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 85,
                width: 85,
                child: CustomPaint(
                  painter: CircularGaugePainter(
                    progress: pct,
                    gaugeColor: color,
                    trackColor: const Color(0xFF1F2937),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          unit,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkGraphCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.hub_rounded, color: widget.accentColor, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'NETWORK THROUGHPUT TELEMETRY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_networkMbps.toStringAsFixed(1)} Mbps',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              width: double.infinity,
              child: CustomPaint(
                painter: PulseLinePainter(
                  values: _networkHistory,
                  lineColor: widget.accentColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0 Mbps', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4))),
                Text('1200 Mbps Peak', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickControlCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'QUICK CORE CONTROLS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: widget.isHighPerformance,
              activeColor: widget.accentColor,
              title: const Text('Performance Mode', style: TextStyle(fontSize: 13)),
              subtitle: Text('Max clock speeds across all cores',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
              onChanged: (_) => widget.onTogglePerformance(),
            ),
            const Divider(color: Color(0xFF1F2937)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.security_rounded, color: Colors.amber, size: 18),
              ),
              title: const Text('Quantum Firewall', style: TextStyle(fontSize: 13)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF059669).withOpacity(0.4)),
                ),
                child: const Text('ACTIVE',
                    style: TextStyle(fontSize: 10, color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF1F2937)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  _handleTerminalSubmit('scan');
                },
                icon: const Icon(Icons.radar_rounded, size: 16),
                label: const Text('RUN AUDIT SCAN', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsolePreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.terminal_rounded, size: 16, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(
                      'SYSTEM CONSOLE LIVE STREAM',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedNavIndex = MediaQuery.of(context).size.width >= 850 ? 4 : 3;
                    });
                  },
                  child: Text('OPEN CLI >', style: TextStyle(fontSize: 11, color: widget.accentColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF070A11),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _terminalLogs.reversed.take(4).toList().reversed.map((log) {
                  Color lvlColor = Colors.white70;
                  if (log.level == 'SUCCESS') lvlColor = const Color(0xFF10B981);
                  if (log.level == 'WARN') lvlColor = Colors.amberAccent;
                  if (log.level == 'ERROR') lvlColor = Colors.redAccent;
                  if (log.level == 'EXEC') lvlColor = widget.accentColor;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      '[${log.time.hour.toString().padLeft(2, '0')}:${log.time.minute.toString().padLeft(2, '0')}:${log.time.second.toString().padLeft(2, '0')}] [${log.level}] ${log.message}',
                      style: TextStyle(fontSize: 11, color: lvlColor, fontFamily: 'monospace'),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: PROCESS & NODE MANAGER
  // ==========================================

  Widget _buildProcessTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROCESS & CORE NODES',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text('Manage threads and dynamic kernel execution units',
                      style: TextStyle(fontSize: 12, color: Colors.white54)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  _addLog('Spawned new daemon worker process.', level: 'SUCCESS');
                  setState(() {
                    _processes.add(
                      OSProcess(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: 'worker_daemon_${_processes.length + 1}',
                        pid: 3000 + _processes.length * 12,
                        cpuUsage: 3.5,
                        memoryMb: 128,
                        status: ProcessStatus.running,
                        category: 'Worker',
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('SPAWN DAEMON', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Process List View
          Expanded(
            child: Card(
              child: ListView.separated(
                itemCount: _processes.length,
                separatorBuilder: (ctx, i) => const Divider(color: Color(0xFF1F2937), height: 1),
                itemBuilder: (ctx, idx) {
                  final proc = _processes[idx];
                  Color statusColor = const Color(0xFF10B981);
                  if (proc.status == ProcessStatus.highLoad) statusColor = Colors.amberAccent;
                  if (proc.status == ProcessStatus.suspended) statusColor = Colors.white38;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.settings_suggest_rounded, color: statusColor, size: 20),
                    ),
                    title: Row(
                      children: [
                        Text(
                          proc.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PID: ${proc.pid}',
                            style: const TextStyle(fontSize: 10, color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: [
                          Text('CPU: ${proc.cpuUsage.toStringAsFixed(1)}%',
                              style: TextStyle(fontSize: 11, color: widget.accentColor)),
                          const SizedBox(width: 12),
                          Text('RAM: ${proc.memoryMb.toInt()} MB',
                              style: const TextStyle(fontSize: 11, color: Colors.white54)),
                          const SizedBox(width: 12),
                          Text('Type: ${proc.category}',
                              style: const TextStyle(fontSize: 11, color: Colors.white38)),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: proc.status == ProcessStatus.suspended ? 'Resume' : 'Suspend',
                          icon: Icon(
                            proc.status == ProcessStatus.suspended
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              if (proc.status == ProcessStatus.suspended) {
                                proc.status = ProcessStatus.running;
                                _addLog('Resumed process PID ${proc.pid}', level: 'INFO');
                              } else {
                                proc.status = ProcessStatus.suspended;
                                proc.cpuUsage = 0.0;
                                _addLog('Suspended process PID ${proc.pid}', level: 'WARN');
                              }
                            });
                          },
                        ),
                        IconButton(
                          tooltip: 'Kill Process',
                          icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              _processes.removeAt(idx);
                              _addLog('Killed process PID ${proc.pid}', level: 'ERROR');
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: SECURITY MATRIX
  // ==========================================

  Widget _buildSecurityTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUANTUM SECURITY MATRIX',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text('Real-time intrusion detection and encryption shield status',
              style: TextStyle(fontSize: 12, color: Colors.white54)),
          const SizedBox(height: 20),

          // Security Status Overview Banner
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_rounded, color: const Color(0xFF10B981), size: 28),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FIREWALL SHIELD',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF10B981))),
                          SizedBox(height: 2),
                          Text('PROTECTION ACTIVE',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: widget.accentColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_clock_rounded, color: widget.accentColor, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ENCRYPTION ENGINE',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: widget.accentColor)),
                          const SizedBox(height: 2),
                          const Text('AES-256-GCM',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'RECENT THREAT AUDIT LOGS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 12),

          // Security Threat List
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _threats.length,
              separatorBuilder: (ctx, i) => const Divider(color: Color(0xFF1F2937), height: 1),
              itemBuilder: (ctx, idx) {
                final threat = _threats[idx];
                Color sevColor = Colors.amber;
                if (threat.severity == 'HIGH') sevColor = Colors.redAccent;
                if (threat.severity == 'LOW') sevColor = Colors.cyan;

                return ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: sevColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.warning_amber_rounded, color: sevColor, size: 20),
                  ),
                  title: Text(
                    threat.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Source IP: ${threat.sourceIp} | Timestamp: ${threat.timestamp.hour}:${threat.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: sevColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: sevColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      threat.severity,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: sevColor),
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

  // ==========================================
  // TAB 4: FORGE MODULES
  // ==========================================

  Widget _buildModulesTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FORGE MICRO-SERVICES',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text('Active system micro-modules and distributed network services',
              style: TextStyle(fontSize: 12, color: Colors.white54)),
          const SizedBox(height: 20),

          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 700 ? 2 : 1,
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _modules.length,
              itemBuilder: (ctx, idx) {
                final mod = _modules[idx];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.token_rounded, color: widget.accentColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  mod.name,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2937),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(mod.version,
                                  style: const TextStyle(fontSize: 10, color: Colors.white54)),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Health Integrity',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.white.withOpacity(0.6))),
                                Text('${mod.health}%',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF10B981))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: mod.health / 100,
                                minHeight: 6,
                                backgroundColor: const Color(0xFF1F2937),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(const Color(0xFF10B981)),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Latency: ${mod.latencyMs} ms',
                                style: const TextStyle(fontSize: 11, color: Colors.white38)),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      color: const Color(0xFF10B981), shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                const Text('ONLINE',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: const Color(0xFF10B981),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
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

  // ==========================================
  // TAB 5: CLI / INTERACTIVE TERMINAL
  // ==========================================

  Widget _buildTerminalTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INTERACTIVE KERNEL CONSOLE',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text('Execute direct system commands and control kernel threads',
              style: TextStyle(fontSize: 12, color: Colors.white54)),
          const SizedBox(height: 16),

          // Terminal Output Container
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF05080E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.accentColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _terminalScrollController,
                      itemCount: _terminalLogs.length,
                      itemBuilder: (ctx, idx) {
                        final log = _terminalLogs[idx];
                        Color col = Colors.white70;
                        if (log.level == 'SUCCESS') col = const Color(0xFF10B981);
                        if (log.level == 'WARN') col = Colors.amberAccent;
                        if (log.level == 'ERROR') col = Colors.redAccent;
                        if (log.level == 'EXEC') col = widget.accentColor;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: SelectableText(
                            '[${log.time.hour.toString().padLeft(2, '0')}:${log.time.minute.toString().padLeft(2, '0')}:${log.time.second.toString().padLeft(2, '0')}] ${log.message}',
                            style: TextStyle(
                              fontSize: 12,
                              color: col,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(color: Color(0xFF1F2937)),
                  Row(
                    children: [
                      Text('nexa@core-os:\$ ',
                          style: TextStyle(
                              color: widget.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      Expanded(
                        child: TextField(
                          controller: _terminalController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Type command (e.g. help, boost, status, scan)...',
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: _handleTerminalSubmit,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send_rounded, color: widget.accentColor, size: 18),
                        onPressed: () => _handleTerminalSubmit(_terminalController.text),
                      ),
                    ],
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
// SYSTEM DIAGNOSTIC DIALOG SHEET
// ==========================================

class _DiagnosticDialog extends StatefulWidget {
  final Color accentColor;
  final double cpuLoad;
  final double ramUsage;
  final double tempC;

  const _DiagnosticDialog({
    required this.accentColor,
    required this.cpuLoad,
    required this.ramUsage,
    required this.tempC,
  });

  @override
  State<_DiagnosticDialog> createState() => _DiagnosticDialogState();
}

class _DiagnosticDialogState extends State<_DiagnosticDialog> {
  bool _isRunning = true;
  double _progress = 0.0;
  String _statusMessage = 'Auditing Kernel Memory Pages...';

  @override
  void initState() {
    super.initState();
    _startDiagnosticRun();
  }

  void _startDiagnosticRun() async {
    for (int i = 1; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() {
        _progress = i / 100.0;
        if (i == 30) {
          _statusMessage = 'Checking Neural Core Latency...';
        }
        if (i == 60) {
          _statusMessage = 'Validating Cryptographic Signatures...';
        }
        if (i == 90) {
          _statusMessage = 'Finalizing System Integrity Report...';
        }
      });
    }
    if (!mounted) return;
    setState(() {
      _isRunning = false;
      _statusMessage = 'Diagnostic Complete. 0 Critical Faults Detected.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety_rounded, color: widget.accentColor, size: 24),
              const SizedBox(width: 12),
              const Text(
                'SYSTEM CORE DIAGNOSTIC',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: _progress,
            minHeight: 8,
            backgroundColor: const Color(0xFF1F2937),
            valueColor: AlwaysStoppedAnimation<Color>(widget.accentColor),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Text(
            _statusMessage,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          if (!_isRunning) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: const Color(0xFF10B981), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'All core threads operational. CPU @ ${widget.cpuLoad.toStringAsFixed(1)}% | RAM @ ${widget.ramUsage.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_isRunning ? 'CANCEL' : 'CLOSE REPORT'),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// CUSTOM PAINTERS (NEON GAUGE & SPARKLINE)
// ==========================================

class CircularGaugePainter extends CustomPainter {
  final double progress;
  final Color gaugeColor;
  final Color trackColor;

  CircularGaugePainter({
    required this.progress,
    required this.gaugeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    const strokeWidth = 8.0;

    // Track Arc
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      trackPaint,
    );

    // Dynamic Progress Arc with Glow Effect
    final progressPaint = Paint()
      ..color = gaugeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (math.pi * 1.5) * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.gaugeColor != gaugeColor;
  }
}

class PulseLinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  PulseLinePainter({
    required this.values,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (values.length - 1);
    final maxVal = values.reduce(math.max);
    final minVal = values.reduce(math.min);
    final range = math.max(1.0, maxVal - minVal);

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final normalizedY = (values[i] - minVal) / range;
      final y = size.height - (normalizedY * (size.height - 20) + 10);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw area fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [lineColor.withOpacity(0.3), lineColor.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw main glowing path line
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant PulseLinePainter oldDelegate) {
    return true;
  }
}