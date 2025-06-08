import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisPage extends StatelessWidget {
  final List<Map<String, dynamic>> allTestResults;

  const AnalysisPage({super.key, required this.allTestResults});

  @override
  Widget build(BuildContext context) {
    if (allTestResults.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Test Analizi'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz çözülmüş test bulunmamaktadır.',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final totalTests = allTestResults.length;
    final totalCorrectAnswers =
        allTestResults.where((result) => result['isCorrect'] == true).length;
    final overallSuccessRate =
        totalTests > 0 ? (totalCorrectAnswers / totalTests) * 100 : 0.0;

    Map<String, int> incorrectWordCounts = {};
    for (var result in allTestResults) {
      if (result['isCorrect'] == false) {
        final wordId = result['wordId'];
        incorrectWordCounts[wordId] = (incorrectWordCounts[wordId] ?? 0) + 1;
      }
    }

    final sortedIncorrectWords = incorrectWordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    Map<String, int> correctWordCounts = {};
    for (var result in allTestResults) {
      if (result['isCorrect'] == true) {
        final wordId = result['wordId'];
        correctWordCounts[wordId] = (correctWordCounts[wordId] ?? 0) + 1;
      }
    }

    final topCorrectWords = correctWordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<BarChartGroupData> barGroups = [];
    if (topCorrectWords.isNotEmpty) {
      for (int i = 0; i < topCorrectWords.take(5).length; i++) {
        barGroups.add(BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: topCorrectWords[i].value.toDouble(),
              color: Theme.of(context).colorScheme.primary,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Analizi'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildAnalysisRow(
                'Toplam Çözülen Soru', totalTests.toString(), context),
            buildAnalysisRow(
                'Toplam Doğru Cevap', totalCorrectAnswers.toString(), context),
            buildAnalysisRow('Genel Başarı Oranı',
                '${overallSuccessRate.toStringAsFixed(1)}%', context),
            const SizedBox(height: 20),
            if (sortedIncorrectWords.isNotEmpty) ...[
              Text(
                'En Çok Yanlış Cevaplanan Kelimeler',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              ...sortedIncorrectWords
                  .take(5)
                  .map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${entry.key}: ${entry.value} kez yanlış',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ))
                  .toList(),
              const SizedBox(height: 20),
            ],
            if (topCorrectWords.isNotEmpty) ...[
              Text(
                'En Çok Doğru Cevaplanan Kelimeler',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: topCorrectWords.isNotEmpty
                        ? topCorrectWords.first.value.toDouble() * 1.2
                        : 10,
                    minY: 0,
                    barGroups: barGroups,
                    borderData: FlBorderData(
                      show: false,
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 &&
                                index < topCorrectWords.take(5).length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: RotatedBox(
                                  quarterTurns: -1,
                                  child: Text(
                                    topCorrectWords.take(5).toList()[index].key,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 60,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${topCorrectWords.take(5).toList()[group.x.toInt()].key}\n'
                            '${rod.toY.toInt()} kez doğru',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildAnalysisRow(String label, String value, BuildContext context) {
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
}
