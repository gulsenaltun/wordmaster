import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:worlde_mobile/features/auth/home_page.dart';
import 'package:worlde_mobile/features/auth/login_page.dart';

class Redirect extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(Color) onColorChanged;

  const Redirect({
    super.key,
    required this.onThemeChanged,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        if (user == null) {
          return Login(
            onThemeChanged: onThemeChanged,
            onColorChanged: onColorChanged,
          );
        }

        // Kullanıcı giriş yapmış, Firestore'da verisi var mı kontrol et
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appUsers')
              .doc(user.email)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Kullanıcı verisi yoksa veya hata varsa login sayfasına yönlendir
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              // Kullanıcı oturumunu sonlandır
              FirebaseAuth.instance.signOut();
              return Login(
                onThemeChanged: onThemeChanged,
                onColorChanged: onColorChanged,
              );
            }

            // Kullanıcı verisi varsa ana sayfaya yönlendir
            return HomePage(
              onThemeChanged: onThemeChanged,
              onColorChanged: onColorChanged,
            );
          },
        );
      },
    );
  }
}
