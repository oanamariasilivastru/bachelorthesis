import 'package:flutter/material.dart';

class PerformanceCard extends StatelessWidget {
  final double accuracy;
  final double latency;

  const PerformanceCard({
    Key? key,
    required this.accuracy,
    required this.latency,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepPurple[300],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text("Accuracy", style: TextStyle(fontSize: 16, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  "${accuracy.toStringAsFixed(1)}%",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            Column(
              children: [
                const Text("Latency", style: TextStyle(fontSize: 16, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  "${latency.toStringAsFixed(1)} sec",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
