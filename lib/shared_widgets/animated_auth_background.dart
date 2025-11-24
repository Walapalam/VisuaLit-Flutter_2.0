import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:visualit/core/theme/app_theme.dart';

class AnimatedAuthBackground extends StatefulWidget {
  final Widget child;

  const AnimatedAuthBackground({super.key, required this.child});

  @override
  State<AnimatedAuthBackground> createState() => _AnimatedAuthBackgroundState();
}

class _AnimatedAuthBackgroundState extends State<AnimatedAuthBackground>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Initialize particles
    for (int i = 0; i < 15; i++) {
      _particles.add(Particle());
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // 1. Deep dark background or Creative Green Gradient for Light Mode
        Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE8F5E9), // Very light green
                      Color(0xFFF1F8E9), // Light green-yellow tint
                      Color(0xFFFFFFFF), // White center
                      Color(0xFFE0F2F1), // Light teal tint
                    ],
                    stops: [0.0, 0.3, 0.6, 1.0],
                  ),
            color: isDark ? AppTheme.black : null,
          ),
        ),

        // 2. Top-left subtle green glow (Matches HomeBackground)
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryGreen.withOpacity(0.15),
            ),
          ),
        ),

        // 3. Bottom-right subtle glow (Matches HomeBackground)
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryGreen.withOpacity(0.1),
            ),
          ),
        ),

        // 4. Floating particles (Kept but updated to use AppTheme.primaryGreen)
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                animation: _particleController.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        // 5. Blur filter (Matches HomeBackground)
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        ),

        // 6. Mesh gradient overlay (Matches HomeBackground)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.02),
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ]
                  : [
                      AppTheme.primaryGreen.withOpacity(0.05),
                      Colors.transparent,
                      Colors.white.withOpacity(0.2),
                    ],
            ),
          ),
        ),

        // Content
        widget.child,
      ],
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late double speed;
  late double opacity;

  Particle() {
    final random = math.Random();
    x = random.nextDouble();
    y = random.nextDouble();
    size = random.nextDouble() * 3 + 1;
    speed = random.nextDouble() * 0.5 + 0.2;
    opacity = random.nextDouble() * 0.3 + 0.1;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      final x = particle.x * size.width;
      final y = ((particle.y + animation * particle.speed) % 1.0) * size.height;

      // Updated to use AppTheme.primaryGreen
      paint.color = AppTheme.primaryGreen.withOpacity(particle.opacity);
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
