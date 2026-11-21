import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool admin;
  const LoginScreen({super.key, required this.admin});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _busy = false, _hide = true;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await context.read<AuthProvider>().login(_email.text, _pw.text, admin: widget.admin);
      if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
    } catch (e) {
      if (mounted) snack(context, errMsg(e));
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _forgot() async {
    final ctrl = TextEditingController(text: _email.text);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset password'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Your email')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Send link')),
        ],
      ),
    );
    if (ok != true || ctrl.text.trim().isEmpty) return;
    try {
      await AuthService.reset(ctrl.text);
      if (mounted) snack(context, 'Password reset email sent.');
    } catch (e) {
      if (mounted) snack(context, errMsg(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final col = widget.admin ? C.success : C.primary;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(children: [
            CircleAvatar(radius: 40, backgroundColor: col, child: const Icon(Icons.school, size: 44, color: Colors.white)),
            const SizedBox(height: 12),
            Text('CampusVoice', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: col)),
            Text(widget.admin ? 'Admin Panel' : 'Student Login'),
            const SizedBox(height: 28),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: widget.admin ? 'Admin email' : 'University email', prefixIcon: const Icon(Icons.email_outlined)),
              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _pw,
              obscureText: _hide,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(icon: Icon(_hide ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _hide = !_hide)),
              ),
              validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _busy ? null : _login, child: _busy ? const CircularProgressIndicator() : const Text('Login')),
            TextButton(onPressed: _forgot, child: const Text('Forgot Password?')),
            if (!widget.admin)
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text('New student? Register here'),
              ),
          ]),
        ),
      ),
    );
  }
}