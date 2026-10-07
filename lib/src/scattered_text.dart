import 'dart:math';
import 'package:flutter/material.dart';

class ScatteredText extends StatefulWidget {
  final String text;
  final bool isScattered;
  final TextStyle textStyle;

  const ScatteredText({
    Key? key,
    required this.text,
    required this.isScattered,
    required this.textStyle,
  }) : super(key: key);

  @override
  State<ScatteredText> createState() => _ScatteredTextState();
}

class _ScatteredTextState extends State<ScatteredText> {
  late List<Offset> _randomOffsets;
  late List<double> _randomRotations;

  @override
  void initState() {
    super.initState();
    _generateRandoms();
  }

  void _generateRandoms() {
    final random = Random();
    _randomOffsets = [];
    _randomRotations = [];

    for (int i = 0; i < widget.text.length; i++) {
      // Calculate a wide random throw distance (dx: -200 to +200, dy: -400 to +400)
      double dx = (random.nextDouble() * 400) - 200;
      double dy = (random.nextDouble() * 800) - 400;

      _randomOffsets.add(Offset(dx, dy));
      // Calculate random rotation between -2π and 2π
      _randomRotations.add((random.nextDouble() * 4 * pi) - (2 * pi));
    }
  }

  @override
  void didUpdateWidget(ScatteredText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _generateRandoms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(widget.text.length, (index) {
        final char = widget.text[index];

        // Handle spaces without animating them
        if (char == ' ') {
          return SizedBox(width: widget.textStyle.fontSize! * 0.3);
        }

        // Apply random values if scattered, otherwise return to zero
        final isScattered = widget.isScattered;
        final offset = isScattered ? _randomOffsets[index] : Offset.zero;
        final rotation = isScattered ? _randomRotations[index] : 0.0;

        return AnimatedContainer(
          duration: const Duration(
            milliseconds: 800,
          ), // Speed of the throw/rearrange
          curve: Curves.easeInOutCubic,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(offset.dx, offset.dy)
            ..rotateZ(rotation),
          child: Text(char, style: widget.textStyle),
        );
      }),
    );
  }
}
