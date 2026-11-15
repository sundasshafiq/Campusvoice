import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _ts(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();

class AppUser {
  final String uid, name, email, rollNumber, department, role;
  final int semester;
  final bool notificationsOn;
  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.rollNumber = '',
    this.department = '',
    this.semester = 1,
    this.role = 'student',
    this.notificationsOn = true,
  });
  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(String id, Map<String, dynamic> m) => AppUser(
    uid: id,
    name: m['fullName'] ?? '',
    email: m['email'] ?? '',
    rollNumber: m['rollNumber'] ?? '',
    department: m['department'] ?? '',
    semester: (m['semester'] as num? ?? 1).toInt(),
    role: m['role'] ?? 'student',
    notificationsOn: m['notificationsOn'] ?? true,
  );

  Map<String, dynamic> toMap() => {
    'fullName': name,
    'email': email,
    'rollNumber': rollNumber,
    'department': department,
    'semester': semester,
    'role': role,
    'notificationsOn': notificationsOn,
  };

  AppUser copyWith({String? name, String? rollNumber, String? department, int? semester, bool? notificationsOn}) =>
      AppUser(
        uid: uid,
        email: email,
        role: role,
        name: name ?? this.name,
        rollNumber: rollNumber ?? this.rollNumber,
        department: department ?? this.department,
        semester: semester ?? this.semester,
        notificationsOn: notificationsOn ?? this.notificationsOn,
      );
}

class Complaint {
  final String id, code, userId, studentName, title, category, location, description, priority, status;
  final String? photo; // base64 compressed image
  final DateTime createdAt;
  Complaint({
    required this.id,
    required this.code,
    required this.userId,
    required this.studentName,
    required this.title,
    required this.category,
    required this.location,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.photo,
  });
  factory Complaint.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return Complaint(
      id: d.id,
      code: m['code'] ?? '',
      userId: m['userId'] ?? '',
      studentName: m['studentName'] ?? '',
      title: m['title'] ?? '',
      category: m['category'] ?? '',
      location: m['location'] ?? '',
      description: m['description'] ?? '',
      priority: m['priority'] ?? 'Medium',
      status: m['status'] ?? 'Pending',
      photo: m['photo'],
      createdAt: _ts(m['createdAt']),
    );
  }
}

class HistoryEntry {
  final String stage, changedBy;
  final DateTime date;
  HistoryEntry(this.stage, this.changedBy, this.date);
  factory HistoryEntry.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return HistoryEntry(m['stage'] ?? '', m['changedBy'] ?? '', _ts(m['date']));
  }
}

class CommentItem {
  final String authorName, text;
  final bool isNote;
  final DateTime createdAt;
  CommentItem(this.authorName, this.text, this.isNote, this.createdAt);
  factory CommentItem.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return CommentItem(m['authorName'] ?? '', m['text'] ?? '', m['isNote'] ?? false, _ts(m['createdAt']));
  }
}

class NotifItem {
  final String id, complaintId, message;
  final bool isRead;
  final DateTime createdAt;
  NotifItem(this.id, this.complaintId, this.message, this.isRead, this.createdAt);
  factory NotifItem.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return NotifItem(d.id, m['complaintId'] ?? '', m['message'] ?? '', m['isRead'] ?? false, _ts(m['createdAt']));
  }
}