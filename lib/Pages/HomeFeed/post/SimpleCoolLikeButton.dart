import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:icons_plus/icons_plus.dart';

class SimpleCoolLikeButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;
  final double iconSize;

  const SimpleCoolLikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
    required this.iconSize,
  });

  @override
  State<SimpleCoolLikeButton> createState() => _SimpleCoolLikeButtonState();
}

class _SimpleCoolLikeButtonState extends State<SimpleCoolLikeButton>
    with SingleTickerProviderStateMixin {
  bool _triggerAnimation = false;

  void _handleTap() {
    setState(() => _triggerAnimation = true);
    widget.onTap();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _triggerAnimation = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Burst effect (particles)
          if (_triggerAnimation)
            ...List.generate(6, (i) => _buildBurstParticle(i)),

          // Heart icon with scale pop animation
          Animate(
            key: ValueKey(widget.isLiked), // Triggers animation when isLiked changes
            effects: [
              ScaleEffect(
                duration: 150.ms,
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.4, 1.4),
                curve: Curves.easeOut,
              ),
              ScaleEffect(
                duration: 150.ms,
                begin: const Offset(1.4, 1.4),
                end: const Offset(1.0, 1.0),
                curve: Curves.easeIn,
              ),
            ],
            child: Icon(
              widget.isLiked ? AntDesign.like_fill : AntDesign.like_outline,
              color: widget.isLiked ? Colors.pinkAccent : Colors.grey,
              size: widget.iconSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBurstParticle(int index) {
    final angle = (index / 6) * 2 * pi;
    final dx = cos(angle) * 20;
    final dy = sin(angle) * 20;

    return Positioned(
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.pinkAccent,
          shape: BoxShape.circle,
        ),
      ).animate().move(
        begin: Offset.zero,
        end: Offset(dx, dy),
        duration: 300.ms,
        curve: Curves.easeOut,
      ).fadeOut(duration: 300.ms),
    );
  }
}
