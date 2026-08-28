import 'package:flutter/material.dart';

import '../core/theme/app_motion.dart';
import '../core/theme/app_physics.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class SwipeableCard extends StatefulWidget {
  const SwipeableCard({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.threshold = 120,
    this.onDragProgress,
  });

  final Widget child;

  final VoidCallback onSwipeLeft;

  final VoidCallback onSwipeRight;

  final double threshold;

  /// Returns a normalized drag progress:
  ///
  /// 0.0 = centered
  /// 1.0 = threshold reached
  ///
  /// The value is always positive and describes
  /// how far the card has been dragged.
  final ValueChanged<double>? onDragProgress;

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
    );

    _controller.addListener(() {
      final animation = _animation;

      if (animation == null || !mounted) {
        return;
      }

      setState(() {
        _dragX = animation.value;
      });

      _notifyProgress();
    });
  }

  void _notifyProgress() {
    final progress =
        (_dragX.abs() / widget.threshold)
            .clamp(0.0, 1.0);

    widget.onDragProgress?.call(
      progress,
    );
  }

  void _onPanStart(
    DragStartDetails details,
  ) {
    if (_isAnimating) {
      return;
    }

    _dragY = 0;

    _horizontalGesture = false;

    _gestureLocked = false;

    _notifyProgress();
  }

  void _onPanUpdate(
    DragUpdateDetails details,
  ) {
    if (_isAnimating ||
        _gestureLocked) {
      return;
    }

    _dragX += details.delta.dx;

    _dragY += details.delta.dy;

    final absX = _dragX.abs();

    final absY = _dragY.abs();

    if (absX < 8 && absY < 8) {
      return;
    }

    if (absX > absY * 1.12) {
      _horizontalGesture = true;
      _gestureLocked = true;
    } else if (absY > absX * 1.12) {
      _horizontalGesture = false;
      _gestureLocked = true;

      _dragX = 0;
      _dragY = 0;

      _notifyProgress();

      return;
    }

    if (!_horizontalGesture) {
      return;
    }

    final width =
        MediaQuery.of(context).size.width;

    final limitedX =
        _dragX.clamp(
      -width * 0.95,
      width * 0.95,
    );

    setState(() {
      _dragX = limitedX;
    });

    _notifyProgress();
  }

  void _onPanEnd(
    DragEndDetails details,
  ) {
    if (_isAnimating ||
        !_horizontalGesture) {
      _resetGestureState();
      _notifyProgress();
      return;
    }

    final velocity =
        details.velocity.pixelsPerSecond.dx;

    final passedRight =
        _dragX >= widget.threshold ||
            velocity >= 850;

    final passedLeft =
        _dragX <= -widget.threshold ||
            velocity <= -850;

    if (passedRight) {
      _animateOut(
        direction: 1,
        callback:
            widget.onSwipeRight,
      );

      return;
    }

    if (passedLeft) {
      _animateOut(
        direction: -1,
        callback:
            widget.onSwipeLeft,
      );

      return;
    }

    _animateBack();
  }

  void _animateOut({
    required int direction,
    required VoidCallback callback,
  }) {
    if (_isAnimating) {
      return;
    }

    _isAnimating = true;

    _pendingCallback = callback;

    final width =
        MediaQuery.of(context).size.width;

    final target =
        direction * width * 1.12;

    _animation = Tween<double>(
      begin: _dragX,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve:
            AppMotion.standardCurve,
      ),
    );

    _controller
      ..duration =
          AppMotion.emphasized
      ..forward(from: 0);

    _controller.addStatusListener(
      _handleAnimationStatus,
    );
  }

  void _animateBack() {
    if (_isAnimating) {
      return;
    }

    _isAnimating = true;

    _pendingCallback = null;

    _animation = Tween<double>(
      begin: _dragX,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve:
            AppMotion.standardCurve,
      ),
    );

    _controller
      ..duration =
          AppMotion.standard
      ..forward(from: 0);

    _controller.addStatusListener(
      _handleAnimationStatus,
    );
  }

  void _handleAnimationStatus(
    AnimationStatus status,
  ) {
    if (status !=
        AnimationStatus.completed) {
      return;
    }

    _controller.removeStatusListener(
      _handleAnimationStatus,
    );

    final callback =
        _pendingCallback;

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

    _notifyProgress();

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
  Widget build(
    BuildContext context,
  ) {
    final width =
        MediaQuery.of(context).size.width;

    final normalized =
        (_dragX / width)
            .clamp(-1.0, 1.0);

    final rotation =
        normalized * 0.055;

    final progress =
        (_dragX.abs() /
                widget.threshold)
            .clamp(0.0, 1.0);

    final rightOpacity =
        _dragX > 0
            ? progress
            : 0.0;

    final leftOpacity =
        _dragX < 0
            ? progress
            : 0.0;

    final scale =
        1.0 -
            (progress * 0.008);

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,
      onPanStart:
          _onPanStart,
      onPanUpdate:
          _onPanUpdate,
      onPanEnd:
          _onPanEnd,
      child: Transform(
        alignment:
            Alignment.center,
        transform:
            Matrix4.identity()
              ..translate(
                _dragX,
                0.0,
              )
              ..rotateZ(
                rotation,
              )
              ..scale(
                scale,
              ),
        child: Stack(
          fit:
              StackFit.expand,
          children: [
            widget.child,

            Positioned(
              top: 24,
              left: 24,
              child:
                  IgnorePointer(
                child:
                    AnimatedOpacity(
                  opacity:
                      rightOpacity,
                  duration:
                      AppMotion.micro,
                  child:
                      const _SwipeStamp(
                    label:
                        'مهتم',
                    icon:
                        Icons
                            .favorite_rounded,
                    color:
                        AppColors
                            .success,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 24,
              right: 24,
              child:
                  IgnorePointer(
                child:
                    AnimatedOpacity(
                  opacity:
                      leftOpacity,
                  duration:
                      AppMotion.micro,
                  child:
                      const _SwipeStamp(
                    label:
                        'غير مهتم',
                    icon:
                        Icons
                            .close_rounded,
                    color:
                        AppColors
                            .error,
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

class _SwipeStamp
    extends StatelessWidget {
  const _SwipeStamp({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;

  final IconData icon;

  final Color color;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withOpacity(
          0.14,
        ),
        borderRadius:
            BorderRadius.circular(
          AppRadius.pill,
        ),
        border:
            Border.all(
          color:
              color.withOpacity(
            0.72,
          ),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            label,
            style:
                AppTextStyles
                    .button
                    .copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
