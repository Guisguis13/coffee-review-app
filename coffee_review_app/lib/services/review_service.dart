import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Singleton pattern to ensure only one instance of ReviewService exists
  Future<void> submitReview(
    String placeId,
    String name,
    int rating,
    String comment,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User is not logged in.");
    }
    // try to add the review to the Firestore collection
    // if it fails, rethrow the error
    try {
      await _firestore.collection('reviews').add({
        'place_id': placeId,
        'place_name': name,
        'rating': rating,
        'comment': comment,
        'user_id': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
