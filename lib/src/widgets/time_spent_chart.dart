import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TimeSpentChart extends StatefulWidget {
  const TimeSpentChart({Key? key}) : super(key: key);

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

  final List<List<FlSpot>> _allSpots = [
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
    // Exemplu: Tot Timpul
    [
      FlSpot(0, 2),
      FlSpot(1, 2),
      FlSpot(2, 3),
      FlSpot(3, 3),
      FlSpot(4, 5),
      FlSpot(5, 4),
      FlSpot(6, 5),
      FlSpot(7, 5),
      FlSpot(8, 6),
      FlSpot(9, 6),
      FlSpot(10, 7),
      FlSpot(11, 7.5),
    ],
  ];

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
    final spots = _allSpots[_currentIntervalIndex];
    double totalHours = 0;
    for (var s in spots) {
      totalHours += s.y;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Navigare între intervale (stânga - etichetă - dreapta)
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
