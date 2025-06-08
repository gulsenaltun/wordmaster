import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WordleStatsPage extends StatefulWidget {
  const WordleStatsPage({super.key});

  @override
  State<WordleStatsPage> createState() => WordleStatsPageState();
}

class WordleStatsPageState extends State<WordleStatsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  Map<String, dynamic> gameStats = {};
  List<Map<String, dynamic>> recentGames = [];
  List<Map<String, dynamic>> difficultWords = [];

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        final doc =
            await firestore.collection('appUsers').doc(user.email).get();
        if (doc.exists) {
          final userData = doc.data() as Map<String, dynamic>;
          setState(() {
            gameStats = userData['gameStats'] ?? {};
            recentGames =
                List<Map<String, dynamic>>.from(userData['recentGames'] ?? []);
            difficultWords = List<Map<String, dynamic>>.from(
                userData['difficultWords'] ?? []);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading stats: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildStatCard(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(item),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyun İstatistikleri'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildStatCard(
                    'Genel İstatistikler',
                    [
                      'Toplam Oyun: ${gameStats['totalGames'] ?? 0}',
                      'Kazanılan: ${gameStats['wonGames'] ?? 0}',
                      'Kaybedilen: ${gameStats['lostGames'] ?? 0}',
                      'Ortalama Deneme: ${(gameStats['averageAttempts'] ?? 0).toStringAsFixed(1)}',
                      'Mevcut Seri: ${gameStats['currentStreak'] ?? 0}',
                      'En İyi Seri: ${gameStats['bestStreak'] ?? 0}',
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildStatCard(
                    'Son Oyunlar',
                    recentGames
                        .map((game) =>
                            '${game['word']} - ${game['result'] == 'won' ? 'Kazandı' : 'Kaybetti'} (${game['attempts']} deneme)')
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  buildStatCard(
                    'Zor Kelimeler',
                    difficultWords
                        .map((word) =>
                            '${word['word']} - ${word['failures']} kez başarısız')
                        .toList(),
                  ),
                ],
              ),
            ),
    );
  }
}

class Firebase_firestore {}
