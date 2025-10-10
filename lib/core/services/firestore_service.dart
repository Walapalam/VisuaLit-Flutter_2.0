// lib/core/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visualit/core/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create or Update a user
  Future<void> setUser(UserModel user) async {
    final docRef = _db.collection('users').doc(user.uid);
    await docRef.set(user.toMap(), SetOptions(merge: true));
  }

  // Get a user
  Future<UserModel?> getUser(String uid) async {
    final docRef = _db.collection('users').doc(uid);
    final docSnap = await docRef.get();
    if (docSnap.exists) {
      return UserModel.fromMap(docSnap.data()!);
    }
    return null;
  }

  // Update user credits
  Future<void> updateUserCredits(String uid, int newCredits) async {
    final docRef = _db.collection('users').doc(uid);
    await docRef.update({'credits': newCredits});
  }

  // Update user premium status
  Future<void> updateUserPremiumStatus(String uid, bool isPremium) async {
    final docRef = _db.collection('users').doc(uid);
    final int credits = isPremium ? 100 : 20;
    await docRef.update({'isPremium': isPremium, 'credits': credits});
  }

  // Deduct credits for a user
  Future<void> deductCredits(String uid, int amount) async {
    final docRef = _db.collection('users').doc(uid);
    await docRef.update({'credits': FieldValue.increment(-amount)});
  }
}