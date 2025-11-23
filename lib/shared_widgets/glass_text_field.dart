import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'dart:ui';

class GlassTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool showValidationIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;

  const GlassTextField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
    this.showValidationIcon = false,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _borderAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasError = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _borderAnimation = Tween<double>(
      begin: 0.1,
      end: 0.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (_isFocused) {
          _controller.forward();
        } else {
          _controller.reverse();
          _validateField();
        }
      });
    });
  }

  void _validateField() {
    if (widget.validator != null && widget.controller != null) {
      final error = widget.validator!(widget.controller!.text);
      setState(() {
        _hasError = error != null;
        _isValid = error == null && widget.controller!.text.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _borderAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _hasError
                      ? Colors.red.withOpacity(0.5)
                      : _isFocused
                      ? AppTheme.primaryGreen.withOpacity(
                          _borderAnimation.value,
                        )
                      : Colors.white.withOpacity(0.1),
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      onTap: widget.onTap,
                      readOnly: widget.readOnly,
                      maxLines: widget.maxLines,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: widget.hint ?? widget.label,
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 16,
                        ),
                        prefixIcon: widget.icon != null
                            ? Icon(
                                widget.icon,
                                color: _isFocused
                                    ? AppTheme.primaryGreen
                                    : Colors.white.withOpacity(0.6),
                              )
                            : null,
                        suffixIcon:
                            widget.suffixIcon ??
                            (widget.showValidationIcon
                                ? _buildValidationIcon()
                                : null),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      onChanged: (value) {
                        if (widget.showValidationIcon) {
                          _validateField();
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (_hasError && widget.validator != null && widget.controller != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              widget.validator!(widget.controller!.text) ?? '',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget? _buildValidationIcon() {
    if (_isValid) {
      return const Icon(Icons.check_circle, color: Color(0xFF00D9A3));
    } else if (_hasError) {
      return const Icon(Icons.error, color: Colors.red);
    }
    return null;
  }
}
