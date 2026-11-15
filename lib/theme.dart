import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const primary = Color(0xFF2563EB);
  static const secondary = Color(0xFF8B5CF6);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const bg = Color(0xFFF8FAFC);
}

const categories = ['Facilities', 'Academic', 'IT & Labs', 'Transport', 'Others'];
const locations = [
  'Library', 'Computer Lab', 'Classroom', 'Cafeteria / Mess', 'Hostel',
  'Transport / Bus', 'Admin Block', 'Sports Ground', 'Washroom', 'Other'
];
const departments = [
  'Computer Science', 'Information Technology', 'Software Engineering',
  'Electrical Engineering', 'Business Administration', 'Mathematics', 'Physics'
];

ThemeData buildTheme(Color seed) => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: seed, primary: seed),
  scaffoldBackgroundColor: C.bg,
  textTheme: GoogleFonts.poppinsTextTheme(),
  appBarTheme: const AppBarTheme(backgroundColor: C.bg, elevation: 0, scrolledUnderElevation: 0),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);