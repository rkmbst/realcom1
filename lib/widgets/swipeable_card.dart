import 'dart:math';

import 'package:flutter/material.dart';

class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final double threshold;

  const SwipeableCard({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.threshold = 110,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;

  late final AnimationController _controller;
  Animation<Offset>? _animation;
  VoidCallback? _pending;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        final animation = _animation;

        if (animation != null && mounted) {
          setState(() {
            _offset = animation.value;
          });
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            _isAnimating = false;
          });

          final callback = _pending;
          _pending = null;

          if (callback != null) {
            callback();
          }
        }
      });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;

    setState(() {
      _offset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating) return;

    final width = MediaQuery.of(context).size.width;
    final velocity = details.velocity.pixelsPerSecond.dx;

    if (_offset.dx > widget.threshold || velocity > 800) {
      _animateTo(
        Offset(width * 1.2, _offset.dy),
        widget.onSwipeRight,
      );
    } else if (_offset.dx < -widget.threshold || velocity < -800) {
      _animateTo(
        Offset(-width * 1.2, _offset.dy),
        widget.onSwipeLeft,
      );
    } else {
      _animateTo(Offset.zero, null);
    }
  }

  void _animateTo(Offset target, VoidCallback? callback) {
    _isAnimating = true;
    _pending = callback;

    _animation = Tween<Offset>(
      begin: _offset,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.value = 0;
    _controller.animateTo(
      1,
      duration: Duration(milliseconds: callback == null ? 220 : 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rotation = _offset.dx / 900;

    final rightOpacity = (_offset.dx / 100).clamp(0.0, 1.0);
    final leftOpacity = (-_offset.dx / 100).clamp(0.0, 1.0);

    return Transform.translate(
      offset: _offset,
      child: Transform.rotate(
        angle: rotation,
        child: Stack(
          children: [
            widget.child,
            Positioned(
              top: 18,
              left: 18,
              child: Opacity(
                opacity: rightOpacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'موافق',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 18,
              right: 18,
              child: Opacity(
                opacity: leftOpacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Text(
                    'تخطي',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
