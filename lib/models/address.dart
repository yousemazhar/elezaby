import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  final String id;
  final String label; // 'Home', 'Work', 'Other'
  final String street;
  final String area;
  final String city;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.street,
    required this.area,
    required this.city,
    this.isDefault = false,
  });

  String get displayLine => '$street, $area';
  String get fullAddress => '$street, $area, $city';

  factory Address.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Address(
      id: doc.id,
      label: d['label'] as String? ?? 'Home',
      street: d['street'] as String? ?? '',
      area: d['area'] as String? ?? '',
      city: d['city'] as String? ?? '',
      isDefault: d['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'label': label,
        'street': street,
        'area': area,
        'city': city,
        'isDefault': isDefault,
      };

  Address copyWith({
    String? id,
    String? label,
    String? street,
    String? area,
    String? city,
    bool? isDefault,
  }) =>
      Address(
        id: id ?? this.id,
        label: label ?? this.label,
        street: street ?? this.street,
        area: area ?? this.area,
        city: city ?? this.city,
        isDefault: isDefault ?? this.isDefault,
      );
}
