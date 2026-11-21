import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _email = TextEditingController();
  final _roll = TextEditingController(), _pw = TextEditingController(), _pw2 = TextEditingController();
  String? _dept;
  int _sem = 1;
  bool _busy = false;

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await context.read<AuthProvider>().register(
        AppUser(uid: '', name: _name.text.trim(), email: _email.text.trim(), rollNumber: _roll.text.trim(), department: _dept!, semester: _sem),
        _pw.text,
      );
      if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
    } catch (e) {
      if (mounted) snack(context, errMsg(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Student Registration')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(children: [
          TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name *'), validator: _req),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'University email *'),
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _roll, decoration: const InputDecoration(labelText: 'Roll number * (e.g. UOC-CS-F2024-026)'), validator: _req),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Department *'),
            items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) => _dept = v,
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _sem,
            decoration: const InputDecoration(labelText: 'Semester *'),
            items: List.generate(8, (i) => DropdownMenuItem(value: i + 1, child: Text('Semester ${i + 1}'))),
            onChanged: (v) => _sem = v ?? 1,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _pw, obscureText: true,
            decoration: const InputDecoration(labelText: 'Password *'),
            validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _pw2, obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm password *'),
            validator: (v) => v != _pw.text ? 'Passwords do not match' : null,
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: C.primary),
            onPressed: _busy ? null : _register,
            child: _busy ? const CircularProgressIndicator() : const Text('Register'),
          ),
        ]),
      ),
    ),
  );
}