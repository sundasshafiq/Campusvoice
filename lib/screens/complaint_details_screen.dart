import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/db_service.dart';
import '../widgets/widgets.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final String id;
  const ComplaintDetailsScreen(this.id, {super.key});
  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  late final AppUser me;
  static const stages = ['Submitted', 'Under Review', 'In Progress', 'Resolved'];

  @override
  void initState() {
    super.initState();
    me = context.read<AuthProvider>().user!;
    if (me.isAdmin) {
      DbService.complaint(widget.id).first.then((c) {
        if (c != null) DbService.markUnderReview(c, me).catchError((_) {});
      });
    }
  }

  Future<void> _comment(Complaint c, {required bool note}) async {
    final t = await textSheet(context, note ? 'Add Note' : 'Add Comment', note ? 'Write a note for the student...' : 'Write your comment...');
    if (t == null) return;
    try {
      await DbService.addComment(c, me, t, isNote: note);
    } catch (e) {
      if (mounted) snack(context, errMsg(e));
    }
  }

  Future<void> _update(Complaint c) async {
    final opts = DbService.statuses.where((s) => DbService.rank(s) > DbService.rank(c.status)).toList();
    if (opts.isEmpty) {
      snack(context, 'This complaint is already resolved.');
      return;
    }
    final pick = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          ...opts.map((s) => ListTile(leading: Icon(Icons.circle, color: statusColor(s)), title: Text(s), onTap: () => Navigator.pop(ctx, s))),
        ]),
      ),
    );
    if (pick == null) return;
    try {
      await DbService.updateStatus(c, pick, me);
    } catch (e) {
      if (mounted) snack(context, errMsg(e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Complaint Details')),
    body: StreamBuilder<Complaint?>(
      stream: DbService.complaint(widget.id),
      builder: (ctx, s) {
        if (s.hasError) return const Center(child: Text('Could not load. Check your connection.'));
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final c = s.data!;
        return Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(c.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                Pill(c.status, statusColor(c.status)),
              ]),
              const SizedBox(height: 6),
              Text(c.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('${c.category} • ${c.location}'),
              Row(children: [
                Text(fmt(c.createdAt)),
                const SizedBox(width: 8),
                Pill('${c.priority} Priority', priorityColor(c.priority)),
              ]),
              if (me.isAdmin) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Submitted by: ${c.studentName}')),
              const SizedBox(height: 14),
              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
              Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(c.description))),
              if (c.photo != null) ...[const SizedBox(height: 8), photoView(c.photo!)],
              const SizedBox(height: 16),
              const Text('Status Timeline', style: TextStyle(fontWeight: FontWeight.bold)),
              StreamBuilder<List<HistoryEntry>>(
                stream: DbService.history(c.id),
                builder: (ctx, hs) {
                  final done = {for (final h in hs.data ?? <HistoryEntry>[]) h.stage: h};
                  return Column(
                    children: stages.map((st) {
                      final h = done[st];
                      return ListTile(
                        dense: true,
                        leading: Icon(h != null ? Icons.check_circle : Icons.radio_button_unchecked, color: h != null ? statusColor(st == 'Submitted' || st == 'Under Review' ? 'Pending' : st) : Colors.grey),
                        title: Text(st),
                        trailing: Text(h == null ? '-' : fmtTime(h.date), style: const TextStyle(fontSize: 11)),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 8),
              const Text('Comments & Notes', style: TextStyle(fontWeight: FontWeight.bold)),
              StreamBuilder<List<CommentItem>>(
                stream: DbService.comments(c.id),
                builder: (ctx, cs) {
                  final l = cs.data ?? [];
                  if (l.isEmpty) return const Padding(padding: EdgeInsets.all(8), child: Text('No comments yet'));
                  return Column(
                    children: l.map((x) => Card(
                      child: ListTile(
                        title: Row(children: [
                          Text(x.authorName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          if (x.isNote) const Pill('Admin note', Colors.green),
                        ]),
                        subtitle: Text('${x.text}\n${fmtTime(x.createdAt)}'),
                        isThreeLine: true,
                      ),
                    )).toList(),
                  );
                },
              ),
            ]),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: me.isAdmin
                  ? Row(children: [
                Expanded(child: FilledButton(onPressed: () => _update(c), child: const Text('Update Status'))),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)), onPressed: () => _comment(c, note: true), child: const Text('Add Note'))),
              ])
                  : FilledButton(onPressed: () => _comment(c, note: false), child: const Text('Add Comment')),
            ),
          ),
        ]);
      },
    ),
  );
}