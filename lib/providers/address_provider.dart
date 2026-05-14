import 'dart:async';
import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _service = AddressService();

  List<Address> _addresses = [];
  StreamSubscription<List<Address>>? _sub;
  bool _loading = false;
  String? _uid;

  List<Address> get addresses => _addresses;
  bool get loading => _loading;

  Address? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  void startListening(String uid) {
    if (_uid == uid) return;
    _uid = uid;
    _loading = true;
    notifyListeners();
    _sub?.cancel();
    _sub = _service.addressStream(uid).listen(
      (list) {
        _addresses = list;
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _sub?.cancel();
    _sub = null;
    _uid = null;
    _addresses = [];
    _loading = false;
    notifyListeners();
  }

  Future<void> addAddress(Address address) async {
    if (_uid == null) return;
    await _service.addAddress(_uid!, address);
  }

  Future<void> updateAddress(Address address) async {
    if (_uid == null) return;
    await _service.updateAddress(_uid!, address);
  }

  Future<void> deleteAddress(String addressId) async {
    if (_uid == null) return;
    await _service.deleteAddress(_uid!, addressId);
  }

  Future<void> setDefault(String addressId) async {
    if (_uid == null) return;
    await _service.setDefault(_uid!, addressId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
