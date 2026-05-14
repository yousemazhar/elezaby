import 'package:cloud_firestore/cloud_firestore.dart';

class RewardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addPoints(String uid, int points) async {
    await _db.collection('users').doc(uid).update({
      'rewardPoints': FieldValue.increment(points),
    });
  }

  Future<void> markFirstOrderCompleted(String uid) async {
    await _db.collection('users').doc(uid).update({
      'firstOrderCompleted': true,
    });
  }
}
