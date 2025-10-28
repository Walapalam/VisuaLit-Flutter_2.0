// dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final TextEditingController _passwordController = TextEditingController();

  File? _pickedImage;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<String?> _uploadProfileImage(String uid) async {
    if (_pickedImage == null) return null;
    final refStorage = _storage.ref().child('profile_pictures/$uid.jpg');
    final uploadTask = await refStorage.putFile(_pickedImage!);
    return await refStorage.getDownloadURL();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final user = _auth.currentUser;
      if (user == null) throw FirebaseAuthException(code: 'no-user', message: 'No authenticated user.');

      // Upload image if selected
      if (_pickedImage != null) {
        final url = await _uploadProfileImage(user.uid);
        if (url != null) {
          await user.updatePhotoURL(url);
        }
      }

      // Update display name
      if (_nameController.text.trim() != (user.displayName ?? '').trim()) {
        await user.updateDisplayName(_nameController.text.trim());
      }

      // Update password (requires recent auth)
      if (_passwordController.text.isNotEmpty) {
        try {
          await user.updatePassword(_passwordController.text);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please re-authenticate to update your password.')),
            );
          } else {
            rethrow;
          }
        }
      }

      // Force reload to refresh local user data
      await user.reload();
      // Update global auth state by re-initializing controller
      await ref.read(authControllerProvider.notifier).initialize();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      final msg = (e is FirebaseAuthException) ? (e.message ?? 'Failed to save changes') : 'Failed to save changes';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This action is irreversible. Enter your password to confirm.'),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);
    try {
      final email = user.email;
      final password = passwordController.text;
      if (email == null) throw Exception('Email not available for re-authentication.');

      final cred = EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(cred);
      await user.delete();

      // Re-initialize the auth controller and navigate to onboarding
      await ref.read(authControllerProvider.notifier).initialize();
      if (mounted) context.go('/onboarding');
    } on FirebaseAuthException catch (e) {
      final message = e.message ?? 'Failed to delete account';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete account')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user ?? _auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Account Settings'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryGreen.withOpacity(0.9),
                isDark ? AppTheme.darkGrey : AppTheme.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header / Avatar
            Center(
              child: Column(children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppTheme.primaryGreen, Colors.green.shade700]),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: isDark ? AppTheme.darkGrey : AppTheme.white,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (user?.photoURL != null ? NetworkImage(user!.photoURL!) : null) as ImageProvider<Object>?,
                    child: (_pickedImage == null && user?.photoURL == null) ? const Icon(Icons.person, size: 52, color: Colors.white) : null,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) => Wrap(children: [
                        ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () { Navigator.of(ctx).pop(); _pickImage(ImageSource.gallery); }),
                        ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () { Navigator.of(ctx).pop(); _pickImage(ImageSource.camera); }),
                      ]),
                    );
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Change Picture'),
                ),
              ]),
            ),

            const SizedBox(height: 24),

            // Personal info
            Text('Personal Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.person_outline), labelText: 'Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: user?.email ?? '',
              enabled: false,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.email_outlined), labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),

            const SizedBox(height: 24),
            // Security
            Text('Security', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline), labelText: 'New Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              validator: (v) {
                if (v != null && v.isNotEmpty && v.length < 8) return 'Password must be at least 8 characters';
                return null;
              },
            ),

            const SizedBox(height: 28),
            if (_isSaving) const Center(child: CircularProgressIndicator()) else Row(children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
              ),
            ]),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // Danger zone
            Text('Danger Zone', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Account'),
              subtitle: const Text('This action is irreversible'),
              onTap: _isSaving ? null : _confirmDeleteAccount,
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
