import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      final result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerEmailPassword(
    String username,
    String email,
    String password,
    String date,
  ) async {
    UserCredential? userCredential;

    try {
      final userDoc = await firestore.collection('appUsers').doc(email).get();

      if (userDoc.exists) {
        throw 'Bu email adresi zaten kullanımda.';
      }

      final wordsDoc = await firestore.collection('words').doc('all').get();
      Map<String, dynamic> words = {};

      if (wordsDoc.exists && wordsDoc.data() != null) {
        words = wordsDoc.data()!;
      }
      final userData = {
        'username': username,
        'email': email,
        'imageURL': "",
        'creationDate': date,
        'words': words,
        'knownWords': <String>[],
        'learningWords': <String>[],
        'testsSolved': 0,
        'testWordCount': 10,
      };

      userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      try {
        await firestore.collection("appUsers").doc(email).set(userData);
      } catch (firestoreError) {
        if (userCredential.user != null) {
          await userCredential.user!.delete();
        }
        throw 'Kullanıcı verileri kaydedilemedi. Lütfen tekrar deneyin.';
      }
      if (auth.currentUser == null) {
        try {
          await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (signInError) {
          throw 'Oturum açılamadı. Lütfen tekrar giriş yapın.';
        }
      }
    } catch (e) {
      if (e is FirebaseAuthException && userCredential?.user != null) {
        await userCredential!.user!.delete();
      }

      rethrow;
    }
  }
}
