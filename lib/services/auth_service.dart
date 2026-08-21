import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Future<void> updateUserExtra(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('users').doc(uid).update(data);
  }

  static Future<UserCredential> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String languageCode,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final uid = credential.user!.uid;

    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'languageCode': languageCode,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  static Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}
