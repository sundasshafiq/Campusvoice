import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _edit(BuildContext context) async {
    final p = context.read<AuthProvider>();
    final u = p.user!;
    final name = TextEditingController(text: u.name);
    final roll = TextEditingController(text: u.rollNumber);
    final sem = TextEditingController(text: '${u.semester}');
    String dept = departments.contains(u.department) ? u.department : departments.first;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
              const SizedBox(height: 8),
              TextField(controller: roll, decoration: const InputDecoration(labelText: 'Roll number')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: dept,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Department'),
                items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => set(() => dept = v!),
              ),
              const SizedBox(height: 8),
              TextField(controller: sem, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Semester')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    try {
      await p.updateProfile(u.copyWith(
        name: name.text.trim(), rollNumber: roll.text.trim(), department: dept,
        semester: int.tryParse(sem.text) ?? u.semester,
      ));
      if (context.mounted) snack(context, 'Profile updated');
    } catch (e) {
      if (context.mounted) snack(context, errMsg(e));
    }
  }

  Future<void> _settings(BuildContext context) async {
    final p = context.read<AuthProvider>();
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => Consumer<AuthProvider>(
        builder: (ctx, a, _) => SafeArea(
          child: SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Receive alerts about complaints'),
            value: a.user!.notificationsOn,
            onChanged: (v) => p.updateProfile(a.user!.copyWith(notificationsOn: v)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = context.watch<AuthProvider>().user!;
    Widget tile(IconData i, String t, VoidCallback f, {Color? c}) => Card(
      child: ListTile(leading: Icon(i, color: c), title: Text(t, style: TextStyle(color: c)), trailing: const Icon(Icons.chevron_right), onTap: f),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Center(child: CircleAvatar(radius: 44, child: Text(u.name.isEmpty ? '?' : u.name[0].toUpperCase(), style: const TextStyle(fontSize: 34)))),
        const SizedBox(height: 10),
        Center(child: Text(u.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        Center(child: Text(u.isAdmin ? '${u.email} • Administrator' : '${u.rollNumber}\n${u.department} • Semester ${u.semester}', textAlign: TextAlign.center)),
        const SizedBox(height: 16),
        if (!u.isAdmin) tile(Icons.edit_outlined, 'Edit Profile', () => _edit(context)),
        tile(Icons.notifications_outlined, 'Notification Settings', () => _settings(context)),
        tile(Icons.help_outline, 'Help & Support', () => showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Help & Support'),
            content: const Text('To report an issue tap the + New button, fill in the form and submit. Track progress under Complaints.\n\nNeed help? Contact the IT office: support@campusvoice.edu'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
          ),
        )),
        tile(Icons.info_outline, 'About App', () => showAboutDialog(
          context: context,
          applicationName: 'CampusVoice',
          applicationVersion: '1.0.0',
          children: const [Text('Your voice matters. A better campus together.\nUniversity of Chakwal - CS-315 project.')],
        )),
        tile(Icons.logout, 'Logout', () => context.read<AuthProvider>().logout(), c: C.error),
      ]),
    );
  }
}