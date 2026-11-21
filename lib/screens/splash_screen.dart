import 'package:flutter/material.dart';
import '../theme.dart';
import 'role_select_screen.dart';

class SplashScreen extends StatelessWidget {
  final bool loading;
  const SplashScreen({super.key, this.loading = false});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [C.primary, C.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: SafeArea(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircleAvatar(radius: 48, backgroundColor: Colors.white, child: Icon(Icons.school, size: 52, color: C.primary)),
          const SizedBox(height: 20),
          const Text('CampusVoice', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const Text('Student Complaint App', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          const Text('Your voice matters.\nA better campus together.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 40),
          if (loading)
            const CircularProgressIndicator(color: Colors.white)
          else
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: C.primary, minimumSize: const Size(200, 50)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoleSelectScreen())),
              child: const Text('Get Started →'),
            ),
        ]),
      ),
    ),
  );
}