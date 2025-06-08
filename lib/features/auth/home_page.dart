import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:worlde_mobile/features/settings/settings_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:worlde_mobile/features/word_management/add_word_page.dart';
import 'package:worlde_mobile/features/wordle/test_page.dart';
import 'package:worlde_mobile/features/wordle/wordle_page.dart';

class HomePage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(Color) onColorChanged;

  const HomePage({
    super.key,
    required this.onThemeChanged,
    required this.onColorChanged,
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const HomeContent(),
      const TestPage(),
      const AddWordPage(),
      const WordlePage(),
      SettingsPage(
        onThemeChanged: widget.onThemeChanged,
        onColorChanged: widget.onColorChanged,
      ),
    ];
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildNavItem(Icons.home, 'Ana Sayfa', 0),
                buildNavItem(Icons.assignment_turned_in_rounded, 'Test', 1),
                buildNavItem(Icons.add_circle_outline, 'Kelime Ekle', 2),
                buildNavItem(Icons.games, 'Wordle', 3),
                buildNavItem(Icons.settings, 'Ayarlar', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNavItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withAlpha(25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isSelected ? 1.1 : 1.0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 200),
                offset: isSelected ? const Offset(0, -0.05) : Offset.zero,
                child: Icon(
                  icon,
                  size: isSelected ? 24 : 22,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  int totalWords = 0; // Toplam kelime sayısı
  int learnedWords = 0; // Öğreniliyor olan kelime sayısı
  int knownWords = 0; // Öğrenilmiş kelime sayısı

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    // Clean up any listeners or subscriptions here
    super.dispose();
  }

  Future<void> loadUserData() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        final doc =
            await firestore.collection('appUsers').doc(user.email).get();
        if (doc.exists && mounted) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            userData = data;
            if (data['words'] != null) {
              final words = data['words'] as Map<String, dynamic>;
              totalWords = words.length;

              knownWords = (data['knownWords'] as List<dynamic>?)?.length ?? 0;
              learnedWords =
                  (data['learningWords'] as List<dynamic>?)?.length ?? 0;
            }
            isLoading = false;
          });
        } else if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      } else if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    final headerColor = Theme.of(context).colorScheme.primary;
    final isHeaderLight = isColorLight(headerColor);
    final headerTextColor = isHeaderLight ? Colors.black87 : Colors.white;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    headerColor,
                    headerColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Merhaba,',
                              style: TextStyle(
                                fontSize: 16,
                                color: headerTextColor.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userData?['username'] ?? 'Kullanıcı',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: headerTextColor,
                              ),
                            ),
                          ],
                        ),
                        Hero(
                          tag: 'profile_picture',
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(
                                userData?['imageURL'] ??
                                    'https://via.placeholder.com/150',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildStatItem(
                          context,
                          Icons.assignment_turned_in_rounded,
                          '${userData?['testsSolved'] ?? 0}',
                          'Çözülen Test',
                          headerTextColor,
                        ),
                        buildStatItem(
                          context,
                          Icons.book,
                          '${knownWords + learnedWords}',
                          'Öğrenilen Kelime',
                          headerTextColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            buildProgressSection(),
          ],
        ),
      ),
    );
  }

  bool isColorLight(Color color) {
    return color.computeLuminance() > 0.5;
  }

  Widget buildStatItem(BuildContext context, IconData icon, String value,
      String label, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProgressItem(
      BuildContext context, Color color, String label, String value) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final textColor = isLightTheme ? Colors.black87 : Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget buildProgressSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kelime İlerlemesi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: Stack(
                        children: [
                          Center(
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: learnedWords.toDouble(),
                                    title: '$learnedWords',
                                    color: const Color(0xFFB59F3B),
                                    radius: 85,
                                    titleStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    titlePositionPercentageOffset: 0.5,
                                  ),
                                  PieChartSectionData(
                                    value: knownWords.toDouble(),
                                    title: '$knownWords',
                                    color: const Color(0xFF538D4E),
                                    radius: 85,
                                    titleStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    titlePositionPercentageOffset: 0.5,
                                  ),
                                  PieChartSectionData(
                                    value: (totalWords -
                                            (learnedWords + knownWords))
                                        .toDouble(),
                                    title:
                                        '${totalWords - (learnedWords + knownWords)}',
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.grey[400]!
                                        : Colors.grey[700]!,
                                    radius: 85,
                                    titleStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    titlePositionPercentageOffset: 0.5,
                                  ),
                                ],
                                sectionsSpace: 2,
                                centerSpaceRadius: 45,
                                startDegreeOffset: -90,
                                centerSpaceColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${((knownWords / totalWords) * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF538D4E),
                                  ),
                                ),
                                const Text(
                                  'Tamamlandı',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey[100]
                                  : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildProgressItem(
                              context,
                              const Color(0xFFB59F3B),
                              'Öğreniliyor',
                              '$learnedWords',
                            ),
                            const SizedBox(height: 8),
                            buildProgressItem(
                              context,
                              const Color(0xFF538D4E),
                              'Öğrenilmiş',
                              '$knownWords',
                            ),
                            const SizedBox(height: 8),
                            buildProgressItem(
                              context,
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey[600]!
                                  : Colors.grey[400]!,
                              'Toplam',
                              '$totalWords',
                            ),
                          ],
                        ),
                      ),
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
