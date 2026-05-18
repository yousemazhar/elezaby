import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String countryCode,
    required String mobile,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    final appUser = AppUser(
      uid: user.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: '$countryCode$mobile',
      countryCode: countryCode,
      gender: gender,
      dateOfBirth: dateOfBirth,
      rewardPoints: 0,
      firstOrderCompleted: false,
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(user.uid).set(appUser.toFirestore());
    return appUser;
  }

  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _fetchAppUser(cred.user!.uid);
  }

  Future<AppUser?> signInWithMobile({
    required String countryCode,
    required String mobile,
    required String password,
  }) async {
    final phone = '$countryCode$mobile';
    final snap = await _db
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No account found with this mobile number.',
      );
    }
    final email = snap.docs.first.data()['email'] as String?;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No account found with this mobile number.',
      );
    }
    return signInWithEmail(email: email, password: password);
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<AppUser?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    final user = cred.user!;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      final display = (user.displayName ?? '').trim();
      final parts =
          display.isEmpty ? <String>[] : display.split(RegExp(r'\s+'));
      final appUser = AppUser(
        uid: user.uid,
        firstName: parts.isNotEmpty ? parts.first : '',
        lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
        email: user.email ?? '',
        phone: user.phoneNumber ?? '',
        countryCode: '+20',
        rewardPoints: 0,
        firstOrderCompleted: false,
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(user.uid).set(appUser.toFirestore());
      return appUser;
    }
    return AppUser.fromFirestore(doc);
  }

  Future<AppUser?> fetchAppUser(String uid) => _fetchAppUser(uid);

  Future<AppUser?> _fetchAppUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first : '';
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    await _db.collection('users').doc(uid).update({
      'name': name,
      'firstName': first,
      'lastName': last,
      'phone': phone,
    });
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
