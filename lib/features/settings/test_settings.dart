import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TestSettingsPage extends StatefulWidget {
  const TestSettingsPage({super.key});

  @override
  State<TestSettingsPage> createState() => TestSettingsPageState();
}

class TestSettingsPageState extends State<TestSettingsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  int testWordCount = 10;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        final doc =
            await firestore.collection('appUsers').doc(user.email).get();
        if (doc.exists) {
          setState(() {
            testWordCount = doc.data()?['testWordCount'] ?? 10;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> updateTestWordCount(int value) async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        await firestore.collection('appUsers').doc(user.email).update({
          'testWordCount': value,
        });
        setState(() {
          testWordCount = value;
        });
      }
    } catch (e) {
      print('Error updating test word count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Ayarları',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Kelime Sayısı',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Her testte kaç kelime sorulacağını belirleyin',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kelime Sayısı'),
                        DropdownButton<int>(
                          value: testWordCount,
                          items: [5, 10, 15, 20, 25, 30].map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value'),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              updateTestWordCount(newValue);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
