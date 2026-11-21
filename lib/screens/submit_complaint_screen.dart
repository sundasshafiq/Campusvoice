import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/db_service.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});
  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(), _desc = TextEditingController();
  String? _cat, _loc, _photo;
  String _priority = 'Medium';
  bool _busy = false;

  Future<void> _pick() async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo), title: const Text('Gallery'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
        ]),
      ),
    );
    if (src == null) return;
    final f = await ImagePicker().pickImage(source: src, maxWidth: 800, imageQuality: 50);
    if (f == null) return;
    final bytes = await f.readAsBytes();
    if (bytes.length > 700 * 1024) {
      if (mounted) snack(context, 'Photo is too large, please choose a smaller one.');
      return;
    }
    setState(() => _photo = base64Encode(bytes));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final user = context.read<AuthProvider>().user!;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      await DbService.submit(
        user: user, title: _title.text.trim(), category: _cat!, location: _loc!,
        description: _desc.text.trim(), priority: _priority, photo: _photo,
      );
      nav.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Complaint submitted successfully')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errMsg(e))));
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Submit Complaint')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Complaint Title *', hintText: 'e.g. AC not working in Classroom'), validator: _req),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Category *'),
            items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => _cat = v,
            validator: (v) => v == null ? 'Please select a category' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Department / Location *'),
            items: locations.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => _loc = v,
            validator: (v) => v == null ? 'Please select a location' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(controller: _desc, maxLines: 4, decoration: const InputDecoration(labelText: 'Description *', hintText: 'Describe your issue in detail...'), validator: _req),
          const SizedBox(height: 14),
          const Text('Add Photo (Optional)', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (_photo != null) ...[
            photoView(_photo!),
            TextButton(onPressed: () => setState(() => _photo = null), child: const Text('Remove photo')),
          ] else
            OutlinedButton.icon(onPressed: _pick, icon: const Icon(Icons.add_a_photo_outlined), label: const Text('Tap to upload image')),
          const SizedBox(height: 14),
          const Text('Priority *', style: TextStyle(fontWeight: FontWeight.w600)),
          Wrap(
            spacing: 8,
            children: ['Low', 'Medium', 'High']
                .map((p) => ChoiceChip(
              label: Text(p),
              selected: _priority == p,
              selectedColor: priorityColor(p).withOpacity(.3),
              onSelected: (_) => setState(() => _priority = p),
            ))
                .toList(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: C.secondary),
            onPressed: _busy ? null : _submit,
            child: _busy ? const CircularProgressIndicator() : const Text('Submit Complaint'),
          ),
        ]),
      ),
    ),
  );
}