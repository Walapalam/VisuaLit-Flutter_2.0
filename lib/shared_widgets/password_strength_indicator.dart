import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength(password);
    final color = _getColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength Bar
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: strength,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _getLabel(strength),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Requirements
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            _Requirement(label: '8+ chars', isMet: password.length >= 8),
            _Requirement(
              label: 'Number',
              isMet: password.contains(RegExp(r'[0-9]')),
            ),
            _Requirement(
              label: 'Symbol',
              isMet: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateStrength(String password) {
    if (password.isEmpty) return 0;
    double strength = 0;
    if (password.length >= 8) strength += 0.34;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.33;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.33;
    return strength;
  }

  Color _getColor(double strength) {
    if (strength <= 0.34) return Colors.red;
    if (strength <= 0.67) return Colors.orange;
    return AppTheme.primaryGreen;
  }

  String _getLabel(double strength) {
    if (strength <= 0.34) return 'Weak';
    if (strength <= 0.67) return 'Medium';
    return 'Strong';
  }
}

class _Requirement extends StatelessWidget {
  final String label;
  final bool isMet;

  const _Requirement({required this.label, required this.isMet});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMet ? Icons.check : Icons.circle,
          size: 12,
          color: isMet ? AppTheme.primaryGreen : Colors.white.withOpacity(0.3),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isMet ? Colors.white : Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
