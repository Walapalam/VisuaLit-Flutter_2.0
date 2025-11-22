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
    // Snap to nearest index
    final int targetIndex = _scrollPercent.round().clamp(
      0,
      widget.items.length - 1,
    );

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
    final int currentIndex = _scrollPercent.round();
    final double centerOffset = MediaQuery.of(context).size.width / 2;

    // We want to render items such that the center one is last (on top).
    // So we render from edges inwards.

    // Determine visible range (e.g., +/- 2 items)
    const int visibleRange = 2;
    final int minIndex = (currentIndex - visibleRange).clamp(
      0,
      widget.items.length - 1,
    );
    final int maxIndex = (currentIndex + visibleRange).clamp(
      0,
      widget.items.length - 1,
    );

    // Create a list of indices to render, sorted by depth (furthest first)
    // Depth is determined by distance from _scrollPercent
    final List<int> indices = [];
    for (int i = minIndex; i <= maxIndex; i++) {
      indices.add(i);
    }

    // Sort: indices with larger distance from _scrollPercent should come first (be behind)
    indices.sort((a, b) {
      final double distA = (a - _scrollPercent).abs();
      final double distB = (b - _scrollPercent).abs();
      return distB.compareTo(distA); // Descending distance
    });

    for (final int index in indices) {
      final double distance = (index - _scrollPercent);
      final double absDistance = distance.abs();

      // Calculate transform properties
      // Reduced the scale reduction factor from 0.2 to 0.08 to keep books larger
      final double scale = (1.0 - (absDistance * 0.08)).clamp(0.0, 1.0);
      // Reduced the opacity reduction factor from 0.3 to 0.15 to keep books more visible
      final double opacity = (1.0 - (absDistance * 0.15)).clamp(0.0, 1.0);
      final double translateX =
          distance * (widget.centerItemWidth * 0.6); // Overlap factor

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
                  if (index == currentIndex) {
                    widget.onClicked(index);
                  } else {
                    // Scroll to this item if clicked
                    // _scrollToIndex(index);
                    // For now, just let drag handle it or implement scroll to tap
                  }
                },
                child: widget.items[index],
              ),
            ),
          ),
        ),
      );
    }

    return children;
  }
}
