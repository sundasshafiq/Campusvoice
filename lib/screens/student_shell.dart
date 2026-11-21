import 'package:flutter/material.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'my_complaints_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'submit_complaint_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});
  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int i = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: i, children: [
      HomeScreen(onTab: (n) => setState(() => i = n)),
      const MyComplaintsScreen(),
      const SizedBox(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ]),
    bottomNavigationBar: NavigationBar(
      selectedIndex: i,
      onDestinationSelected: (n) {
        if (n == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitComplaintScreen()));
          return;
        }
        setState(() => i = n);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Complaints'),
        NavigationDestination(
          icon: CircleAvatar(radius: 18, backgroundColor: C.secondary, child: Icon(Icons.add, color: Colors.white)),
          label: 'New',
        ),
        NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
  );
}