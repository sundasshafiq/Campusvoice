import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class StudentShell extends StatelessWidget {
  const StudentShell({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Student Home')),
    body: Center(
      child: FilledButton(
        onPressed: () => context.read<AuthProvider>().logout(),
        child: Text('Logged in as ${context.watch<AuthProvider>().user!.name}. Tap to logout'),
      ),
    ),
  );
}