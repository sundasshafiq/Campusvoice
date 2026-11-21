import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../screens/complaint_details_screen.dart';
import '../theme.dart';

String fmt(DateTime d) => DateFormat('d MMM yyyy').format(d);
String fmtTime(DateTime d) => DateFormat('d MMM yyyy, h:mm a').format(d);

Color statusColor(String s) =>
    s == 'Resolved' ? C.success : (s == 'In Progress' ? C.primary : C.warning);
Color priorityColor(String p) =>
    p == 'High' ? C.error : (p == 'Medium' ? C.warning : C.success);

String errMsg(Object e) {
  if (e is String) return e;
  if (e is FirebaseAuthException) {
    if (e.code == 'network-request-failed') return 'No connection. Check your internet and retry.';
    if (['invalid-credential', 'wrong-password', 'user-not-found'].contains(e.code)) {
      return 'Incorrect email or password.';
    }
    return e.message ?? 'Authentication error.';
  }
  return 'Something went wrong. Check your internet connection and try again.';
}

void snack(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

Future<String?> textSheet(BuildContext context, String title, String hint) {
  final ctrl = TextEditingController();
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(controller: ctrl, maxLines: 4, autofocus: true, decoration: InputDecoration(hintText: hint)),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () {
            if (ctrl.text.trim().isNotEmpty) Navigator.pop(ctx, ctrl.text.trim());
          },
          child: const Text('Submit'),
        ),
      ]),
    ),
  );
}

class Pill extends StatelessWidget {
  final String label;
  final Color color;
  const Pill(this.label, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

class CountBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const CountBox(this.label, this.value, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ]),
    ),
  );
}

Widget countsRow(List<Complaint> l) => Row(children: [
  CountBox('Total', l.length, Colors.blueGrey),
  CountBox('Pending', l.where((c) => c.status == 'Pending').length, C.warning),
  CountBox('In Progress', l.where((c) => c.status == 'In Progress').length, C.primary),
  CountBox('Resolved', l.where((c) => c.status == 'Resolved').length, C.success),
]);

class ComplaintTile extends StatelessWidget {
  final Complaint c;
  final bool admin;
  const ComplaintTile(this.c, {super.key, this.admin = false});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ComplaintDetailsScreen(c.id))),
      leading: CircleAvatar(
        backgroundColor: priorityColor(c.priority).withOpacity(.15),
        child: Icon(Icons.report_problem_outlined, color: priorityColor(c.priority)),
      ),
      title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${c.code} • ${fmt(c.createdAt)}${admin ? ' • ${c.studentName}' : ''}'),
      trailing: Pill(c.status, statusColor(c.status)),
    ),
  );
}

/// List with All / Pending / In Progress / Resolved filters.
class ComplaintListView extends StatefulWidget {
  final Stream<List<Complaint>> stream;
  final bool admin;
  const ComplaintListView({super.key, required this.stream, this.admin = false});
  @override
  State<ComplaintListView> createState() => _ComplaintListViewState();
}

class _ComplaintListViewState extends State<ComplaintListView> {
  String f = 'All';
  @override
  Widget build(BuildContext context) => Column(children: [
    SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: ['All', 'Pending', 'In Progress', 'Resolved']
            .map((s) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(label: Text(s), selected: f == s, onSelected: (_) => setState(() => f = s)),
        ))
            .toList(),
      ),
    ),
    Expanded(
      child: StreamBuilder<List<Complaint>>(
        stream: widget.stream,
        builder: (c, s) {
          if (s.hasError) return const Center(child: Text('Could not load. Check your connection.'));
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final l = s.data!.where((x) => f == 'All' || x.status == f).toList();
          if (l.isEmpty) return const Center(child: Text('No complaints found'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: l.length,
            itemBuilder: (c, i) => ComplaintTile(l[i], admin: widget.admin),
          );
        },
      ),
    ),
  ]);
}

Widget photoView(String b64) => ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Image.memory(base64Decode(b64), height: 200, width: double.infinity, fit: BoxFit.cover),
);