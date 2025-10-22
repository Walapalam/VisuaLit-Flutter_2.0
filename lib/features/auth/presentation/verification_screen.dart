import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isVerified = false;
  bool _isLoading = false;

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isVerified = user?.emailVerified ?? false;
      _isLoading = false;
    });
    if (_isVerified) {
      // Navigate to home or login
      context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('A verification email has been sent. Please check your inbox.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkVerification,
              child: _isLoading ? const CircularProgressIndicator() : const Text('I have verified'),
            ),
          ],
        ),
      ),
    );
  }
}