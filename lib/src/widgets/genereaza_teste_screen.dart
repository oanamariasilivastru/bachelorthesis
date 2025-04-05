import 'package:flutter/material.dart';

class GenereazaTesteScreen extends StatelessWidget {
  const GenereazaTesteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generează test"),
      ),
      body: const Center(
        child: Text("Aici poți implementa logica de generare a testelor."),
      ),
    );
  }
}
