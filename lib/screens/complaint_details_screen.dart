import 'package:flutter/material.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  final String id;
  const ComplaintDetailsScreen(this.id, {super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text('Complaint Details')), body: Center(child: Text(id)));
}