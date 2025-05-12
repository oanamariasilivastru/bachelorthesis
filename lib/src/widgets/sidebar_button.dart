// lib/src/widgets/sidebar_button.dart

import 'package:flutter/material.dart';

class SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final Color accentColor;

  const SidebarButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if selected, use the accent; otherwise a disabled grey
    final fg = isSelected ? accentColor : Colors.grey[600]!;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // lightly tint the background when selected
        color: isSelected ? accentColor.withOpacity(0.1) : null,
        child: Row(
          children: [
            Icon(icon, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
