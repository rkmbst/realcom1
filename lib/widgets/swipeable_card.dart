import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';

class SwipeableCard extends StatefulWidget {
  const SwipeableCard({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.threshold = 120,
  });

  final Widget child;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final double threshold;

  @override
  State<SwipeableCard> createState() =>
      _SwipeableCardState();
}

class _SwipeableCardState
    extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  double _dragY = 0;

  bool _horizontalGesture = false;
  bool _gestureLocked = false;
  bool _isAnimating = false;

  late final AnimationController _controller;

  Animation<double>? _animation;
  VoidCallback? _pendingCallback;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
    )..addListener(() {
        final animation = _animation;

        if (animation == null || !mounted) {
          return;
        }

        setState(() {
          _dragX = animation.value;
        });
      });
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimating) {
      return;
    }

    _gestureLocked = false;
    _horizontalGesture = false;

    _dragY = 0;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating || _gestureLocked) {
      return;
    }

    _dragY += details.delta.dy;
    _dragX += details.delta.dx;

    final absX = _dragX.abs();
    final absY = _dragY.abs();

    if (absX < 6 && absY < 6) {
      return;
    }

    if (absX > absY * 1.15) {
      _horizontalGesture = true;
      _gestureLocked = true;
    } else if (absY > absX * 1.15) {
      // Vertical gesture belongs to the parent
      // PageView. Do not move this card.
      _dragX = 0;
      _dragY = 0;
      _horizontalGesture = false;
      _gestureLocked = true;
      return;
    }

    if (!_horizontalGesture) {
      return;
    }

    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating ||
        !_horizontalGesture) {
      _resetGestureState();
      return;
    }

    final velocity =
        details.velocity.pixelsPerSecond.dx;

    if (_dragX > widget.threshold ||
        velocity > 800) {
      _animateOut(
        direction: 1,
        callback: widget.onSwipeRight,
      );
      return;
    }

    if (_dragX < -widget.threshold ||
        velocity < -800) {
      _animateOut(
        direction: -1,
        callback: widget.onSwipeLeft,
      );
      return;
    }

    _animateBack();
  }

  void _animateOut({
    required int direction,
    required VoidCallback callback,
  }) {
    _isAnimating = true;
    _pendingCallback = callback;

    final width =
        MediaQuery.of(context).size.width;

    final target =
        direction * width * 1.15;

    _animation = Tween<double>(
      begin: _dragX,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.standardCurve,
      ),
    );

    _controller
      ..duration = AppMotion.standard
      ..forward(from: 0);

    _controller.addStatusListener(
      _handleAnimationStatus,
    );
  }

  void _animateBack() {
    _isAnimating = true;
    _pendingCallback = null;

    _animation = Tween<double>(
      begin: _dragX,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.standardCurve,
      ),
    );

    _controller
      ..duration = AppMotion.standard
      ..forward(from: 0);

    _controller.addStatusListener(
      _handleAnimationStatus,
    );
  }

  void _handleAnimationStatus(
    AnimationStatus status,
  ) {
    if (status != AnimationStatus.completed) {
      return;
    }

    _controller.removeStatusListener(
      _handleAnimationStatus,
    );

    final callback = _pendingCallback;

    _pendingCallback = null;

    if (!mounted) {
      return;
    }

    setState(() {
      _dragX = 0;
      _dragY = 0;
      _horizontalGesture = false;
      _gestureLocked = false;
      _isAnimating = false;
    });

    callback?.call();
  }

  void _resetGestureState() {
    _dragX = 0;
    _dragY = 0;
    _horizontalGesture = false;
    _gestureLocked = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width;

    final rotation =
        (_dragX / width) * 0.15;

    final rightOpacity =
        (_dragX / 120).clamp(0.0, 1.0);

    final leftOpacity =
        (-_dragX / 120).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: Offset(_dragX, 0),
        child: Transform.rotate(
          angle: rotation,
          child: Stack(
            children: [
              widget.child,

              Positioned(
                top: 20,
                left: 20,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: rightOpacity,
                    child: _Stamp(
                      label: 'مهتم',
                      color: AppColors.success,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 20,
                right: 20,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: leftOpacity,
                    child: _Stamp(
                      label: 'غير مهتم',
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stamp extends StatelessWidget {
  const _Stamp({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius:
            BorderRadius.circular(
          AppRadius.pill,
        ),
        border: Border.all(
          color: color.withOpacity(0.75),
        ),
      ),
      child: Text(
        label,
        style:
            AppTextStyles.button.copyWith(
          color: color,
        ),
      ),
    );
  }
}
