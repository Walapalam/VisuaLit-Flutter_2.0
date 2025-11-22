import 'package:flutter/material.dart';

/// A wrapper widget that provides focus state to carousel items
class CustomOverlappedCarouselItem extends StatelessWidget {
  final int index;
  final Widget Function(BuildContext context, bool isFocused) builder;

  const CustomOverlappedCarouselItem({
    super.key,
    required this.index,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // Get the current scroll position from the carousel
    final carouselState = context
        .findAncestorStateOfType<_CustomOverlappedCarouselState>();
    final isFocused =
        carouselState != null &&
        (carouselState._scrollPercent.round() == index);

    return builder(context, isFocused);
  }
}

class CustomOverlappedCarousel extends StatefulWidget {
  final List<Widget> items;
  final double centerItemWidth;
  final double height;
  final int initialIndex;
  final Function(int) onClicked;

  const CustomOverlappedCarousel({
    super.key,
    required this.items,
    required this.centerItemWidth,
    required this.height,
    this.initialIndex = 0,
    required this.onClicked,
  });

  @override
  State<CustomOverlappedCarousel> createState() =>
      _CustomOverlappedCarouselState();
}

class _CustomOverlappedCarouselState extends State<CustomOverlappedCarousel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _scrollPercent = 0.0;
  double _startDragPercent = 0.0;
  double _startDragX = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollPercent = widget.initialIndex
        .toDouble(); // Set initial scroll position
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _startDragX = details.globalPosition.dx;
    _startDragPercent = _scrollPercent;
    _controller.stop();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final double dragDistance = details.globalPosition.dx - _startDragX;
    final double dragPercent = dragDistance / widget.centerItemWidth;
    setState(() {
      _scrollPercent = _startDragPercent - dragPercent;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    // Snap to nearest index (no clamping for infinite scroll)
    final int targetIndex = _scrollPercent.round();

    _controller.duration = const Duration(milliseconds: 300);
    final double targetPercent = targetIndex.toDouble();

    _controller.addListener(() {
      setState(() {
        _scrollPercent = _controller.value;
      });
    });

    // Animate from current percent to target percent
    final double start = _scrollPercent;
    final double end = targetPercent;

    Animation<double> animation = Tween<double>(
      begin: start,
      end: end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    animation.addListener(() {
      setState(() {
        _scrollPercent = animation.value;
      });
    });

    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: GestureDetector(
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          alignment: Alignment.center,
          children: _buildStackChildren(),
        ),
      ),
    );
  }

  List<Widget> _buildStackChildren() {
    final List<Widget> children = [];
    // Use modulo for infinite scroll effect logic
    // We assume the list is circular.
    // _scrollPercent can now go beyond 0..length-1

    final double centerOffset = MediaQuery.of(context).size.width / 2;
    final int totalItems = widget.items.length;
    if (totalItems == 0) return [];

    // Normalize scroll percent to positive range for easier calculation if needed,
    // but we can handle negative indices with modulo.

    // Determine visible range (e.g., +/- 2 items)
    const int visibleRange = 2;
    final int currentIndex = _scrollPercent.round();

    // Create a list of indices to render relative to current index
    final List<int> relativeIndices = [];
    for (int i = -visibleRange; i <= visibleRange; i++) {
      relativeIndices.add(currentIndex + i);
    }

    // Sort: indices with larger distance from _scrollPercent should come first (be behind)
    relativeIndices.sort((a, b) {
      final double distA = (a - _scrollPercent).abs();
      final double distB = (b - _scrollPercent).abs();
      return distB.compareTo(distA); // Descending distance
    });

    for (final int relativeIndex in relativeIndices) {
      final double distance = (relativeIndex - _scrollPercent);
      final double absDistance = distance.abs();

      // Calculate transform properties
      // Reduced the scale reduction factor from 0.2 to 0.08 to keep books larger
      final double scale = (1.0 - (absDistance * 0.1)).clamp(0.0, 1.0);

      // User requested NO transparency/translucency for following layers
      // So we keep opacity at 1.0 unless it's very far and we want to hide it completely
      final double opacity = 1.0;

      final double translateX =
          distance * (widget.centerItemWidth * 0.6); // Overlap factor

      // Wrap index for infinite scroll
      int actualIndex = relativeIndex % totalItems;
      if (actualIndex < 0) actualIndex += totalItems;

      children.add(
        Positioned(
          // Center the item horizontally, then apply translation
          left: centerOffset - (widget.centerItemWidth / 2) + translateX,
          top:
              (widget.height - (widget.height * scale)) /
              2, // Center vertically
          width: widget.centerItemWidth,
          height: widget.height * scale, // Scale height
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale, // Also scale content
              child: GestureDetector(
                onTap: () {
                  if (relativeIndex == currentIndex) {
                    widget.onClicked(actualIndex);
                  } else {
                    // Optional: Scroll to clicked
                  }
                },
                child: widget.items[actualIndex],
              ),
            ),
          ),
        ),
      );
    }

    return children;
  }
}
