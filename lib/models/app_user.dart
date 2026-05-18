import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String countryCode;
  final String? gender;
  final DateTime? dateOfBirth;
  final int rewardPoints;
  final bool firstOrderCompleted;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.countryCode,
    required this.rewardPoints,
    required this.firstOrderCompleted,
    required this.createdAt,
    this.gender,
    this.dateOfBirth,
  });

  String get name => '$firstName $lastName'.trim();

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    String firstName = (data['firstName'] as String?) ?? '';
    String lastName = (data['lastName'] as String?) ?? '';
    if (firstName.isEmpty && lastName.isEmpty) {
      final legacy = (data['name'] as String?)?.trim() ?? '';
      if (legacy.isNotEmpty) {
        final parts = legacy.split(RegExp(r'\s+'));
        firstName = parts.first;
        lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }
    return AppUser(
      uid: doc.id,
      firstName: firstName,
      lastName: lastName,
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      countryCode: data['countryCode'] as String? ?? '+20',
      gender: data['gender'] as String?,
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      rewardPoints: (data['rewardPoints'] as num?)?.toInt() ?? 0,
      firstOrderCompleted: data['firstOrderCompleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'firstName': firstName,
        'lastName': lastName,
        'name': name,
        'email': email,
        'phone': phone,
        'countryCode': countryCode,
        'gender': gender,
        'dateOfBirth':
            dateOfBirth == null ? null : Timestamp.fromDate(dateOfBirth!),
        'rewardPoints': rewardPoints,
        'firstOrderCompleted': firstOrderCompleted,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? countryCode,
    String? gender,
    DateTime? dateOfBirth,
    int? rewardPoints,
    bool? firstOrderCompleted,
  }) =>
      AppUser(
        uid: uid,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email,
        phone: phone ?? this.phone,
        countryCode: countryCode ?? this.countryCode,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        rewardPoints: rewardPoints ?? this.rewardPoints,
        firstOrderCompleted: firstOrderCompleted ?? this.firstOrderCompleted,
        createdAt: createdAt,
      );
}
