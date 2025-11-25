
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
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
  String _originalName = '';

  File? _pickedImage;
  bool _isSaving = false;
  bool _isEditing = false;

  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _originalName = user?.displayName ?? '';
    _nameController = TextEditingController(text: _originalName);
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
      setState(() {
        _pickedImage = File(picked.path);
        _isEditing = true; // Enter edit mode when image is picked
      });
    }
  }

  Future<String?> _uploadProfileImage(String uid) async {
    if (_pickedImage == null) return null;
    final refStorage = _storage.ref().child('profile_pictures/$uid.jpg');
    await refStorage.putFile(_pickedImage!);
    return await refStorage.getDownloadURL();
  }

  void _cancelChanges() {
    setState(() {
      _pickedImage = null;
      _nameController.text = _originalName;
      _passwordController.clear();
      _isEditing = false;
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final user = _auth.currentUser;
      if (user == null) throw FirebaseAuthException(code: 'no-user');

      // Upload image if selected
      if (_pickedImage != null) {
        final url = await _uploadProfileImage(user.uid);
        if (url != null) await user.updatePhotoURL(url);
      }

      // Update display name
      if (_nameController.text.trim() != _originalName) {
        await user.updateDisplayName(_nameController.text.trim());
        _originalName = _nameController.text.trim();
      }

      // Update password
      if (_passwordController.text.isNotEmpty) {
        await user.updatePassword(_passwordController.text);
      }

      await user.reload();
      await ref.read(authControllerProvider.notifier).initialize();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
        setState(() {
          _isEditing = false;
          _passwordController.clear();
        });
      }
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'requires-recent-login'
          ? 'Please re-authenticate to update your password.'
          : (e.message ?? 'Failed to save changes.');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An unexpected error occurred.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final user = _auth.currentUser;
    if (user?.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No email associated with this account.')));
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset link sent to ${user.email}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send reset link.')));
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This action is permanent and cannot be undone. Are you sure you want to delete your account?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    setState(() => _isSaving = true);
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      await user.delete();
      await ref.read(authControllerProvider.notifier).initialize();
      if (mounted) context.go('/onboarding');
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'requires-recent-login'
          ? 'Please sign out and sign back in to delete your account.'
          : (e.message ?? 'Failed to delete account.');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An unexpected error occurred.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user ?? _auth.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text('Edit'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvatarSection(user),
              const SizedBox(height: 24),
              _buildInfoCard(
                children: [
                  _buildSectionHeader('User Information', theme),
                  _buildEditableTextField(
                    controller: _nameController,
                    label: 'Name',
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name cannot be empty' : null,
                  ),
                  const Divider(height: 1),
                  _buildReadOnlyField(
                    label: 'Email',
                    value: user?.email ?? 'Not available',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Security', theme),
                  if (_isEditing)
                    _buildEditableTextField(
                      controller: _passwordController,
                      label: 'New Password (optional)',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (v) => (v != null && v.isNotEmpty && v.length < 6) ? 'Password must be at least 6 characters' : null,
                    )
                  else
                    _buildReadOnlyField(
                      label: 'Password',
                      value: '********',
                      icon: Icons.lock_outline,
                    ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.password),
                    title: const Text('Reset Password'),
                    subtitle: const Text('Send a password reset link to your email'),
                    onTap: _sendPasswordReset,
                    dense: true,
                  ),
                  if (_isEditing) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: _buildActionButtons(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  _buildDangerZone(theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(User? user) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              backgroundImage: _pickedImage != null
                  ? FileImage(_pickedImage!)
                  : (user?.photoURL != null ? NetworkImage(user!.photoURL!) : null) as ImageProvider?,
              child: (_pickedImage == null && user?.photoURL == null)
                  ? Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.onSurfaceVariant)
                  : null,
            ),
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (ctx) => Wrap(children: [
                    ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () { Navigator.of(ctx).pop(); _pickImage(ImageSource.gallery); }),
                    ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () { Navigator.of(ctx).pop(); _pickImage(ImageSource.camera); }),
                  ]),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.edit, size: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value, required IconData icon}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      dense: true,
    );
  }

  Widget _buildEditableTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildActionButtons() {
    return _isSaving
        ? const Center(child: CircularProgressIndicator())
        : Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelChanges,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          );
  }

  Widget _buildDangerZone(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Danger Zone', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.error)),
        const SizedBox(height: 10),
        Card(
          elevation: 0,
          color: theme.colorScheme.errorContainer.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.error),
          ),
          child: ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text('Delete Account', style: TextStyle(color: theme.colorScheme.onErrorContainer)),
            subtitle: Text('This action is permanent', style: TextStyle(color: theme.colorScheme.onErrorContainer.withOpacity(0.7))),
            onTap: _isSaving ? null : _confirmDeleteAccount,
          ),
        ),
      ],
    );
  }
}
