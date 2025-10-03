import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    // More specific listener to prevent errors being missed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(authControllerProvider, (previous, current) {
        // Only show error if we have an error message and we're not in loading state
        if (current.errorMessage != null &&
            current.status == AuthStatus.unauthenticated &&
            mounted) {
          // Add a slight delay to ensure UI is ready
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(current.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(8),
                ),
              );
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    debugPrint('Auth status: ${authState.status}');

    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('onboarding'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log in to continue your journey.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppTheme.grey),
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (authState.status == AuthStatus.invalidLogin && authState.errorMessage != null)
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5,right: 0.0),
                            child: Text(
                              "Email or password is incorrect.",
                              style: const TextStyle(color: Colors.red, fontSize: 10),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      const Spacer(),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Forgot password feature coming soon!')),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: AppTheme.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                  // ... rest of your code ...
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: AppTheme.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isLoading ? null : _handleLogin,
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.black),
                    )
                        : const Text(
                      'Login',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text("OR", style: TextStyle(color: AppTheme.grey)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isLoading
                        ? null
                        : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: isLoading ? null : () => context.goNamed('signup'),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}