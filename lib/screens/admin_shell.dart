import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Admin Home')),
    body: Center(
      child: FilledButton(
        onPressed: () => context.read<AuthProvider>().logout(),
        child: Text('Admin: ${context.watch<AuthProvider>().user!.name}. Tap to logout'),
      ),
    ),
  );
}