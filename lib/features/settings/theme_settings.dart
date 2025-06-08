import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettings extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;

  const ThemeSettings({
    super.key,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema Ayarları'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tema Modu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              buildThemeModeSelector(context),
              const SizedBox(height: 40),
              Text(
                'Tema Rengi',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              buildColorSelector(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildThemeModeSelector(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildThemeOption(
              context,
              'Sistem',
              Icons.brightness_auto,
              ThemeMode.system,
              'Sistem temasını kullan',
            ),
            const Divider(height: 1),
            buildThemeOption(
              context,
              'Açık',
              Icons.light_mode,
              ThemeMode.light,
              'Açık tema',
            ),
            const Divider(height: 1),
            buildThemeOption(
              context,
              'Koyu',
              Icons.dark_mode,
              ThemeMode.dark,
              'Koyu tema',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    ThemeMode mode,
    String description,
  ) {
    return FutureBuilder<String>(
      future: SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('theme') ?? 'Sistem'),
      builder: (context, snapshot) {
        final isSelected = snapshot.data == title;
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).dividerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).iconTheme.color,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          subtitle: Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          trailing: isSelected
              ? Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : null,
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('theme', title);
            onThemeChanged(mode);
          },
        );
      },
    );
  }

  Widget buildColorSelector(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                return FutureBuilder<Color>(
                  future: SharedPreferences.getInstance().then((prefs) {
                    final colorValue =
                        prefs.getInt('themeColor') ?? Colors.orange.value;
                    return Color(colorValue);
                  }),
                  builder: (context, snapshot) {
                    final isSelected =
                        snapshot.data?.value == colors[index].value;
                    return GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt('themeColor', colors[index].value);
                        final currentTheme =
                            prefs.getString('theme') ?? 'Sistem';
                        ThemeMode currentMode;
                        switch (currentTheme) {
                          case 'Açık':
                            currentMode = ThemeMode.light;
                            break;
                          case 'Koyu':
                            currentMode = ThemeMode.dark;
                            break;
                          default:
                            currentMode = ThemeMode.system;
                        }
                        onThemeChanged(currentMode);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: colors[index].withOpacity(0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
