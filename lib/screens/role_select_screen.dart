import 'package:flutter/material.dart';
import '../theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});
  Widget _btn(BuildContext c, String t, String sub, IconData i, Color col, bool admin) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => LoginScreen(admin: admin))),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Icon(i, color: Colors.white, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
              Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ]),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircleAvatar(radius: 40, backgroundColor: C.primary, child: Icon(Icons.school, size: 44, color: Colors.white)),
        const SizedBox(height: 12),
        const Text('CampusVoice', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: C.primary)),
        const SizedBox(height: 16),
        const Text('Welcome! Please choose how you want to continue',
            textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        _btn(context, 'Login as Student', 'Submit and track your complaints', Icons.person, C.primary, false),
        _btn(context, 'Login as Admin', 'Review and resolve complaints', Icons.verified_user, C.success, true),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
          child: const Text('New student? Register here'),
        ),
      ]),
    ),
  );
}