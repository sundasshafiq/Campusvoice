import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _users = FirebaseFirestore.instance.collection('users');

  static Future<AppUser?> profile(String uid) async {
    final d = await _users.doc(uid).get();
    if (!d.exists) return null;
    return AppUser.fromMap(d.id, d.data()!);
  }

  static Future<UserCredential> signIn(String email, String pw) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: pw);

  static Future<AppUser> register(AppUser u, String pw) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: u.email.trim(), password: pw);
    final user = AppUser(
      uid: cred.user!.uid, name: u.name, email: u.email.trim(), rollNumber: u.rollNumber,
      department: u.department, semester: u.semester, role: 'student',
    );
    await _users.doc(user.uid).set(user.toMap());
    return user;
  }

  static Future<void> reset(String email) => _auth.sendPasswordResetEmail(email: email.trim());
  static Future<void> signOut() => _auth.signOut();

  static Future<void> updateProfile(AppUser u) => _users.doc(u.uid).update({
    'fullName': u.name, 'rollNumber': u.rollNumber, 'department': u.department,
    'semester': u.semester, 'notificationsOn': u.notificationsOn,
  });
}