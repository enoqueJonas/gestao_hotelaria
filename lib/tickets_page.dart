import 'package:flutter/material.dart';

class TicketsPage extends StatelessWidget {
  const TicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilhetes'),
      ),
      body: const Center(
        child: Text('Página de Bilhetes'),
      ),
    );
  }
}
