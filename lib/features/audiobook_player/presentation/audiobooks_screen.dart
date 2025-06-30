import 'package:flutter/material.dart';

class AudiobooksScreen extends StatelessWidget {
  const AudiobooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Audiobooks')),
      body: const Center(child: Text('Audiobooks Content Goes Here')),
    );
  }
}
