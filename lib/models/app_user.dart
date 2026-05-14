import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final int rewardPoints;
  final bool firstOrderCompleted;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.rewardPoints,
    required this.firstOrderCompleted,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      rewardPoints: (data['rewardPoints'] as num?)?.toInt() ?? 0,
      firstOrderCompleted: data['firstOrderCompleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'phone': phone,
        'rewardPoints': rewardPoints,
        'firstOrderCompleted': firstOrderCompleted,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  AppUser copyWith({
    String? name,
    String? phone,
    int? rewardPoints,
    bool? firstOrderCompleted,
  }) =>
      AppUser(
        uid: uid,
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        rewardPoints: rewardPoints ?? this.rewardPoints,
        firstOrderCompleted: firstOrderCompleted ?? this.firstOrderCompleted,
        createdAt: createdAt,
      );
}
