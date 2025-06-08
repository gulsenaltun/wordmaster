import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dart:async';

import 'package:worlde_mobile/features/wordle/wordle_stats_page.dart';

class BoxColorNotifier extends ChangeNotifier {
  Color _color = Colors.transparent;

  Color get color => _color;

  void setColor(Color newColor) {
    _color = newColor;
    notifyListeners();
  }
}

class WordlePage extends StatefulWidget {
  const WordlePage({super.key});

  @override
  State<WordlePage> createState() => WordlePageState();
}

class WordlePageState extends State<WordlePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  List<String> knownWords = [];
  bool showGame = false;
  String targetWord = '';
  List<List<String>> guesses = [];
  List<List<ValueNotifier<Color>>> boxColors = [];
  int currentRow = 0;
  bool gameOver = false;
  bool gameWon = false;
  int maxAttempts = 5;

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  @override
  void dispose() {
    for (var row in boxColors) {
      for (var color in row) {
        color.dispose();
      }
    }
    super.dispose();
  }

  Future<void> loadWords() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        final doc =
            await firestore.collection('appUsers').doc(user.email).get();
        if (doc.exists) {
          final userData = doc.data() as Map<String, dynamic>;
          final words = userData['words'] as Map<String, dynamic>;
          knownWords = words.keys.toList();
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading words: $e');
    }
  }

  void startNewGame() {
    if (knownWords.isEmpty) return;

    knownWords.shuffle();
    targetWord = knownWords[0].toUpperCase();
    print('Yeni oyun başladı. Hedef kelime: $targetWord');

    guesses = List.generate(
      maxAttempts,
      (_) => List.filled(targetWord.length, ''),
    );

    boxColors = List.generate(
      maxAttempts,
      (row) => List.generate(
        targetWord.length,
        (col) => ValueNotifier<Color>(Colors.transparent),
      ),
    );

    setState(() {
      showGame = true;
      currentRow = 0;
      gameOver = false;
      gameWon = false;
    });
  }

  void handleLetterInput(String letter) {
    if (gameOver) return;

    final emptyIndex = guesses[currentRow].indexWhere((char) => char.isEmpty);
    if (emptyIndex == -1) return;

    print('Hedef kelime: $targetWord');
    print('Girilen harf: $letter');
    print('Mevcut satır: $currentRow');
    print('Boş kutu indeksi: $emptyIndex');

    setState(() {
      guesses[currentRow][emptyIndex] = letter.toUpperCase();

      if (targetWord[emptyIndex] == letter.toUpperCase()) {
        boxColors[currentRow][emptyIndex].value = Colors.green;
      } else if (targetWord.contains(letter.toUpperCase())) {
        boxColors[currentRow][emptyIndex].value = Colors.amber;
      } else {
        boxColors[currentRow][emptyIndex].value = Colors.grey;
      }

      if (emptyIndex == 4) {
        final currentGuess = guesses[currentRow].join();
        if (currentGuess == targetWord) {
          gameWon = true;
          gameOver = true;
          showResultDialog();
        } else if (currentRow == 5) {
          gameOver = true;
          showResultDialog();
        } else {
          currentRow++;
        }
      }
    });
  }

  void handleBackspace() {
    if (gameOver) return;

    final currentGuess = guesses[currentRow];
    final lastFilledIndex =
        currentGuess.lastIndexWhere((char) => char.isNotEmpty);

    if (lastFilledIndex != -1) {
      setState(() {
        guesses[currentRow][lastFilledIndex] = '';
      });
    }
  }

  void showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          gameWon ? 'Tebrikler!' : 'Tekrar Deneyin',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              gameWon ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              size: 64,
              color: gameWon ? Colors.amber : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              gameWon ? 'Kelimeyi buldunuz!' : 'Doğru kelime: $targetWord',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                showGame = false;
              });
            },
            child: const Text('Ana Menü'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startNewGame();
            },
            child: const Text('Yeni Oyun'),
          ),
        ],
      ),
    );
  }

  Widget buildLetterBox(String letter, int position, int row) {
    final displayLetter = guesses[row][position];
    final color = boxColors[row][position].value;

    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          displayLetter,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildKeyboard() {
    final keys = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              return Padding(
                padding: const EdgeInsets.all(1),
                child: SizedBox(
                  width: key == '⌫' ? 60 : 30,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      if (key == '⌫') {
                        handleBackspace();
                      } else {
                        handleLetterInput(key);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      key,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget buildGameScreen() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: List.generate(maxAttempts, (row) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(targetWord.length, (col) {
                          final letter = guesses[row][col];
                          return buildLetterBox(letter, col, row);
                        }),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: buildKeyboard(),
        ),
      ],
    );
  }

  Widget buildMainMenu() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                onTap: startNewGame,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.games,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bugünün Kelimesini Tahmin Et',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Öğrendiğin kelimelerden rastgele seçilen bir kelimeyi bul!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Oyunu Başlat',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.book,
                            size: 24,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Öğrendiğim Kelimeler',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${knownWords.length} kelime öğrendin',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.2),
                          ),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: knownWords.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .shadow
                                        .withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    knownWords[index],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTitleBox('W', true),
            buildTitleBox('O', false),
            buildTitleBox('R', false),
            buildTitleBox('D', false),
            buildTitleBox('L', false),
            buildTitleBox('E', false),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WordleStatsPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: showGame ? buildGameScreen() : buildMainMenu(),
      ),
    );
  }

  Widget buildTitleBox(String letter, bool isGreen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isGreen ? const Color(0xFF538D4E) : const Color(0xFFB59F3B),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
