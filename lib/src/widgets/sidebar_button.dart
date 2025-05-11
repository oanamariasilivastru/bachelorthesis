import 'package:flutter/material.dart';

class SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const SidebarButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false, required MaterialAccentColor accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.deepPurple : Colors.grey[600];
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? Colors.deepPurple.withOpacity(0.1) : null,
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
