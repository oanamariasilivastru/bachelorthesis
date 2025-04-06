import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TimeSpentChart extends StatefulWidget {
  final Duration timeSpent;
  const TimeSpentChart({Key? key, required this.timeSpent}) : super(key: key);

  @override
  State<TimeSpentChart> createState() => _TimeSpentChartState();
}

class _TimeSpentChartState extends State<TimeSpentChart> {
  final List<String> _intervalLabels = [
    "Azi",
    "Ultimele 7 zile",
    "Ultima lună",
    "Tot Timpul"
  ];
  int _currentIntervalIndex = 0;

  // Date statice pentru primele 3 intervale:
  final List<List<FlSpot>> _staticSpots = [
    // Exemplu: Azi
    [
      FlSpot(0, 0),
      FlSpot(1, 2),
      FlSpot(2, 3),
      FlSpot(3, 2.5),
      FlSpot(4, 3.8),
      FlSpot(5, 4),
      FlSpot(6, 6),
    ],
    // Exemplu: Ultimele 7 zile
    [
      FlSpot(0, 1),
      FlSpot(1, 2),
      FlSpot(2, 1.5),
      FlSpot(3, 3),
      FlSpot(4, 4),
      FlSpot(5, 3.5),
      FlSpot(6, 5),
    ],
    // Exemplu: Ultima lună
    [
      FlSpot(0, 2),
      FlSpot(1, 3),
      FlSpot(2, 4),
      FlSpot(3, 2),
      FlSpot(4, 3),
      FlSpot(5, 5),
      FlSpot(6, 4),
      FlSpot(7, 6),
      FlSpot(8, 7),
      FlSpot(9, 5),
    ],
  ];

  // Pentru intervalul "Tot Timpul", generăm date din durata reală
  List<FlSpot> _generateTotTimpulSpots() {
    // Pentru exemplu, presupunem că vom afișa doar o valoare,
    // dar o poți extinde pentru a crea un grafic mai detaliat.
    double hours = widget.timeSpent.inMinutes / 60.0;
    // Vom genera 2 puncte: unul care reprezintă timpul efectiv, altul restul până la un total predefinit (ex: 8 ore)
    double total = 8;
    if (hours > total) hours = total;
    return [
      FlSpot(0, hours),
      FlSpot(1, total - hours),
    ];
  }

  List<FlSpot> get currentSpots {
    if (_currentIntervalIndex < _staticSpots.length) {
      return _staticSpots[_currentIntervalIndex];
    } else {
      return _generateTotTimpulSpots();
    }
  }

  void _prevInterval() {
    setState(() {
      _currentIntervalIndex =
          (_currentIntervalIndex - 1 + _intervalLabels.length) %
              _intervalLabels.length;
    });
  }

  void _nextInterval() {
    setState(() {
      _currentIntervalIndex =
          (_currentIntervalIndex + 1) % _intervalLabels.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spots = currentSpots;
    double totalHours;
    if (_currentIntervalIndex == _intervalLabels.length - 1) {
      // Pentru "Tot Timpul", folosim timpul real
      totalHours = widget.timeSpent.inMinutes / 60.0;
    } else {
      totalHours = spots.fold(0, (prev, spot) => prev + spot.y);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Navigare între intervale
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left, size: 30),
              onPressed: _prevInterval,
            ),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  _intervalLabels[_currentIntervalIndex],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right, size: 30),
              onPressed: _nextInterval,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Afișăm totalul de ore
        Row(
          children: [
            const Icon(Icons.timer, color: Colors.orangeAccent),
            const SizedBox(width: 8),
            Text(
              "Ai petrecut ${totalHours.toStringAsFixed(1)} ore",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Graficul propriu-zis
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: spots.length.toDouble() - 1,
              minY: 0,
              maxY: 8,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey[300]!,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.deepPurple,
                  barWidth: 4,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
