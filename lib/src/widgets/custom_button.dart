import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          // Poți adăuga o umbră mai pronunțată:
          elevation: 8,
          // Dacă vrei un efect de gradient, poți folosi un Container cu BoxDecoration
          // și apoi să suprapui butonul transparent peste el (soluție custom).
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
