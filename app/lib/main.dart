import 'package:flutter/material.dart';

void main() {
  runApp(const NexaForgeApp());
}

class NexaForgeApp extends StatelessWidget {
  const NexaForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexaForge',
      theme: ThemeData.dark(),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NexaForge Lab'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Terminal | Editor | Preview | AI Agent',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
