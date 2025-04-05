import 'package:flutter/material.dart';

class ResponseCard extends StatelessWidget {
  final String responseText;
  const ResponseCard({Key? key, required this.responseText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (responseText.isEmpty) return const SizedBox.shrink();
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.insert_drive_file_outlined, color: Colors.deepOrange, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                responseText,
                style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
