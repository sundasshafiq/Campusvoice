import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/admin_shell.dart';
import 'screens/splash_screen.dart';
import 'screens/student_shell.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(create: (_) => AuthProvider(), child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AuthProvider>().user?.isAdmin == true;
    return MaterialApp(
      title: 'CampusVoice',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(admin ? C.success : C.primary),
      home: const Root(),
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) {
    final a = context.watch<AuthProvider>();
    if (a.loading) return const SplashScreen(loading: true);
    if (a.user == null) return const SplashScreen();
    return a.user!.isAdmin ? const AdminShell() : const StudentShell();
  }
}