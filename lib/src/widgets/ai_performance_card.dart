import 'package:flutter/material.dart';

class AiPerformanceCard extends StatelessWidget {
  final double accuracy;
  final double latency;
  final Color backgroundColor;
  final VoidCallback? onTap; // callback opțional

  const AiPerformanceCard({
    Key? key,
    required this.accuracy,
    required this.latency,
    required this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                backgroundColor,
                backgroundColor.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.5),
                offset: const Offset(0, 8),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.insights, color: Colors.white, size: 36),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Latency: ${latency.toStringAsFixed(1)}s',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
