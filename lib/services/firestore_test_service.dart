import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTestService {
  static Future<void> addTestData() async {
    await FirebaseFirestore.instance.collection('test').add({
      'message': 'Emergency AI connected to Firebase',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}