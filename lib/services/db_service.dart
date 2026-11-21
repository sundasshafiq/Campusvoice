import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class DbService {
  static final _db = FirebaseFirestore.instance;
  static const statuses = ['Pending', 'In Progress', 'Resolved'];
  static int rank(String s) => statuses.indexOf(s);

  static Future<String> _nextCode() => _db.runTransaction<String>((tx) async {
    final ref = _db.collection('counters').doc('complaints');
    final snap = await tx.get(ref);
    final n = ((snap.data()?['count'] ?? 0) as num).toInt() + 1;
    tx.set(ref, {'count': n});
    return '#C${n.toString().padLeft(3, '0')}';
  });

  static Future<void> notify(String userId, String complaintId, String message) async {
    final u = await _db.collection('users').doc(userId).get();
    if (u.data()?['notificationsOn'] == false) return;
    await _db.collection('notifications').add({
      'userId': userId,
      'complaintId': complaintId,
      'message': message,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> submit({
    required AppUser user,
    required String title,
    required String category,
    required String location,
    required String description,
    required String priority,
    String? photo,
  }) async {
    final code = await _nextCode();
    final ref = _db.collection('complaints').doc();
    final batch = _db.batch();
    batch.set(ref, {
      'code': code, 'userId': user.uid, 'studentName': user.name, 'title': title,
      'category': category, 'location': location, 'description': description,
      'priority': priority, 'status': 'Pending', 'photo': photo,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(ref.collection('history').doc(), {
      'stage': 'Submitted', 'changedBy': user.name, 'date': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    final admins = await _db.collection('users').where('role', isEqualTo: 'admin').get();
    for (final a in admins.docs) {
      await notify(a.id, ref.id, 'New complaint $code: $title');
    }
  }

  static List<Complaint> _sorted(QuerySnapshot s) {
    final l = s.docs.map(Complaint.fromDoc).toList();
    l.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return l;
  }

  static Stream<List<Complaint>> myComplaints(String uid) =>
      _db.collection('complaints').where('userId', isEqualTo: uid).snapshots().map(_sorted);

  static Stream<List<Complaint>> allComplaints() =>
      _db.collection('complaints').snapshots().map(_sorted);

  static Stream<Complaint?> complaint(String id) => _db
      .collection('complaints').doc(id).snapshots()
      .map((d) => d.exists ? Complaint.fromDoc(d) : null);

  static Stream<List<HistoryEntry>> history(String id) =>
      _db.collection('complaints').doc(id).collection('history').snapshots().map((s) {
        final l = s.docs.map(HistoryEntry.fromDoc).toList();
        l.sort((a, b) => a.date.compareTo(b.date));
        return l;
      });

  static Stream<List<CommentItem>> comments(String id) =>
      _db.collection('complaints').doc(id).collection('comments').snapshots().map((s) {
        final l = s.docs.map(CommentItem.fromDoc).toList();
        l.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return l;
      });

  /// Set automatically when an admin opens a Pending complaint for the first time.
  static Future<void> markUnderReview(Complaint c, AppUser admin) async {
    if (c.status != 'Pending') return;
    final h = _db.collection('complaints').doc(c.id).collection('history');
    final ex = await h.where('stage', isEqualTo: 'Under Review').limit(1).get();
    if (ex.docs.isNotEmpty) return;
    await h.add({'stage': 'Under Review', 'changedBy': admin.name, 'date': FieldValue.serverTimestamp()});
    await notify(c.userId, c.id, 'Your complaint ${c.code} is now under review.');
  }

  static Future<void> updateStatus(Complaint c, String newStatus, AppUser admin) async {
    if (rank(newStatus) <= rank(c.status)) {
      throw 'A complaint can only move forward through its stages.';
    }
    final ref = _db.collection('complaints').doc(c.id);
    await ref.update({'status': newStatus});
    await ref.collection('history').add({
      'stage': newStatus, 'changedBy': admin.name, 'date': FieldValue.serverTimestamp(),
    });
    await notify(c.userId, c.id, 'Your complaint ${c.code} is now $newStatus.');
  }

  static Future<void> addComment(Complaint c, AppUser u, String text, {bool isNote = false}) async {
    await _db.collection('complaints').doc(c.id).collection('comments').add({
      'userId': u.uid, 'authorName': u.name, 'text': text, 'isNote': isNote,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (isNote) await notify(c.userId, c.id, 'Admin added a note on ${c.code}.');
  }

  static Stream<List<NotifItem>> notifications(String uid) =>
      _db.collection('notifications').where('userId', isEqualTo: uid).snapshots().map((s) {
        final l = s.docs.map(NotifItem.fromDoc).toList();
        l.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return l;
      });

  static Future<void> markRead(String id) =>
      _db.collection('notifications').doc(id).update({'isRead': true});

  static Future<void> markAllRead(List<NotifItem> l) async {
    final b = _db.batch();
    for (final n in l.where((n) => !n.isRead)) {
      b.update(_db.collection('notifications').doc(n.id), {'isRead': true});
    }
    await b.commit();
  }

  static Stream<List<AppUser>> users(String role) =>
      _db.collection('users').where('role', isEqualTo: role).snapshots().map((s) {
        final l = s.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList();
        l.sort((a, b) => a.name.compareTo(b.name));
        return l;
      });
}