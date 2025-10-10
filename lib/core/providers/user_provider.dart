import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/models/user_model.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';

final userProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authControllerProvider);

  if (authState.status == AuthStatus.authenticated) {
    final userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(authState.user!.uid)
        .snapshots();

    return userStream.map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data()!);
      }
      return null;
    });
  }
  return Stream.value(null);
});