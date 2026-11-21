import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/db_service.dart';
import '../widgets/widgets.dart';
import 'submit_complaint_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onTab;
  const HomeScreen({super.key, required this.onTab});
  @override
  Widget build(BuildContext context) {
    final u = context.watch<AuthProvider>().user!;
    final h = DateTime.now().hour;
    final greet = h < 12 ? 'Good Morning' : (h < 17 ? 'Good Afternoon' : 'Good Evening');
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Complaint>>(
          stream: DbService.myComplaints(u.uid),
          builder: (c, s) {
            final l = s.data ?? [];
            return ListView(padding: const EdgeInsets.all(16), children: [
              Row(children: [
                CircleAvatar(radius: 24, child: Text(u.name.isEmpty ? '?' : u.name[0].toUpperCase())),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(greet, style: const TextStyle(fontSize: 12)),
                    Text(u.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${u.department} • Semester ${u.semester}', style: const TextStyle(fontSize: 12)),
                  ]),
                ),
                IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => onTab(3)),
              ]),
              const SizedBox(height: 16),
              countsRow(l),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Submit New Complaint'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitComplaintScreen())),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Recent Complaints', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(onPressed: () => onTab(1), child: const Text('View All')),
              ]),
              if (!s.hasData && !s.hasError) const Center(child: CircularProgressIndicator()),
              if (s.hasError) const Text('Could not load. Check your connection.'),
              if (s.hasData && l.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No complaints yet'))),
              ...l.take(3).map((x) => ComplaintTile(x)),
            ]);
          },
        ),
      ),
    );
  }
}