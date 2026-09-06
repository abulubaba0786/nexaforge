import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const NexaStopwatchApp());
}

class NexaStopwatchApp extends StatelessWidget {
  const NexaStopwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexaStopwatch',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0C10),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFF0055),
          surface: Color(0xFF1F2833),
        ),
      ),
      home: const StopwatchScreen(),
    );
  }
}

class LapItem {
  final int lapNumber;
  final Duration lapTime;
  final Duration totalTime;

  LapItem({
    required this.lapNumber,
    required this.lapTime,
    required this.totalTime,
  });
}

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<LapItem> _laps = [];
  Duration _lastLapTotalTime = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _toggleStartPause() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _timer?.cancel();
      } else {
        _stopwatch.start();
        _startTimer();
      }
    });
  }

  void _reset() {
    HapticFeedback.heavyImpact();
    setState(() {
      _stopwatch.stop();
      _stopwatch.reset();
      _timer?.cancel();
      _laps.clear();
      _lastLapTotalTime = Duration.zero;
    });
  }

  void _addLap() {
    if (!_stopwatch.isRunning) return;
    HapticFeedback.lightImpact();

    final currentTotal = _stopwatch.elapsed;
    final lapDuration = currentTotal - _lastLapTotalTime;
    _lastLapTotalTime = currentTotal;

    setState(() {
      _laps.insert(
        0,
        LapItem(
          lapNumber: _laps.length + 1,
          lapTime: lapDuration,
          totalTime: currentTotal,
        ),
      );
    });
  }

  String _formatDuration(Duration duration, {bool showMs = true}) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds = twoDigits((duration.inMilliseconds.remainder(1000) / 10).floor());

    if (duration.inHours > 0) {
      return showMs
          ? '$hours:$minutes:$seconds.$milliseconds'
          : '$hours:$minutes:$seconds';
    }
    return showMs ? '$minutes:$seconds.$milliseconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed;
    final isRunning = _stopwatch.isRunning;

    // Determine fastest and slowest lap indices
    int? fastestIndex;
    int? slowestIndex;
    if (_laps.length > 1) {
      Duration minDuration = _laps.first.lapTime;
      Duration maxDuration = _laps.first.lapTime;
      fastestIndex = 0;
      slowestIndex = 0;

      for (int i = 0; i < _laps.length; i++) {
        if (_laps[i].lapTime < minDuration) {
          minDuration = _laps[i].lapTime;
          fastestIndex = i;
        }
        if (_laps[i].lapTime > maxDuration) {
          maxDuration = _laps[i].lapTime;
          slowestIndex = i;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.timer_outlined, color: Color(0xFF00E5FF), size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'NexaStopwatch',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Stopwatch Circular Timer View
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow Ring
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: isRunning
                            ? [
                                const Color(0xFF00E5FF),
                                const Color(0xFF00E5FF).withOpacity(0.1),
                                const Color(0xFF00E5FF),
                              ]
                            : [
                                Colors.white10,
                                Colors.white24,
                                Colors.white10,
                              ],
                        transform: GradientRotation(
                          (elapsed.inMilliseconds % 1000) / 1000 * 2 * 3.14159,
                        ),
                      ),
                      boxShadow: [
                        if (isRunning)
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.25),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                  ),

                  // Inner Container
                  Container(
                    width: 238,
                    height: 238,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF12141C),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatDuration(elapsed, showMs: false),
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '.${(elapsed.inMilliseconds.remainder(1000) / 10).floor().toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00E5FF),
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Controls Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reset Button
                  _buildActionButton(
                    icon: Icons.refresh_rounded,
                    label: 'Reset',
                    color: Colors.white54,
                    onPressed: (elapsed.inMilliseconds > 0) ? _reset : null,
                  ),

                  // Start / Pause Main Button
                  GestureDetector(
                    onTap: _toggleStartPause,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isRunning
                            ? const Color(0xFFFF0055)
                            : const Color(0xFF00E5FF),
                        boxShadow: [
                          BoxShadow(
                            color: (isRunning
                                    ? const Color(0xFFFF0055)
                                    : const Color(0xFF00E5FF))
                                .withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Lap Button
                  _buildActionButton(
                    icon: Icons.flag_outlined,
                    label: 'Lap',
                    color: const Color(0xFF00E5FF),
                    onPressed: isRunning ? _addLap : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Laps List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'LAP',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'LAP TIME',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'TOTAL TIME',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),

            // Laps ListView
            Expanded(
              child: _laps.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.timer_off_outlined,
                            size: 48,
                            color: Colors.white12,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No laps recorded',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: _laps.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                      itemBuilder: (context, index) {
                        final item = _laps[index];
                        final isFastest = index == fastestIndex;
                        final isSlowest = index == slowestIndex;

                        Color textColor = Colors.white70;
                        if (isFastest) textColor = const Color(0xFF00FF66);
                        if (isSlowest) textColor = const Color(0xFFFF3366);

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Lap Number with tag
                              Row(
                                children: [
                                  Text(
                                    '#${item.lapNumber.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (isFastest) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00FF66).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'FAST',
                                        style: TextStyle(
                                          color: Color(0xFF00FF66),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ] else if (isSlowest) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF3366).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'SLOW',
                                        style: TextStyle(
                                          color: Color(0xFFFF3366),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              // Lap duration
                              Text(
                                _formatDuration(item.lapTime),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),

                              // Total duration
                              Text(
                                _formatDuration(item.totalTime),
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 15,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          iconSize: 28,
          style: IconButton.styleFrom(
            backgroundColor: isEnabled
                ? color.withOpacity(0.12)
                : Colors.white.withOpacity(0.04),
            foregroundColor: isEnabled ? color : Colors.white24,
            padding: const EdgeInsets.all(16),
            shape: const CircleBorder(),
            side: BorderSide(
              color: isEnabled
                  ? color.withOpacity(0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          icon: Icon(icon),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isEnabled ? Colors.white70 : Colors.white24,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}