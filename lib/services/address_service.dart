import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address.dart';

class AddressService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('addresses');

  Stream<List<Address>> addressStream(String uid) {
    return _col(uid).orderBy('isDefault', descending: true).snapshots().map(
          (snap) => snap.docs.map(Address.fromDoc).toList(),
        );
  }

  Future<void> addAddress(String uid, Address address) async {
    if (address.isDefault) {
      await _clearDefault(uid);
    }
    await _col(uid).add(address.toMap());
  }

  Future<void> updateAddress(String uid, Address address) async {
    if (address.isDefault) {
      await _clearDefault(uid, exceptId: address.id);
    }
    await _col(uid).doc(address.id).update(address.toMap());
  }

  Future<void> deleteAddress(String uid, String addressId) async {
    await _col(uid).doc(addressId).delete();
  }

  Future<void> setDefault(String uid, String addressId) async {
    await _clearDefault(uid);
    await _col(uid).doc(addressId).update({'isDefault': true});
  }

  Future<void> _clearDefault(String uid, {String? exceptId}) async {
    final snap = await _col(uid).where('isDefault', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      if (doc.id != exceptId) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }
    await batch.commit();
  }
}
