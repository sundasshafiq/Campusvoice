import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/db_service.dart';
import '../widgets/widgets.dart';

class MyComplaintsScreen extends StatelessWidget {
  const MyComplaintsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final u = context.watch<AuthProvider>().user!;
    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
      body: ComplaintListView(stream: DbService.myComplaints(u.uid)),
    );
  }
}