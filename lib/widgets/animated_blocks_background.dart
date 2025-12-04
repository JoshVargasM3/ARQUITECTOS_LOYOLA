import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedBlocksBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBlocksBackground({super.key, required this.child});

  @override
  State<AnimatedBlocksBackground> createState() => _AnimatedBlocksBackgroundState();
}

class _AnimatedBlocksBackgroundState extends State<AnimatedBlocksBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<_FallingBlock> _blocks = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..addListener(_tick)
      ..repeat();
  }

  void _tick() {
    final size = MediaQuery.sizeOf(context);
    if (_blocks.length < 40 && _random.nextDouble() > 0.7) {
      _blocks.add(_FallingBlock.random(_random, size));
    }
    for (final block in _blocks) {
      block.update(size);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _BlocksPainter(blocks: _blocks, time: _controller.value),
        ),
        Container(color: Colors.black.withOpacity(0.25)),
        widget.child,
      ],
    );
  }
}

class _BlocksPainter extends CustomPainter {
  final List<_FallingBlock> blocks;
  final double time;

  _BlocksPainter({required this.blocks, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final block in blocks) {
      final paint = Paint()
        ..color = HSVColor.fromAHSV(0.8, (block.hue + time * 360) % 360, 0.7, 0.9).toColor();
      final rect = Rect.fromLTWH(block.x, block.y, block.width, block.height);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlocksPainter oldDelegate) => true;
}

class _FallingBlock {
  double x;
  double y;
  double width;
  double height;
  double speed;
  double hue;

  _FallingBlock({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.speed,
    required this.hue,
  });

  factory _FallingBlock.random(Random random, Size size) {
    final blockWidth = 10 + random.nextDouble() * 30;
    final blockHeight = 10 + random.nextDouble() * 30;
    return _FallingBlock(
      x: random.nextDouble() * size.width,
      y: -random.nextDouble() * size.height,
      width: blockWidth,
      height: blockHeight,
      speed: 1 + random.nextDouble() * 3,
      hue: random.nextDouble() * 360,
    );
  }

  void update(Size size) {
    y += speed;
    if (y > size.height) {
      y = -height;
    }
    x += sin(y / 20) * 0.5;
    if (x < 0) x = size.width;
    if (x > size.width) x = 0;
  }
}
