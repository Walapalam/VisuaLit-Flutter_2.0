// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final int credits;
  final bool isPremium;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.credits = 0,
    this.isPremium = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'credits': credits,
      'isPremium': isPremium,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String?,
      credits: map['credits'] as int? ?? 0,
      isPremium: map['isPremium'] as bool? ?? false,
    );
  }
}