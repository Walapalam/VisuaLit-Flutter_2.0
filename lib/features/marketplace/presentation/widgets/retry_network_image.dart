import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visualit/core/theme/app_theme.dart';

class RetryNetworkImage extends StatefulWidget {
  final String url;
  final int maxRetries;
  final BoxFit fit;
  final double? height;
  final double? width;

  const RetryNetworkImage({
    required this.url,
    this.maxRetries = 2,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    super.key,
  });

  @override
  State<RetryNetworkImage> createState() => _RetryNetworkImageState();
}

class _RetryNetworkImageState extends State<RetryNetworkImage> {
  int _retryCount = 0;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.url,
      fit: widget.fit,
      height: widget.height,
      width: widget.width,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Shimmer.fromColors(
          baseColor: AppTheme.darkGrey,
          highlightColor: AppTheme.black,
          child: Container(
            height: widget.height,
            width: widget.width,
            color: AppTheme.darkGrey,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (_retryCount < widget.maxRetries) {
          _retryCount++;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() {});
          });
          return Shimmer.fromColors(
            baseColor: AppTheme.darkGrey,
            highlightColor: AppTheme.black,
            child: Container(
              height: widget.height,
              width: widget.width,
              color: AppTheme.darkGrey,
            ),
          );
        }
        return Container(
          color: Theme.of(context).colorScheme.surface,
          height: widget.height,
          width: widget.width,
          child: const Center(child: Icon(Icons.broken_image, size: 40)),
        );
      },
    );
  }
}
