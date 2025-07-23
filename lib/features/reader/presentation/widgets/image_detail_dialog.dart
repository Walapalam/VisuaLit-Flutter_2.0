import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:visualit/features/reader/presentation/widgets/liquid_glass_container.dart';

class ImageDetailDialog extends StatelessWidget {
  final String tag;
  final String imageUrl;
  final String title;
  final String description; // This will be the prompt
  final String detail1Label;
  final String detail1;
  final String detail2Label;
  final String detail2;

  const ImageDetailDialog({
    super.key,
    required this.tag,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.detail1Label,
    required this.detail1,
    required this.detail2Label,
    required this.detail2,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.transparent, // Important for full-screen glass effect
      child: LiquidGlassContainer(
        borderRadius: BorderRadius.zero, // Full screen, no rounded corners
        padding: EdgeInsets.zero,
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              flex: 3, // Top 3/4 for image
              child: Stack(
                children: [
                  Hero(
                    tag: tag,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain, // Use contain to see full image
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.error, color: Colors.white)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 100, // Height of the gradient overlay
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Theme.of(context).colorScheme.surface.withOpacity(0.5),
                            Theme.of(context).colorScheme.surface.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1, // Bottom 1/4 for details
              child: LiquidGlassContainer(
                borderRadius: BorderRadius.zero, // No rounded corners for this inner container
                backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.2), // Slightly more opaque for details
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(detail1Label, detail1),
                      const SizedBox(height: 8),
                      _buildDetailRow(detail2Label, detail2),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
      ],
    );
  }
}