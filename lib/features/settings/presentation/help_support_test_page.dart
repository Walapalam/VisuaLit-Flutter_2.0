import 'package:flutter/material.dart';
import 'package:visualit/features/settings/presentation/help_support_screen.dart';

class HelpSupportTestPage extends StatelessWidget {
  const HelpSupportTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
            );
          },
          child: const Text('Open Help & Support Screen'),
        ),
      ),
    );
  }
}
