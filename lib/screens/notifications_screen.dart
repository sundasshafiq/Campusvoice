import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/db_service.dart';
import '../widgets/widgets.dart';
import 'complaint_details_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final u = context.watch<AuthProvider>().user!;
    return StreamBuilder<List<NotifItem>>(
      stream: DbService.notifications(u.uid),
      builder: (ctx, s) {
        final l = s.data ?? [];
        return Scaffold(
          appBar: AppBar(title: const Text('Notifications'), actions: [
            TextButton(onPressed: l.isEmpty ? null : () => DbService.markAllRead(l), child: const Text('Mark all read')),
          ]),
          body: s.hasError
              ? const Center(child: Text('Could not load. Check your connection.'))
              : !s.hasData
              ? const Center(child: CircularProgressIndicator())
              : l.isEmpty
              ? const Center(child: Text('No notifications yet'))
              : ListView.builder(
            itemCount: l.length,
            itemBuilder: (c, i) {
              final n = l[i];
              return ListTile(
                leading: Icon(Icons.notifications, color: n.isRead ? Colors.grey : Theme.of(context).colorScheme.primary),
                title: Text(n.message, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(fmtTime(n.createdAt)),
                trailing: n.isRead ? null : const Icon(Icons.circle, size: 10, color: Colors.red),
                onTap: () {
                  DbService.markRead(n.id);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ComplaintDetailsScreen(n.complaintId)));
                },
              );
            },
          ),
        );
      },
    );
  }
}