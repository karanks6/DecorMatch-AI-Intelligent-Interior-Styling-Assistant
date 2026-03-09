import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Users ─────────────────────────────────────────────

  /// Get a user document by ID
  Future<DocumentSnapshot> getUser(String userId) {
    return _db.collection('Users').doc(userId).get();
  }

  /// Create or update a user profile
  Future<void> saveUser({
    required String userId,
    required String email,
    required String name,
  }) {
    return _db.collection('Users').doc(userId).set({
      'user_id': userId,
      'email': email,
      'name': name,
      'saved_products': [],
      'analysis_history': [],
    }, SetOptions(merge: true));
  }

  /// Add a product to the user's saved list
  Future<void> saveProduct(String userId, String productId) {
    return _db.collection('Users').doc(userId).update({
      'saved_products': FieldValue.arrayUnion([productId]),
    });
  }

  /// Remove a product from saved list
  Future<void> unsaveProduct(String userId, String productId) {
    return _db.collection('Users').doc(userId).update({
      'saved_products': FieldValue.arrayRemove([productId]),
    });
  }

  // ─── Products ──────────────────────────────────────────

  /// Get all products
  Future<QuerySnapshot> getAllProducts() {
    return _db.collection('Products').get();
  }

  /// Get products filtered by style
  Future<QuerySnapshot> getProductsByStyle(String style) {
    return _db
        .collection('Products')
        .where('style_category', isEqualTo: style)
        .get();
  }

  /// Get a single product by ID
  Future<DocumentSnapshot> getProduct(String productId) {
    return _db.collection('Products').doc(productId).get();
  }

  // ─── Analyses ──────────────────────────────────────────

  /// Save an analysis result
  Future<DocumentReference> saveAnalysis({
    required String userId,
    required String imageUrl,
    required String detectedStyle,
    required List<String> dominantColors,
  }) async {
    final docRef = await _db.collection('Analyses').add({
      'user_id': userId,
      'image_url': imageUrl,
      'detected_style': detectedStyle,
      'dominant_colors': dominantColors,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Also add to user's analysis history
    await _db.collection('Users').doc(userId).update({
      'analysis_history': FieldValue.arrayUnion([docRef.id]),
    });

    return docRef;
  }

  /// Get analysis history for a user
  Future<QuerySnapshot> getUserAnalyses(String userId) {
    return _db
        .collection('Analyses')
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
  }
}
