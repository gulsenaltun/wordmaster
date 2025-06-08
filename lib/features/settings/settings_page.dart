import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:worlde_mobile/features/auth/login_page.dart';

class SettingsPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(Color) onColorChanged;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.onColorChanged,
  });

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final TextEditingController usernameController = TextEditingController();

  File? profileImage;
  String selectedTheme = 'Sistem';
  Color selectedColor = Colors.green;
  double wordCount = 10;
  bool isLoading = true;
  Map<String, dynamic>? userData;

  final ImagePicker imagePicker = ImagePicker();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadSettings();
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildProfileSettingsCard(context),
          const SizedBox(height: 16),
          buildThemeSettingsCard(context),
          const SizedBox(height: 16),
          buildTestSettingsCard(context),
          const SizedBox(height: 16),
          buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget buildProfileSettingsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Profil Ayarları',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: handleImagePick,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: profileImage != null
                          ? ClipOval(
                              child: Image.file(
                                profileImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: handleImagePick,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'İsim Soyisim',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if (userData != null) {
                    userData!['username'] = value;
                  }
                });
                saveUserData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildThemeSettingsCard(BuildContext context) {
    return buildSettingCard(
      context,
      title: 'Tema Ayarları',
      subtitle: 'Uygulama görünümünü özelleştirin',
      icon: Icons.palette,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThemeSettingsPage(
              selectedTheme: selectedTheme,
              selectedColor: selectedColor,
              onThemeChanged: (theme) {
                setState(() {
                  selectedTheme = theme;
                });
                saveSettings();
              },
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                });
                saveSettings();
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildTestSettingsCard(BuildContext context) {
    return buildSettingCard(
      context,
      title: 'Test Ayarları',
      subtitle: 'Test deneyiminizi kişiselleştirin',
      icon: Icons.quiz,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestSettingsPage(
              wordCount: wordCount,
              onWordCountChanged: (count) {
                setState(() {
                  wordCount = count;
                });
                saveSettings();
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: handleLogout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout),
          SizedBox(width: 8),
          Text('Çıkış Yap'),
        ],
      ),
    );
  }

  Widget buildSettingCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadUserData() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        final doc =
            await firestore.collection('appUsers').doc(user.email).get();
        if (doc.exists) {
          setState(() {
            userData = doc.data();
            usernameController.text = userData?['username'] ?? '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadSettings() async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString('theme') ?? 'Sistem';
      final colorValue = prefs.getInt('themeColor') ?? Colors.green.value;

      final user = auth.currentUser;
      if (user != null) {
        final doc =
            await firestore.collection('appUsers').doc(user.email).get();

        if (doc.exists) {
          final wordCount = doc.data()?['wordCount'] ?? 10;
          setState(() {
            this.wordCount = wordCount.toDouble();
          });
        }
      }

      setState(() {
        selectedTheme = theme;
        selectedColor = Color(colorValue);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading settings: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme', selectedTheme);
      await prefs.setInt('themeColor', selectedColor.value);

      final user = auth.currentUser;
      if (user != null) {
        await firestore.collection('appUsers').doc(user.email).update({
          'wordCount': wordCount.round(),
        });
      }

      widget.onThemeChanged(getThemeMode());
      widget.onColorChanged(selectedColor);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  Future<void> handleImagePick() async {
    try {
      final XFile? image =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          profileImage = File(image.path);
        });
        await saveUserData();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> saveUserData() async {
    try {
      final user = auth.currentUser;
      if (user != null && userData != null) {
        await firestore
            .collection('appUsers')
            .doc(user.email)
            .update(userData!);
      }
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  ThemeMode getThemeMode() {
    switch (selectedTheme) {
      case 'Açık':
        return ThemeMode.light;
      case 'Koyu':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> handleLogout() async {
    try {
      await auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Login(
              onThemeChanged: widget.onThemeChanged,
              onColorChanged: widget.onColorChanged,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}

class ThemeSettingsPage extends StatelessWidget {
  final String selectedTheme;
  final Color selectedColor;
  final Function(String) onThemeChanged;
  final Function(Color) onColorChanged;

  const ThemeSettingsPage({
    super.key,
    required this.selectedTheme,
    required this.selectedColor,
    required this.onThemeChanged,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema Ayarları'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildSection(
            context,
            title: 'Tema Modu',
            subtitle: 'Uygulamanın görünümünü seçin',
            icon: Icons.brightness_6,
            child: Column(
              children: [
                buildThemeCard(
                  context,
                  title: 'Sistem',
                  description: 'Sistem temasını kullan',
                  icon: Icons.settings_suggest,
                  isSelected: selectedTheme == 'Sistem',
                  onTap: () {
                    onThemeChanged('Sistem');
                  },
                ),
                const SizedBox(height: 12),
                buildThemeCard(
                  context,
                  title: 'Açık',
                  description: 'Açık tema',
                  icon: Icons.light_mode,
                  isSelected: selectedTheme == 'Açık',
                  onTap: () {
                    onThemeChanged('Açık');
                  },
                ),
                const SizedBox(height: 12),
                buildThemeCard(
                  context,
                  title: 'Koyu',
                  description: 'Koyu tema',
                  icon: Icons.dark_mode,
                  isSelected: selectedTheme == 'Koyu',
                  onTap: () {
                    onThemeChanged('Koyu');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          buildSection(
            context,
            title: 'Tema Rengi',
            subtitle: 'Uygulamanın ana rengini seçin',
            icon: Icons.color_lens,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Colors.green,
                    Colors.blue,
                    Colors.purple,
                    Colors.orange,
                    Colors.pink,
                    Colors.teal,
                    Colors.indigo,
                    Colors.amber,
                  ].map((color) {
                    final isSelected = selectedColor == color;
                    return buildColorCard(
                      context,
                      color: color,
                      isSelected: isSelected,
                      onTap: () {
                        onColorChanged(color);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                buildSelectedColorPreview(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget buildThemeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withOpacity(0.7),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).textTheme.titleMedium?.color,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildColorCard(
    BuildContext context, {
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 24,
                ),
              )
            : null,
      ),
    );
  }

  Widget buildSelectedColorPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selectedColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selectedColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: selectedColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.color_lens,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seçili Renk',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: selectedColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bu renk uygulamanın ana rengi olarak kullanılacak',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TestSettingsPage extends StatelessWidget {
  final double wordCount;
  final Function(double) onWordCountChanged;

  const TestSettingsPage({
    super.key,
    required this.wordCount,
    required this.onWordCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Ayarları'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildSection(
            context,
            title: 'Kelime Sayısı',
            subtitle: 'Test başına gösterilecek kelime sayısını ayarlayın',
            icon: Icons.format_list_numbered,
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.remove),
                    Expanded(
                      child: Slider(
                        value: wordCount,
                        min: 5,
                        max: 20,
                        divisions: 3,
                        label: wordCount.round().toString(),
                        onChanged: onWordCountChanged,
                      ),
                    ),
                    const Icon(Icons.add),
                  ],
                ),
                Center(
                  child: Text(
                    '${wordCount.round()} Kelime',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
