import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:worlde_mobile/features/wordle/analysis_page.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  List<Map<String, dynamic>> testWords = [];
  int currentIndex = 0;
  bool isCorrect = false;
  bool showResult = false;
  int score = 0;
  bool isLoading = true;
  int wordCount = 10;
  String? selectedAnswer;
  List<String> currentOptions = [];
  List<Map<String, dynamic>> allTestResults = [];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (testWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Test'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz kelime eklenmemiş',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Test çözmek için önce kelime eklemelisiniz',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/addWord');
                },
                icon: const Icon(Icons.add),
                label: const Text('Kelime Ekle'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (allTestResults.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AnalysisPage(allTestResults: allTestResults),
                    ),
                  ),
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Analizleri Görüntüle'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final currentWord = testWords[currentIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              buildAppBar(),
              Expanded(
                child: buildTestContent(currentWord),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Boşluk Doldurma',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Puan: $score',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AnalysisPage(allTestResults: allTestResults),
              ),
            ),
            icon: const Icon(Icons.analytics_outlined),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget buildTestContent(Map<String, dynamic> currentWord) {
    final sentence = currentWord['sentence'] as String;
    final wordToGuess = currentWord['word'] as String;

    final displayText =
        sentence.replaceAll(RegExp(wordToGuess, caseSensitive: false), '_____');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildProgressIndicator(),
            const SizedBox(height: 32),
            buildQuestionCard(displayText, currentWord),
          ],
        ),
      ),
    );
  }

  Widget buildProgressIndicator() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (currentIndex + 1) / wordCount,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${currentIndex + 1}/$wordCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildQuestionCard(
      String displayText, Map<String, dynamic> currentWord) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Cümleyi Tamamla',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: currentOptions.map((option) {
                final isSelected = selectedAnswer == option;
                final isCorrect = option == currentWord['word'];

                Color backgroundColor = Theme.of(context).colorScheme.primary;
                if (showResult) {
                  if (isCorrect) {
                    backgroundColor = Colors.green;
                  } else if (isSelected) {
                    backgroundColor = Colors.red;
                  }
                }

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => checkAnswer(option),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: backgroundColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          option,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not logged in. Cannot load settings.');
        setState(() {
          isLoading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('appUsers')
          .doc(user.email)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        if (mounted) {
          setState(() {
            wordCount = data['wordCount'] ?? 10;
            allTestResults =
                List<Map<String, dynamic>>.from(data['testSolved'] ?? []);
            isLoading = false;
          });
        }
      }
      await loadWords();
    } catch (e) {
      print('Error loading settings: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> loadWords() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not logged in. Cannot load words.');
        setState(() {
          isLoading = false;
        });
        return;
      }

      final now = DateTime.now();

      final wordsSnapshot =
          await FirebaseFirestore.instance.collection('words').get();

      if (wordsSnapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final allWordsFromDb = wordsSnapshot.docs.first.data();

      final userDoc = await FirebaseFirestore.instance
          .collection('appUsers')
          .doc(user.email)
          .get();

      List<String> learningWords = [];
      List<String> knownWords = [];
      Map<String, dynamic> wordProgressMap = {};
      if (userDoc.exists) {
        learningWords =
            List<String>.from(userDoc.data()?['learningWords'] ?? []);
        knownWords = List<String>.from(userDoc.data()?['knownWords'] ?? []);
        wordProgressMap =
            Map<String, dynamic>.from(userDoc.data()?['wordProgress'] ?? {});
      }

      List<Map<String, dynamic>> wordsDueForReview = [];
      List<Map<String, dynamic>> newWordsAvailable = [];

      allWordsFromDb.forEach((wordId, wordData) {
        if (knownWords.contains(wordId)) {
          return;
        }

        if (learningWords.contains(wordId)) {
          final progressForWord = wordProgressMap[wordId];
          if (progressForWord != null &&
              progressForWord['nextReviewDate'] != null) {
            final nextReviewDate =
                DateTime.parse(progressForWord['nextReviewDate']);
            if (nextReviewDate.isBefore(now)) {
              wordsDueForReview.add({
                'word': wordId,
                'meaning': wordData['meaning'],
                'sentence': wordData['sentence'],
              });
            }
          } else {
            wordsDueForReview.add({
              'word': wordId,
              'meaning': wordData['meaning'],
              'sentence': wordData['sentence'],
            });
          }
        } else {
          if (!wordProgressMap.containsKey(wordId) ||
              (wordProgressMap[wordId]['status'] != 'mastered' &&
                  wordProgressMap[wordId]['status'] != 'learning')) {
            newWordsAvailable.add({
              'word': wordId,
              'meaning': wordData['meaning'],
              'sentence': wordData['sentence'],
            });
          }
        }
      });

      wordsDueForReview.shuffle();
      newWordsAvailable.shuffle();

      List<Map<String, dynamic>> finalTestWords = [];
      finalTestWords.addAll(wordsDueForReview);

      int neededNewWords = wordCount - finalTestWords.length;
      if (neededNewWords > 0) {
        finalTestWords.addAll(newWordsAvailable.take(neededNewWords));
      }

      if (finalTestWords.length > wordCount) {
        finalTestWords = finalTestWords.take(wordCount).toList();
      }

      finalTestWords.shuffle();

      setState(() {
        testWords = finalTestWords;
        isLoading = false;
        generateOptions();
      });
    } catch (e) {
      print('Error loading words: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void generateOptions() {
    if (testWords.isEmpty) return;
    final currentWord = testWords[currentIndex];
    final correctAnswer = currentWord['word'];

    final wrongAnswers = testWords
        .where((q) => q['word'] != correctAnswer)
        .map((q) => q['word'])
        .toList()
      ..shuffle();

    currentOptions = [
      correctAnswer,
      ...wrongAnswers.take(3),
    ]..shuffle();
  }

  Future<void> checkAnswer(String answer) async {
    if (showResult) return;

    final currentWord = testWords[currentIndex];
    final correctAnswer = currentWord['word'];

    final isCorrect = answer.toLowerCase() == correctAnswer.toLowerCase();

    setState(() {
      this.isCorrect = isCorrect;
      showResult = true;
      selectedAnswer = answer;

      if (isCorrect) {
        score++;
      }
    });

    await saveTestResult(currentWord, isCorrect);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (currentIndex < wordCount - 1) {
          setState(() {
            currentIndex++;
            showResult = false;
            selectedAnswer = null;
            generateOptions();
          });
        } else {
          showResults();
        }
      }
    });
  }

  void showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  score > wordCount / 2 ? Icons.emoji_events : Icons.school,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                score > wordCount / 2 ? 'Tebrikler!' : 'Tekrar Dene!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              buildAnalysisRow('Puanınız', '$score/$wordCount'),
              buildAnalysisRow('Başarı Oranı',
                  '${((score / wordCount) * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        currentIndex = 0;
                        score = 0;
                        showResult = false;
                        selectedAnswer = null;
                        testWords.shuffle();
                        generateOptions();
                      });
                      loadSettings();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Ana Sayfa'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAnalysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> saveTestResult(Map<String, dynamic> word, bool isCorrect) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not logged in. Cannot save test result.');
        return;
      }

      final now = DateTime.now();
      final wordId = word['word'];

      final userDocRef =
          FirebaseFirestore.instance.collection('appUsers').doc(user.email);
      final userDocSnapshot = await userDocRef.get();

      Map<String, dynamic> userData = userDocSnapshot.data() ?? {};

      Map<String, dynamic> wordProgressMap =
          Map<String, dynamic>.from(userData['wordProgress'] ?? {});

      Map<String, dynamic> wordProgress =
          Map<String, dynamic>.from(wordProgressMap[wordId] ??
              {
                'correctCount': 0,
                'lastCorrectDate': null,
                'nextReviewDate': null,
                'reviewDates': [],
                'status': 'learning'
              });

      if (isCorrect) {
        wordProgress['correctCount'] = (wordProgress['correctCount'] ?? 0) + 1;
        wordProgress['lastCorrectDate'] = now.toIso8601String();

        DateTime nextReviewDate;
        switch (wordProgress['correctCount']) {
          case 1:
            nextReviewDate = now.add(const Duration(days: 1));
            break;
          case 2:
            nextReviewDate = now.add(const Duration(days: 7));
            break;
          case 3:
            nextReviewDate = now.add(const Duration(days: 30));
            break;
          case 4:
            nextReviewDate = now.add(const Duration(days: 90));
            break;
          case 5:
            nextReviewDate = now.add(const Duration(days: 180));
            break;
          case 6:
            nextReviewDate = now.add(const Duration(days: 365));
            break;
          default:
            nextReviewDate = now.add(const Duration(days: 1));
        }

        wordProgress['nextReviewDate'] = nextReviewDate.toIso8601String();

        List<String> reviewDates =
            List<String>.from(wordProgress['reviewDates'] ?? []);
        if (!reviewDates.contains(nextReviewDate.toIso8601String())) {
          reviewDates.add(nextReviewDate.toIso8601String());
        }
        wordProgress['reviewDates'] = reviewDates;

        if (wordProgress['correctCount'] >= 6) {
          wordProgress['status'] = 'mastered';
          await userDocRef.update({
            'knownWords': FieldValue.arrayUnion([wordId]),
            'learningWords': FieldValue.arrayRemove([wordId]),
          });
        } else {
          await userDocRef.update({
            'learningWords': FieldValue.arrayUnion([wordId]),
          });
        }
      } else {
        wordProgress['correctCount'] = 0;
        wordProgress['nextReviewDate'] =
            now.add(const Duration(days: 1)).toIso8601String();
        wordProgress['status'] = 'learning';

        await userDocRef.update({
          'learningWords': FieldValue.arrayUnion([wordId]),
          'knownWords': FieldValue.arrayRemove([wordId]),
        });
      }

      wordProgressMap[wordId] = wordProgress;
      await userDocRef.update({'wordProgress': wordProgressMap});

      Map<String, dynamic> newTestResult = {
        'wordId': wordId,
        'isCorrect': isCorrect,
        'date': now.toIso8601String(),
        'correctCount': wordProgress['correctCount'],
      };
      await userDocRef.update({
        'testSolved': FieldValue.arrayUnion([newTestResult])
      });
    } catch (e) {
      print('Error saving test result: $e');
    }
  }
}
