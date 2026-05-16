import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Central service for all user-specific Firestore & Storage operations.
class UserService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static FirebaseStorage get _storage => FirebaseStorage.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static String _safeId(String raw) =>
      raw.replaceAll(RegExp(r'[^\w]'), '_').toLowerCase();

  // ── Stats Stream (real-time) ─────────────────────────────────────────────────

  static Stream<DocumentSnapshot<Map<String, dynamic>>> statsStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('stats')
        .doc('summary')
        .snapshots();
  }

  static Future<void> _updateStats(Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('stats')
        .doc('summary')
        .set(data, SetOptions(merge: true));
  }

  static Future<void> incrementAnalysis() =>
      _updateStats({'analysisCount': FieldValue.increment(1)});

  static Future<void> incrementArViews() =>
      _updateStats({'arViewCount': FieldValue.increment(1)});

  static Future<void> _incrementSavedCount() =>
      _updateStats({'savedCount': FieldValue.increment(1)});

  static Future<void> _decrementSavedCount() =>
      _updateStats({'savedCount': FieldValue.increment(-1)});

  // ── Analysis History ─────────────────────────────────────────────────────────

  static Future<void> saveAnalysis({
    required Map<String, dynamic> analysis,
    required int recommendationCount,
    required String roomType,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('analysisHistory')
        .add({
      'style': analysis['style'] ?? 'Unknown',
      'confidence': analysis['confidence'] ?? 0.0,
      'dominant_colors': analysis['dominant_colors'] ?? [],
      'detected_items': analysis['detected_items'] ?? [],
      'roomType': roomType,
      'recommendationCount': recommendationCount,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await incrementAnalysis();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> analysisHistoryStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('analysisHistory')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ── Saved Items ──────────────────────────────────────────────────────────────

  static Future<void> saveItem(Map<String, dynamic> product) async {
    final uid = _uid;
    if (uid == null) return;
    final id = _safeId(
        (product['product_id'] ?? product['name'] ?? DateTime.now().millisecondsSinceEpoch.toString()).toString());
    await _db
        .collection('users')
        .doc(uid)
        .collection('savedItems')
        .doc(id)
        .set({...product, '_savedAt': FieldValue.serverTimestamp()});
    await _incrementSavedCount();
  }

  static Future<void> removeSavedItem(String rawId) async {
    final uid = _uid;
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('savedItems')
        .doc(_safeId(rawId))
        .delete();
    await _decrementSavedCount();
  }

  static Future<bool> isItemSaved(String rawId) async {
    final uid = _uid;
    if (uid == null) return false;
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('savedItems')
        .doc(_safeId(rawId))
        .get();
    return doc.exists;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> savedItemsStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('savedItems')
        .orderBy('_savedAt', descending: true)
        .snapshots();
  }

  // ── Style Preferences ────────────────────────────────────────────────────────

  static Future<void> saveStylePreferences(List<String> styles) async {
    final uid = _uid;
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('preferences')
        .doc('styles')
        .set({'styles': styles});
  }

  static Future<List<String>> getStylePreferences() async {
    final uid = _uid;
    if (uid == null) return [];
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('preferences')
        .doc('styles')
        .get();
    if (doc.exists) {
      return List<String>.from(doc.data()?['styles'] ?? []);
    }
    return [];
  }

  // ── Profile Image ────────────────────────────────────────────────────────────

  static Future<String?> uploadProfileImage(File imageFile) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not signed in.');

    // Read file as bytes — more reliable on Android than putFile()
    final Uint8List bytes = await imageFile.readAsBytes();
    final ref = _storage.ref().child('users').child(uid).child('profile.jpg');
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    try {
      final snapshot = await ref.putData(bytes, metadata);
      final url = await snapshot.ref.getDownloadURL();
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(url);
      return url;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found' || e.code == 'bucket-not-found') {
        throw Exception(
            'Firebase Storage is not set up.\n\nGo to Firebase Console → Build → Storage → Get Started, then set rules to allow authenticated users.');
      }
      if (e.code == 'unauthorized') {
        throw Exception(
            'Storage permission denied. Update Firebase Storage rules to allow uploads.');
      }
      rethrow;
    }
  }
}
